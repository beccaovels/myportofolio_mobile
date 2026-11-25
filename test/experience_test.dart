// Widget tests for Tutorial 10's screens: the experience list and detail
// (FutureBuilder states), the login guard, posting the experience form,
// and the drawer's Login/Logout option.
//
// Run with: flutter test

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

import 'test_helpers.dart';

/// Starts the app against [backend] and taps the home card [name].
Future<void> tapCard(
  WidgetTester tester,
  FakeBackend backend,
  String name,
) async {
  await tester.pumpWidget(MyApp(apiClient: backend.apiClient));
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
  // Remove the "You pressed ..." SnackBar so it can't cover buttons.
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .removeCurrentSnackBar();
  await tester.pumpAndSettle();
}

/// Fills in the login screen and submits it.
Future<void> logIn(
  WidgetTester tester, {
  String username = 'owner',
  String password = 'secret',
}) async {
  await tester.enterText(find.byKey(const Key('usernameField')), username);
  await tester.enterText(find.byKey(const Key('passwordField')), password);
  await tester.tap(find.byKey(const Key('loginButton')));
  await tester.pumpAndSettle();
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

void main() {
  group('experience list', () {
    testWidgets('shows a spinner, then the experiences from the API', (
      tester,
    ) async {
      // The response is held back until we complete it, so the loading
      // state can be checked first.
      final response = Completer<http.Response>();
      final api = ApiClient(
        client: MockClient((_) => response.future),
        baseUrl: 'http://test.local',
      );
      await tester.pumpWidget(MyApp(apiClient: api));
      await tester.tap(find.text('View Experience'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ExperienceListScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      response.complete(
        http.Response(
          jsonEncode([
            experienceJson(),
            experienceJson(id: 'b', title: 'Researcher', category: 'research'),
          ]),
          200,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Teaching Assistant'), findsOneWidget);
      expect(find.text('Researcher'), findsOneWidget);
      // Public endpoint: no login was needed.
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('shows an empty message when there is no data', (tester) async {
      await tapCard(tester, FakeBackend(), 'View Experience');
      expect(find.text('No experiences found.'), findsOneWidget);
    });

    testWidgets('shows an error with Retry, and Retry reloads', (tester) async {
      final backend = FakeBackend(listStatus: 500);
      await tapCard(tester, backend, 'View Experience');

      expect(find.textContaining('Failed to load experiences'), findsOneWidget);
      expect(find.textContaining('<h1>'), findsNothing); // no raw HTML

      backend
        ..listStatus = 200
        ..experiences = [experienceJson()];
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Teaching Assistant'), findsOneWidget);
    });

    testWidgets('tapping an experience opens its detail screen', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [experienceJson()]);
      await tapCard(tester, backend, 'View Experience');

      await tester.tap(find.text('Teaching Assistant'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceDetailScreen), findsOneWidget);
      expect(find.text('Fasilkom UI'), findsOneWidget);
      expect(find.text('Part-Time'), findsOneWidget);
    });

    testWidgets('detail hides the employer row when it is empty', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [experienceJson(employer: '')]);
      await tapCard(tester, backend, 'View Experience');
      await tester.tap(find.text('Teaching Assistant'));
      await tester.pumpAndSettle();

      expect(find.text('Employer'), findsNothing);
      expect(find.textContaining('Present'), findsOneWidget); // ongoing
    });
  });

  group('auth guard', () {
    testWidgets('Add Experience asks for login when logged out', (
      tester,
    ) async {
      await tapCard(tester, FakeBackend(), 'Add Experience');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });

    testWidgets('empty login fields show validation errors', (tester) async {
      await tapCard(tester, FakeBackend(), 'Add Experience');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);
    });

    testWidgets('wrong password shows the error and stays on login', (
      tester,
    ) async {
      await tapCard(tester, FakeBackend(), 'Add Experience');
      await logIn(tester, password: 'wrong');

      expect(
        find.text(
          'Login failed (400): Unable to log in with provided credentials.',
        ),
        findsOneWidget,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('after logging in, the form opens', (tester) async {
      await tapCard(tester, FakeBackend(), 'Add Experience');
      await logIn(tester);

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(ExperienceFormPage), findsOneWidget);
    });
  });

  group('experience form', () {
    testWidgets('valid input is POSTed with the token and confirmed', (
      tester,
    ) async {
      final backend = FakeBackend();
      await tapCard(tester, backend, 'Add Experience');
      await logIn(tester);

      await tester.enterText(
        find.byKey(const Key('titleField')),
        'Mobile Developer',
      );
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Built the portfolio app in Flutter.',
      );

      final startField = find.byKey(const Key('startDateField'));
      await tester.ensureVisible(startField);
      await tester.tap(startField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // date picker
      await tester.pumpAndSettle();

      final ongoing = find.byKey(const Key('ongoingSwitch'));
      await tester.ensureVisible(ongoing);
      await tester.tap(ongoing);
      await tester.pumpAndSettle();

      final save = find.byKey(const Key('saveButton'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.text('Experience saved!'), findsOneWidget);

      final post = backend.requests.lastWhere(
        (r) => r.method == 'POST' && r.url.path == '/api/v1/experience/',
      );
      expect(post.headers['Authorization'], 'Token ${FakeBackend.token}');
      final body = jsonDecode(post.body) as Map<String, dynamic>;
      expect(body['title'], 'Mobile Developer');
      expect(body['category'], 'full-time');
      expect(body['ended_at'], isNull);
      expect(body.containsKey('id'), isFalse);

      await tester.tap(find.text('OK')); // close the dialog
      await tester.pumpAndSettle();
      expect(find.text('Experience saved!'), findsNothing);
      expect(find.text('Mobile Developer'), findsNothing); // form cleared
    });

    testWidgets('invalid input is not sent', (tester) async {
      final backend = FakeBackend();
      await tapCard(tester, backend, 'Add Experience');
      await logIn(tester);

      await tester.enterText(find.byKey(const Key('titleField')), '   ');
      final save = find.byKey(const Key('saveButton'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.text('Title is required.'), findsOneWidget);
      expect(find.text('Pick a start date.'), findsOneWidget);
      expect(
        backend.requests.where((r) => r.url.path == '/api/v1/experience/'),
        isEmpty,
      );
    });
  });

  group('drawer', () {
    testWidgets('shows Login when logged out and Logout after login', (
      tester,
    ) async {
      await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));
      await openDrawer(tester);
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);

      await tester.tap(find.widgetWithText(ListTile, 'Login'));
      await tester.pumpAndSettle();
      await logIn(tester);

      expect(find.byType(MyHomePage), findsOneWidget);
      await openDrawer(tester);
      expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await tester.pumpAndSettle();
      expect(find.text('You have been logged out.'), findsOneWidget);

      await openDrawer(tester);
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
    });

    testWidgets('Add Experience in the drawer is guarded too', (tester) async {
      await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Add Experience'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      await logIn(tester);
      expect(find.byType(ExperienceFormPage), findsOneWidget);
    });
  });
}
