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

### Assignment 8

1. **Explain the differences between `Navigator.push()`, `Navigator.pushReplacement()`, and `Navigator.pop()`. Which method opens the form from the action card? Explain how the Home option in the drawer takes the user back to the home screen.**
   Flutter keeps pages in a stack, kind of like a pile of cards. `Navigator.push()` puts a new page on top and keeps the old one underneath, so I can go back to it. `Navigator.pushReplacement()` also opens a new page, but it throws away the current one first, so there's nothing to go back to. `Navigator.pop()` removes the top page and shows whatever was under it. The device's Back button does this, and so does the **OK** button in my summary dialog, which is why it closes the dialog and brings me back to the form.

   The **Add Education** card uses `Navigator.push()`, so the stack becomes `[Home, Education form]` and the Back button takes me home. In the drawer, **Add Project** and **Add Education** use `pushReplacement()`, so switching between forms doesn't keep piling up pages. For **Home**, the tutorial used `pushReplacement()` too, but that has a problem. If I open the form from the card first (`[Home, Form]`) and then press Home, the form gets replaced by a *second* Home, so I end up with `[Home, Home]` and a back arrow on my home screen. So I changed Home to `Navigator.pushAndRemoveUntil(..., (route) => false)`. It opens the home screen and removes every page under it, so Home is always the only page again.

2. **How does the arrangement of `Scaffold`, `AppBar`, and `Drawer` keep the page structure consistent? Give one example of the portfolio theme colors being used on more than one page.**
   All my pages use the same skeleton: a `Scaffold` with an `AppBar` on top, `drawer: const LeftDrawer()`, and the content in `body`. Since the drawer is just one widget in `lib/widgets/left_drawer.dart`, I only had to add the Add Education option once and it showed up on all three pages. The title and the ☰ button are always in the same spot, so it feels like one app instead of separate screens stuck together.

   For colors, I set the theme once in `MaterialApp` (`ColorScheme.fromSeed(seedColor: Colors.indigo)`), and every page reads it with `Theme.of(context).colorScheme.primary`. That same primary color is on the home AppBar, the AppBar and Save button of both forms, and the drawer header. The tutorial had `Colors.indigo` hard-coded in the project form and the drawer, so I switched those to the theme color too. Now if I change the seed color, every page changes together.

3. **Why was this layout chosen for the form? Explain what the spacing and scrolling widgets do when screen space is limited.**
   I went with one column of full-width fields, in the same order as my Django `Education` model, with the Save button at the bottom. On a phone, one field per row is just easier to read and tap than putting things side by side. What each widget does:
   - `SingleChildScrollView`: My form is taller than a small phone screen, and when the keyboard pops up the page gets even shorter. Without scrolling, the bottom fields and the Save button would get cut off. With it, I can always scroll down to Save.
   - `Center` and `ConstrainedBox`: Same trick as my home page. On Chrome the fields looked way too stretched, so I keep the form in the middle and no wider than 800px.
   - `SizedBox` and `padding`: Give the same gap between every field, so the labels and the red error messages don't bump into each other.
   - `isExpanded: true` on the dropdown: Without it, the dropdown sized itself to its longest option ("Middle School") and overflowed by 14 pixels on a 320px-wide phone. With it, the dropdown just fills the field's width.

4. **What roles do `GlobalKey<FormState>`, `validator`, and `validate()` play when Save is pressed? Give one example of a value the form rejects and explain why choosing an input widget or keyboard type alone is insufficient.**
   `GlobalKey<FormState>` is attached to my `Form`, and it's how the Save button can reach the form from outside the fields. Each field has its own `validator`, a function that returns `null` if the value is okay, or an error message if it isn't. When I press Save, `_formKey.currentState!.validate()` runs all the validators at once and shows each error right under its field. It only returns `true` if everything passed, and only then does my summary dialog open.

   One value my form rejects is a logo URL like `ui.ac.id`, because my Django `URLField` expects a full `http://` or `https://` link. I did set `keyboardType: TextInputType.url` on that field, but that only changes which keyboard shows up (one with `/` and `.com`). It doesn't stop anyone from typing or pasting whatever they want, and on Chrome there isn't even a special keyboard. It's the same with dates: the date picker makes sure the date itself is valid, but it doesn't know my end date can't be before my start date. Rules like that can only be checked by a validator, which is why I have `optionalUrl` and `endDateAfterStart` in `lib/utils/form_validators.dart`.

## AI Disclosure

### Tools Used

| Tool | Version / Model |
|---|---|
| Claude App | Claude Opus 5.5 | 

### Prompt Strategy

Context first, plan before code, one topic per prompt, ask for reviews instead of rewrites, and verify everything myself.


### AI-Assisted Parts

| Part | File(s) | How the AI helped | What I did myself |
|---|---|---|---|
| `material_ui` migration (A7) | `pubspec.yaml`, `lib/*.dart`, `test/widget_test.dart` | Found that `flutter analyze` flagged `package:flutter/material.dart` as deprecated in Flutter 3.50, then added `material_ui` and switched the imports | Approved the extra dependency, reviewed and committed |
| Responsive layout | `lib/menu.dart` | Added `SingleChildScrollView`, `Expanded`, `IntrinsicHeight`, `LayoutBuilder`, `ConstrainedBox` and `FittedBox` | Chose this as my extra feature, tested in Chrome |
| Widget tests | `test/widget_test.dart` | Replaced the broken counter test with 10 home-screen tests | Reviewed and committed |
| README | `README.md` | Drafted the project overview, setup, structure, weekly progress and reflective answers (template only for reflective) | Wrote the reflective answers, reviewed and committed |
| Planning (A8) | - | Explained my project and made a plan mapped to the checklist and rubric | Chose Education as the form, chose the `feat/assignment-8` branch, approved the plan |
| Education form (A8) | `lib/screens/education_form.dart` | Wrote the form: text fields, level dropdown, date pickers, "currently studying" switch, Save and summary dialog | Matched the fields to my Django `Education` model, tested it in Chrome |
| Validators (A8) | `lib/utils/form_validators.dart` | Wrote reusable validators for required/whitespace, length, URL and date order | Checked the rules against my model |
| Navigation (A8) | `lib/screens/menu.dart`, `lib/widgets/project_card.dart`, `lib/widgets/left_drawer.dart` | Added the Add Education card and drawer option, and changed Home to `pushAndRemoveUntil` | Tested the card, Back button and drawer Home flow in Chrome |
| Theme fix (A8) | `lib/screens/project_form.dart`, `lib/widgets/left_drawer.dart` | Replaced hard-coded `Colors.indigo` with the theme's primary color | Reviewed |
| Tests (A8) | `test/education_form_test.dart` | Wrote 13 tests for validators, navigation, error messages, the dialog and small screens | Ran `flutter analyze` and `flutter test` |
| README (A8) | `README.md` | Made the Assignment 8 template and filled the reflections in my writing style | Checked the answers against my code and edited them |


### Prompt Log
A7 Link : https://claude.ai/share/e18f44c2-f338-47e5-80f7-91e0b75ae41c
A8 Link : https://claude.ai/share/45d2121e-f550-4c84-9349-a167540d4003

### Limitations of the AI

**Assignment 7:**

- **It changed my files without asking first.** When I asked it to make my code responsive, it edited `menu.dart` and `widget_test.dart` on my computer directly instead of showing me the changes first. I had to ask it to undo them.
- **It couldn't test its own code.** It said itself that it couldn't run Flutter, so its responsive changes and new tests were never run before it gave them to me.
- **Its test guide mostly repeated my existing tests.** Because it could read my project, its "how to write tests" answer was almost the same as my existing `widget_test.dart`, instead of a fresh explanation.
- **Some of its claims were unverified.** It said replacing `SingleChildScrollView` with `Padding` would make both the small-phone and landscape tests fail, but it never checked that. It also said passing tests print a ✓, but `flutter test` actually shows counters like `+10: All tests passed!`.

**Assignment 8:**

- **It didn't notice layout bugs until the tests caught them.** The level dropdown overflowed by 14 pixels on a 320px phone (fixed with `isExpanded: true`). The tutorial's `DrawerHeader` has a fixed height, so the title overflowed with bigger text (replaced with a `Container` that grows with its content). Neither of these was in its plan.

All these limitations, I fixed it myself.
