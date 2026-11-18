# MyPortfolio Mobile

A Flutter mobile app for my personal portfolio. It is the mobile companion to the Django portfolio website built in the Platform-Based Programming (PBP) course, Faculty of Computer Science, Universitas Indonesia, Odd Semester 2026/2027.

| | |
|---|---|
| **Owner** | Rebecca Love Lianov Simanjuntak |
| **NPM** | 2506637110 |
| **Class** | PBP KI |

## Features

- **Owner identity:** three information cards showing my NPM, full name and PBP class.
- **Action menu:** View Projects (blue), Add Project (green) and Logout (red), each with its own icon and color.
- **Interactive feedback:** tapping a card shows a SnackBar saying `You pressed the [Button Name] button!`.
- **Responsive layout:** the page scrolls on short screens, the information cards share the width equally so long text wraps, the action grid switches between 2, 3 and 4 columns depending on screen width, and on web or tablet the content is centered with a maximum width.
- **Tested:** widget tests cover the identity cards, card colors, SnackBars, and layout at four screen sizes.

## Tech Stack

- [Flutter](https://flutter.dev) 3.50 (stable), Dart 3.14
- [`material_ui`](https://pub.dev/packages/material_ui), the Material widgets package that replaces the deprecated `package:flutter/material.dart` import from Flutter 3.50 onwards
- `flutter_test` and `flutter_lints` for testing and static analysis

## Getting Started

### Prerequisites

- Flutter SDK 3.50 or newer (`flutter --version`)
- One target: Chrome, an Android emulator or device, or Windows desktop
- `flutter doctor` reports no blocking issues

### Setup and run

```bash
git clone https://github.com/beccaovels/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
flutter run -d chrome      # or: flutter run (picks a connected device)
```

### Quality checks

```bash
flutter analyze   # expected: No issues found!
flutter test      # expected: All tests passed!
```

## Project Structure

```
lib/
├── main.dart        # Entry point: runApp + MaterialApp (theme, home screen)
└── menu.dart        # Home screen: MyHomePage, InfoCard, ItemHomepage, ItemCard
test/
└── widget_test.dart # Widget tests for the home screen
```

## Weekly Progress

| Week | Work | Highlights |
|---|---|---|
| Tutorial 08 | Basic Flutter | Project setup, split `menu.dart` from `main.dart`, `MyHomePage` as a `StatelessWidget`, `InfoCard` and `ItemCard` |
| Assignment 7 | Basic Flutter for my own portfolio | Own identity, a distinct color per action card, responsive layout, `material_ui` migration, docstrings, widget tests |
| Tutorial 09 / Assignment 8 | Navigation, layouts, forms and input elements | *Coming next* |

## Reflective Questions

### Assignment 7

1. **Explain what a widget tree is in Flutter and how parent-child relationships work between widgets.**
   In Flutter, everything on screen is a widget, and widgets are nested inside each other to form a tree. So, a widget tree is a nested structure where every Flutter UI is built from. The root of this app is `MyApp`, which builds a `MaterialApp`. That contains `MyHomePage`, which builds a `Scaffold` holding an `AppBar` and a body, and so on down to individual `Text` and `Icon` widgets. A parent decides where its children are placed and how much space they get: it passes constraints down, each child picks a size within them, and the parent positions it. For example, a `Row` lays its children out horizontally, and `Expanded` tells a child to take an equal share of the remaining width. Data also flows down the tree. Children can read things provided by an ancestor, such as `Theme.of(context)` reading the theme defined in `MaterialApp`. When something changes, Flutter rebuilds only the affected subtree.

2. **List all the widgets you used in this project and explain each of their functions.**
   - `MaterialApp`: The very top of my app. It holds my theme colors and opens `MyHomePage` as the first page.
   - `Scaffold`: Basically the skeleton of the page. It gives me a spot for the app bar and the body, and it's also what shows the SnackBar.
   - `AppBar`: The bar at the top that says "MyPortfolio". I colored it with the theme's primary color so it matches.
   - `Column` / `Row`: `Column` stacks things from top to bottom, and `Row` puts them side by side. My three identity cards sit in a `Row`.
   - `Expanded`: Makes the three identity cards share the width equally. My full name is pretty long, so this lets it wrap instead of overflowing.
   - `IntrinsicHeight`: Because my name wraps, the Name card got taller than the others. This keeps all three the same height so it looks neat.
   - `GridView.count`: Puts the action buttons in a grid.
   - `LayoutBuilder`: Tells me how wide the screen is, so I can show 2, 3 or 4 columns depending on the device.
   - `Center` and `ConstrainedBox`: I use these together so the page stays in the middle and doesn't go wider than 800px. Without them it looked stretched on Chrome.
   - `SingleChildScrollView`: Makes the page scrollable, so on a small phone or in landscape nothing gets cut off.
   - `Padding`, `SizedBox` and `Container`: These give some breathing room around and between things so they aren't squished together.
   - `FittedBox`: If a button gets too small, it shrinks the icon and text to fit instead of overflowing.
   - `Text` / `Icon`: Show the text and the little icon on each button.
   - `Card`: The box with a small shadow that I used for each identity card.
   - `Material`: Gives each button its own color (blue, green and red) and rounded corners. It's also what makes the tap ripple visible.
   - `InkWell`: Makes the button tappable and runs the code that shows the SnackBar.
   - `SnackBar`: The little message at the bottom that says "You pressed the [Button Name] button!".
   - `MyApp`, `MyHomePage`, `InfoCard` and `ItemCard` are my own `StatelessWidget`s, made by combining the widgets above. `ItemHomepage` isn't actually a widget, it's just a small class that stores each button's name, icon and color.

3. **What is the purpose of the `MaterialApp` widget? Explain why this widget is commonly used as the root widget in Flutter applications.**
   `MaterialApp` is like the setup for the whole app. It holds the theme (in my case indigo with an amber accent), the app title, which page opens first, and the navigation between pages. It also sets up the `ScaffoldMessenger` that I use for SnackBars. Widgets like `Scaffold`, `AppBar` and `SnackBar` look up the tree to find these things, so they need `MaterialApp` somewhere above them to work properly. That's why it's usually the root: you set everything up once at the top, and every page under it automatically gets the same look and navigation.

4. **Explain the difference between `StatelessWidget` and `StatefulWidget`. When should you choose `StatelessWidget`, and when is `StatefulWidget` necessary?**
   A `StatelessWidget` doesn't remember anything on its own. It just shows whatever it's given, and it only changes when its parent gives it new values. A `StatefulWidget` has a `State` object that can hold data that changes over time, and when I call `setState()`, Flutter redraws it with the new data. I'd pick `StatelessWidget` when the screen only depends on fixed values, like my home page: my identity, the buttons and their colors never change, and the SnackBar is handled by `ScaffoldMessenger`, not by my widget. `StatefulWidget` is needed when the widget itself has to keep track of something that changes, like what the user types in a form, a counter, a switch being turned on or off, or data that's still loading.

5. **What is `BuildContext` and why is it crucial in Flutter? How is it used inside the `build` method?**
   `BuildContext` is basically the widget's address in the widget tree. Every `build` method gets one, and it's what a widget uses to look up things from the widgets above it. In my app, `Theme.of(context).colorScheme.primary` uses the context to find the theme from `MaterialApp` and color the `AppBar`. In `ItemCard`, `ScaffoldMessenger.of(context)` uses it to find where to show the SnackBar. Without the context, a widget wouldn't know where it is, so it couldn't reach any of these. One thing to keep in mind is that it only searches upward, so the context has to come from a widget that sits below the thing you're looking for.

6. **Explain the concept of hot reload in Flutter and how it differs from hot restart. When can you not rely on hot reload and must instead perform a hot restart or full restart?**
   Hot reload puts my code changes into the app that's already running, and it keeps the current state. It's super fast, so it's perfect for small UI changes like colors, padding or text. Hot restart also loads the new code, but it resets everything and starts the app again from `main()`, so the state is lost. A full restart means stopping the app completely and running `flutter run` again, which also rebuilds the native part of the app.

   Hot reload isn't enough when the change is in code that already ran before. For example:
   - Changing `main()` or what's inside `initState()`
   - Changing the starting value of a global variable or a static field
   - Changing an enum or a generic type
   - Turning a `StatelessWidget` into a `StatefulWidget`

   For those, I need a hot restart. If I add a new package or plugin, edit native Android/iOS code, or change the assets in `pubspec.yaml`, I need a full restart.

## AI Disclosure

### Tools Used

| Tool | Version / Model | Used for |
|---|---|---|
| Claude App | Claude Opus 5.5 | Refactoring the Flutter code, writing widget tests, running `flutter analyze` / `flutter test`, and drafting the README |

### Prompt Strategy

I gave the AI clear context and goals at the start, then guided it with short follow-up prompts and specific feedback until the result was what I wanted.

### AI-Assisted Parts

| Part | File(s) | How the AI helped | What I did myself |
|---|---|---|---|
| `material_ui` migration | `pubspec.yaml`, `lib/*.dart`, `test/widget_test.dart` | Found that `flutter analyze` flagged `package:flutter/material.dart` as deprecated in Flutter 3.50, then added `material_ui` and switched the imports | Approved the extra dependency, reviewed and committed |
| Responsive layout | `lib/menu.dart` | Added `SingleChildScrollView`, `Expanded`, `IntrinsicHeight`, `LayoutBuilder`, `ConstrainedBox` and `FittedBox` | Chose this as my extra feature, tested in Chrome |
| Widget tests | `test/widget_test.dart` | Replaced the broken counter test with 10 home-screen tests | Reviewed and committed |
| README | `README.md` | Drafted the project overview, setup, structure, weekly progress and reflective answers (template only for reflective) |

### Prompt Log
Link : https://claude.ai/share/e18f44c2-f338-47e5-80f7-91e0b75ae41c

### Limitations of the AI

- **It changed my files without asking first.** When I asked it to make my code responsive, it edited `menu.dart` and `widget_test.dart` on my computer directly instead of showing me the changes first. I had to ask it to undo them.
- **It couldn't test its own code.** It said itself that it couldn't run Flutter, so its responsive changes and new tests were never run before it gave them to me.
- **Its test guide mostly repeated my existing tests.** Because it could read my project, its "how to write tests" answer was almost the same as my existing `widget_test.dart`, instead of a fresh explanation.
- **Some of its claims were unverified.** It said replacing `SingleChildScrollView` with `Padding` would make both the small-phone and landscape tests fail, but it never checked that. It also said passing tests print a ✓, but `flutter test` actually shows counters like `+10: All tests passed!`.

All these limitations, I fixed it myself.
