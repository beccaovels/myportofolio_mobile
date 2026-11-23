// Tests for the Add Education form (Assignment 8): validators, navigation
// from the action card and the drawer, validation errors, and the summary
// dialog.
//
// Run with: flutter test

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';

/// Opens the drawer of the currently visible Scaffold.
Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

/// Starts the app and opens the Education form from its action card.
Future<void> openFormFromCard(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  // On small screens the card is below the fold, so scroll to it first.
  await tester.ensureVisible(find.text('Add Education'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add Education'));
  await tester.pumpAndSettle();
  // The card's SnackBar would sit on top of the Save button on short test
  // screens for 4 seconds; remove it so taps reach the form.
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .removeCurrentSnackBar();
  await tester.pumpAndSettle();
}

/// Taps Save, scrolling to it first so it works on any screen size.
Future<void> pressSave(WidgetTester tester) async {
  final save = find.byKey(const Key('saveButton'));
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  await tester.pumpAndSettle();
}

/// Whether the root navigator could go back (i.e. something is below).
bool canPop(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator)).canPop();

void main() {
  group('validators', () {
    test('requiredText rejects empty and whitespace-only values', () {
      expect(requiredText(null, 'Institution'), 'Institution is required.');
      expect(requiredText('', 'Institution'), 'Institution is required.');
      expect(requiredText('    ', 'Institution'), 'Institution is required.');
      expect(requiredText('Universitas Indonesia', 'Institution'), isNull);
    });

    test('requiredText enforces min and max length on trimmed text', () {
      expect(requiredText('short', 'Description', minLength: 10), isNotNull);
      expect(requiredText('  ok text  ', 'Name', maxLength: 7), isNull);
      expect(requiredText('a' * 256, 'Institution', maxLength: 255), isNotNull);
      expect(requiredText('a' * 255, 'Institution', maxLength: 255), isNull);
    });

    test('optionalText allows empty but enforces max length', () {
      expect(optionalText('', 'Program', maxLength: 255), isNull);
      expect(optionalText('a' * 256, 'Program', maxLength: 255), isNotNull);
    });

    test('optionalUrl accepts blank or http(s) URLs only', () {
      expect(optionalUrl(''), isNull);
      expect(optionalUrl('https://ui.ac.id/logo.png'), isNull);
      expect(optionalUrl('http://example.com'), isNull);
      expect(optionalUrl('ui.ac.id'), isNotNull);
      expect(optionalUrl('ftp://ui.ac.id'), isNotNull);
      expect(optionalUrl('https://'), isNotNull);
      expect(optionalUrl('https://ui ac.id'), isNotNull);
    });

    test('endDateAfterStart checks date order unless ongoing', () {
      final start = DateTime(2025, 8, 1);
      expect(endDateAfterStart(start, null, isOngoing: true), isNull);
      expect(endDateAfterStart(start, null, isOngoing: false), isNotNull);
      expect(
        endDateAfterStart(start, DateTime(2024, 1, 1), isOngoing: false),
        'End date cannot be before the start date.',
      );
      expect(endDateAfterStart(start, start, isOngoing: false), isNull);
      expect(
        endDateAfterStart(start, DateTime(2029, 7, 1), isOngoing: false),
        isNull,
      );
    });

    test('formatDate gives a short readable label', () {
      expect(formatDate(DateTime(2026, 11, 23)), '23 Nov 2026');
    });
  });

  group('navigation', () {
    testWidgets('action card opens the form and system Back returns home', (
      tester,
    ) async {
      await openFormFromCard(tester);

      expect(find.byType(EducationFormPage), findsOneWidget);
      expect(canPop(tester), isTrue); // opened with push

      // Simulates the device's system Back button.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('drawer option opens the Education form', (tester) async {
      await tester.pumpWidget(const MyApp());
      await openDrawer(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsWidgets);
      await tester.tap(find.widgetWithText(ListTile, 'Add Education'));
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsOneWidget);
      expect(find.text('Add Education'), findsOneWidget); // AppBar title
    });

    testWidgets('drawer Home from the form returns to a clean home screen', (
      tester,
    ) async {
      await openFormFromCard(tester);

      // The same drawer is available on the form page.
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(EducationFormPage), findsNothing);
      // Home is the only route again: no stacked Home underneath.
      expect(canPop(tester), isFalse);
    });
  });

  group('validation and dialog', () {
    testWidgets('Save on an empty form shows errors next to the fields', (
      tester,
    ) async {
      await openFormFromCard(tester);
      await pressSave(tester);

      expect(find.text('Institution is required.'), findsOneWidget);
      expect(find.text('Description is required.'), findsOneWidget);
      expect(find.text('Pick a start date.'), findsOneWidget);
      expect(
        find.text('Pick an end date, or mark it as ongoing.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('whitespace-only institution and bad URL are rejected', (
      tester,
    ) async {
      await openFormFromCard(tester);

      await tester.enterText(find.byKey(const Key('institutionField')), '   ');
      await tester.enterText(find.byKey(const Key('logoField')), 'ui.ac.id');
      await pressSave(tester);

      expect(find.text('Institution is required.'), findsOneWidget);
      expect(
        find.text('Enter a valid URL starting with http:// or https://'),
        findsOneWidget,
      );
    });

    testWidgets('valid input shows a summary dialog, OK returns to the form', (
      tester,
    ) async {
      await openFormFromCard(tester);

      await tester.enterText(
        find.byKey(const Key('institutionField')),
        'Universitas Indonesia',
      );
      await tester.enterText(
        find.byKey(const Key('programField')),
        'S1 Ilmu Komputer KKI',
      );
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Computer Science student at Fasilkom UI.',
      );

      // Pick today's date as the start date with showDatePicker().
      final startField = find.byKey(const Key('startDateField'));
      await tester.ensureVisible(startField);
      await tester.tap(startField);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Still studying here, so no end date is needed.
      final ongoing = find.byKey(const Key('ongoingSwitch'));
      await tester.ensureVisible(ongoing);
      await tester.tap(ongoing);
      await tester.pumpAndSettle();

      await pressSave(tester);

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(find.text('Education saved!'), findsOneWidget);
      String dialogText() => tester
          .widgetList<RichText>(
            find.descendant(of: dialog, matching: find.byType(RichText)),
          )
          .map((richText) => richText.text.toPlainText())
          .join('\n');
      expect(dialogText(), contains('Institution: Universitas Indonesia'));
      expect(dialogText(), contains('Program: S1 Ilmu Komputer KKI'));
      expect(dialogText(), contains('Level: University'));
      expect(dialogText(), contains('Logo URL: -'));
      expect(
        dialogText(),
        contains('Start date: ${formatDate(DateTime.now())}'),
      );
      expect(dialogText(), contains('End date: Present (ongoing)'));

      // OK closes the dialog and leaves the user on a cleared form.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(EducationFormPage), findsOneWidget);
      expect(find.text('Universitas Indonesia'), findsNothing);
    });

    testWidgets('Save stays reachable on a small phone screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await openFormFromCard(tester);
      expect(tester.takeException(), isNull); // no overflow

      await pressSave(tester);
      expect(find.text('Pick a start date.'), findsOneWidget);
    });
  });
}
