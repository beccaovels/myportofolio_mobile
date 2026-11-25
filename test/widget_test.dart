// Widget tests for the MyPortfolio Mobile home screen (Assignment 7,
// updated for Tutorial 10's API-backed cards).
//
// Run with: flutter test

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

import 'test_helpers.dart';

/// Sets the test window to [size] logical pixels and resets it after the test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows the owner identity in three InfoCards', (tester) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text(MyHomePage.npm), findsOneWidget);
    expect(find.text(MyHomePage.nama), findsOneWidget);
    expect(find.text(MyHomePage.kelas), findsOneWidget);
  });

  testWidgets('each action card has a distinct background color', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

    final colors = tester
        .widgetList<Material>(
          find.descendant(
            of: find.byType(ItemCard),
            matching: find.byType(Material),
          ),
        )
        .map((material) => material.color)
        .toList();

    expect(colors, hasLength(MyHomePage.items.length));
    expect(colors.toSet(), hasLength(colors.length));
  });

  // Logout replaces this message with its own result (tested below).
  for (final item in MyHomePage.items.where((i) => i.name != 'Logout')) {
    testWidgets('tapping ${item.name} shows its SnackBar', (tester) async {
      await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

      await tester.tap(find.text(item.name));
      await tester.pump();

      expect(find.text('You pressed the ${item.name} button!'), findsOneWidget);
    });
  }

  testWidgets('tapping Logout while logged out says so', (tester) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text("You're not logged in."), findsOneWidget);
  });

  group('responsive layout', () {
    test('grid column count adapts to width', () {
      expect(MyHomePage.gridColumnsFor(320), 2);
      expect(MyHomePage.gridColumnsFor(411), 3);
    });

    test('grid never has more columns than cards (no empty slot)', () {
      expect(MyHomePage.gridColumnsFor(826), MyHomePage.items.length);
      expect(MyHomePage.gridColumnsFor(1280), MyHomePage.items.length);
    });

    const sizes = {
      'small phone': Size(320, 568),
      'phone': Size(411, 891),
      'phone landscape': Size(891, 411),
      'desktop': Size(1280, 800),
    };

    sizes.forEach((label, size) {
      testWidgets('renders without overflow on $label', (tester) async {
        setScreenSize(tester, size);
        await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

        // A RenderFlex overflow would surface here as an exception.
        expect(tester.takeException(), isNull);

        // The last card stays reachable by scrolling.
        await tester.ensureVisible(find.text('Logout'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();
        expect(find.text("You're not logged in."), findsOneWidget);
      });
    });
  });
}
