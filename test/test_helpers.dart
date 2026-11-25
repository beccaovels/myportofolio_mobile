// Shared helpers for widget tests: a fake Django backend built on
// package:http's MockClient, so no test ever touches the network.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// One experience as Django's `ExperienceSerializer` returns it.
Map<String, dynamic> experienceJson({
  String id = '11111111-1111-1111-1111-111111111111',
  String title = 'Teaching Assistant',
  String? employer = 'Fasilkom UI',
  String description = 'Helped students learn web development.',
  String category = 'part-time',
  String startedAt = '2025-08-01T00:00:00Z',
  String? endedAt,
}) => {
  'id': id,
  'title': title,
  'employer': employer,
  'description': description,
  'category': category,
  'started_at': startedAt,
  'ended_at': endedAt,
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': 'alice, bob',
};

/// Records every request the fake backend received.
final class FakeBackend {
  FakeBackend({
    this.experiences = const [],
    this.listStatus = 200,
    this.createStatus = 201,
    this.validUsername = 'owner',
    this.validPassword = 'secret',
  });

  List<Map<String, dynamic>> experiences;
  int listStatus;
  int createStatus;
  final String validUsername;
  final String validPassword;
  final List<http.Request> requests = [];

  static const token = 'test-token-123';

  /// An [ApiClient] whose requests are answered by this fake backend.
  ApiClient get apiClient =>
      ApiClient(client: MockClient(_handle), baseUrl: 'http://test.local');

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;

    if (path == '/api/v1/experience/' && request.method == 'GET') {
      if (listStatus != 200) {
        return http.Response('<h1>Server Error</h1>', listStatus);
      }
      return _json(experiences, 200);
    }
    if (path == '/api/v1/experience/' && request.method == 'POST') {
      if (request.headers['Authorization'] != 'Token $token') {
        return _json({'detail': 'Invalid token.'}, 401);
      }
      if (createStatus != 201) {
        return _json({
          'ended_at': ["End date can't be before the start date."],
        }, createStatus);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({
        ...body,
        'id': '22222222-2222-2222-2222-222222222222',
        'star_count': 0,
        'is_starred': false,
        'starred_by_names': '',
      }, 201);
    }
    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == validUsername &&
          body['password'] == validPassword) {
        return _json({'token': token}, 200);
      }
      return _json({
        'non_field_errors': ['Unable to log in with provided credentials.'],
      }, 400);
    }
    if (path == '/api/v1/auth/logout/') {
      return http.Response('', 204);
    }
    return http.Response('Not found', 404);
  }

  static http.Response _json(Object body, int status) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
