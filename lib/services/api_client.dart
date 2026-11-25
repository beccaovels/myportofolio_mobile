import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/experience.dart';

/// Thrown when the API answers with a non-2xx status code.
///
/// [message] is a short, user-friendly sentence based on [statusCode], so
/// screens never show the raw response body (which can be a full Django
/// HTML error page when `DEBUG=True`). The raw body is kept in [body] for
/// debugging and for reading DRF field errors.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message, {this.body = ''});

  final int statusCode;
  final String message;
  final String body;

  /// Builds an [ApiException] with a friendly message for [statusCode].
  factory ApiException.fromResponse(http.Response response) {
    final code = response.statusCode;
    final String message;
    if (code == 400) {
      message = _firstFieldError(response.body) ?? 'Some input is invalid.';
    } else if (code == 401) {
      message = 'Your session has expired. Please log in again.';
    } else if (code == 403) {
      message = "You don't have permission to do that.";
    } else if (code == 404) {
      message = 'Not found.';
    } else if (code >= 500) {
      message = 'The server had a problem. Please try again later.';
    } else {
      message = 'Request failed.';
    }
    return ApiException(code, message, body: response.body);
  }

  /// Reads the first message from a DRF 400 body such as
  /// `{"ended_at": ["End date can't be before the start date."]}` or
  /// `{"non_field_errors": ["Unable to log in with provided credentials."]}`.
  static String? _firstFieldError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded.isNotEmpty) {
        final first = decoded.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        if (first is String) return first;
      }
    } on FormatException {
      // Not JSON (e.g. an HTML error page): fall back to the generic text.
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
///
/// Uses plain string header keys instead of `dart:io`'s `HttpHeaders`,
/// because importing `dart:io` breaks Flutter Web builds.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// `GET /api/v1/experience/` (public, no token needed).
  Future<List<Experience>> getExperiences() async {
    final response = await _client.get(
      _uri('/api/v1/experience/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Experience.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// `POST /api/v1/experience/` with `Authorization: Token <token>`.
  /// Only the portfolio owner (superuser) may create; returns the saved
  /// experience including its server-generated id.
  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/experience/'),
      headers: {..._jsonHeaders, 'Authorization': 'Token $token'},
      body: jsonEncode(experience.toJson()),
    );
    _ensureSuccess(response);
    return Experience.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// `POST /api/v1/auth/token/`: exchanges username + password for a token.
  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  /// `POST /api/v1/auth/logout/`: revokes [token] on the server (204).
  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  /// Throws [ApiException] for any non-2xx response, so callers (and
  /// `FutureBuilder`) can show an error instead of receiving `null`.
  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw ApiException.fromResponse(response);
  }
}
