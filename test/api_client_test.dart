// Unit tests for Tutorial 10's data layer: the Experience model, ApiClient
// and AuthState. All HTTP goes to a MockClient (see test_helpers.dart).
//
// Run with: flutter test

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'test_helpers.dart';

void main() {
  group('Experience model', () {
    test('fromJson maps snake_case keys and handles nulls', () {
      final experience = Experience.fromJson(
        experienceJson(employer: null, endedAt: null),
      );
      expect(experience.id, '11111111-1111-1111-1111-111111111111');
      expect(experience.startedAt, DateTime.utc(2025, 8, 1));
      expect(experience.employer, ''); // null -> ''
      expect(experience.isOngoing, isTrue);
      expect(experience.categoryLabel, 'Part-Time');
      expect(experience.starCount, 2);
    });

    test('toJson omits server-only fields and sends UTC dates', () {
      final json = Experience(
        id: 'should-not-be-sent',
        title: 'Mobile Developer',
        description: 'Built the app.',
        category: 'freelance',
        startedAt: DateTime.utc(2026, 11, 1),
        starCount: 99,
      ).toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('star_count'), isFalse);
      expect(json['started_at'], '2026-11-01T00:00:00.000Z');
      expect(json['ended_at'], isNull);
      expect(json['category'], 'freelance');
    });
  });

  group('ApiClient', () {
    test('getExperiences parses the list', () async {
      final backend = FakeBackend(
        experiences: [
          experienceJson(),
          experienceJson(title: 'Researcher'),
        ],
      );
      final experiences = await backend.apiClient.getExperiences();

      expect(experiences.map((e) => e.title), [
        'Teaching Assistant',
        'Researcher',
      ]);
      expect(backend.requests.single.headers['Authorization'], isNull);
    });

    test('createExperience sends the token and a JSON body', () async {
      final backend = FakeBackend();
      final saved = await backend.apiClient.createExperience(
        Experience(
          title: 'Mobile Developer',
          description: 'Built the app.',
          category: 'freelance',
          startedAt: DateTime.utc(2026, 11, 1),
        ),
        token: FakeBackend.token,
      );

      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.headers['Authorization'], 'Token ${FakeBackend.token}');
      expect(request.headers['Content-Type'], contains('application/json'));
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['title'], 'Mobile Developer');
      expect(body.containsKey('id'), isFalse);
      expect(saved.id, isNotNull); // assigned by the "server"
    });

    test('obtainToken returns the token', () async {
      final token = await FakeBackend().apiClient.obtainToken(
        'owner',
        'secret',
      );
      expect(token, FakeBackend.token);
    });

    test('wrong credentials throw ApiException with the DRF message', () {
      expect(
        FakeBackend().apiClient.obtainToken('owner', 'wrong'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                'Unable to log in with provided credentials.',
              ),
        ),
      );
    });

    test('invalid token on create throws 401', () {
      expect(
        FakeBackend().apiClient.createExperience(
          Experience(
            title: 'x',
            description: 'y',
            category: 'freelance',
            startedAt: DateTime.utc(2026),
          ),
          token: 'expired',
        ),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 401)),
      );
    });

    test('server errors get a friendly message, not raw HTML', () async {
      final backend = FakeBackend(listStatus: 500);
      try {
        await backend.apiClient.getExperiences();
        fail('Expected ApiException');
      } on ApiException catch (error) {
        expect(error.statusCode, 500);
        expect(error.message, isNot(contains('<h1>')));
        expect(error.body, contains('<h1>')); // raw body kept for debugging
      }
    });

    test('logout posts the token to /auth/logout/', () async {
      final backend = FakeBackend();
      await backend.apiClient.logout(token: FakeBackend.token);
      final request = backend.requests.single;
      expect(request.url.path, '/api/v1/auth/logout/');
      expect(request.headers['Authorization'], 'Token ${FakeBackend.token}');
    });
  });

  group('AuthState', () {
    test('login stores the token and notifies listeners', () async {
      final auth = AuthState(FakeBackend().apiClient);
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.login('owner', 'secret');

      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, FakeBackend.token);
      expect(notified, 1);
    });

    test('failed login stays logged out', () async {
      final auth = AuthState(FakeBackend().apiClient);
      await expectLater(
        auth.login('owner', 'wrong'),
        throwsA(isA<ApiException>()),
      );
      expect(auth.isLoggedIn, isFalse);
    });

    test('logout clears the token even when the server fails', () async {
      final failingApi = ApiClient(
        client: MockClient((_) async => http.Response('down', 503)),
        baseUrl: 'http://test.local',
      );
      final auth = AuthState(failingApi, initialToken: 'abc');
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      expect(notified, 1);
    });

    test('logout when already logged out does nothing', () async {
      final backend = FakeBackend();
      await AuthState(backend.apiClient).logout();
      expect(backend.requests, isEmpty);
    });
  });
}
