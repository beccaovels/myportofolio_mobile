import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Holds the in-memory authentication token for the current session and
/// notifies listeners (e.g. the drawer) when the user logs in or out.
///
/// The token is not persisted, so closing the app logs the user out.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Exchanges [username] and [password] for a token. Throws
  /// [ApiException] (e.g. 400 for wrong credentials) and stays logged out.
  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  /// Revokes the token on the server, then forgets it locally.
  ///
  /// The local token is cleared even if the server request fails (offline,
  /// token already revoked, ...), so the user is never stuck "logged in".
  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException catch (error) {
      debugPrint('Server logout failed: $error');
    } on Exception catch (error) {
      // Network errors (e.g. http.ClientException when offline).
      debugPrint('Server logout failed: $error');
    } finally {
      _token = null;
      notifyListeners();
    }
  }
}
