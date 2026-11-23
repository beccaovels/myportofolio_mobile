# MyPortfolio Mobile

A Flutter mobile app for my personal portfolio. It is the mobile companion to the Django portfolio website built in the Platform-Based Programming (PBP) course, Faculty of Computer Science, Universitas Indonesia, Odd Semester 2026/2027.

| | |
|---|---|
| **Owner** | Rebecca Love Lianov Simanjuntak |
| **NPM** | 2506637110 |
| **Class** | PBP KI |

## Features

- **Owner identity:** three information cards showing my NPM, full name and PBP class.
- **Action menu:** View Projects (blue), Add Project (green), Add Education (teal) and Logout (red), each with its own icon and color.
- **Interactive feedback:** tapping a card shows a SnackBar saying `You pressed the [Button Name] button!`.
- **Navigation drawer:** one shared `LeftDrawer` on every page with Home, Add Project and Add Education.
- **Add Project form** (Tutorial 09): name, description, category, technologies and link, with a summary dialog.
- **Add Education form** (Assignment 8): fields that mirror the `Education` model of my Django portfolio (institution, program, level, description, logo URL, start date, end date or "currently studying"). Inputs are validated (required, whitespace-only, length limits, URL format, date order) and a summary dialog shows the saved values.
- **Responsive layout:** the pages scroll on short screens, the information cards share the width equally so long text wraps, the action grid switches between 2, 3 and 4 columns depending on screen width, and on web or tablet the content is centered with a maximum width.
- **Tested:** 25 tests cover the home screen, the form validators, navigation from the card and the drawer, validation errors, the summary dialog, and small-screen layout.

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
├── main.dart                  # Entry point: runApp + MaterialApp (theme, home screen)
├── screens/
│   ├── menu.dart              # Home screen: MyHomePage, InfoCard, ItemHomepage
│   ├── project_form.dart      # Add Project form (Tutorial 09)
│   └── education_form.dart    # Add Education form (Assignment 8)
├── widgets/
│   ├── left_drawer.dart       # Shared navigation drawer
│   └── project_card.dart      # ItemCard: colored action card on the home screen
└── utils/
    └── form_validators.dart   # Reusable validators + date formatting
test/
├── widget_test.dart           # Home screen tests
└── education_form_test.dart   # Validator, navigation, validation and dialog tests
```

### How to try the Assignment 8 features

1. Run the app and tap **Add Education** on the home screen, or open the drawer (☰) and choose **Add Education**.
2. Press **Save** with the form empty: an error appears under each required field.
3. Fill it in. Try a logo URL without `https://`, or an end date before the start date, to see those errors.
4. Press **Save** again: a dialog lists everything you entered. **OK** closes it and returns to the form.
5. Use the device's Back button (when opened from the card) or the drawer's **Home** to go back to the home screen.

## Weekly Progress

| Week | Work | Highlights |
|---|---|---|
| Tutorial 08 | Basic Flutter | Project setup, split `menu.dart` from `main.dart`, `MyHomePage` as a `StatelessWidget`, `InfoCard` and `ItemCard` |
| Assignment 7 | Basic Flutter for my own portfolio | Own identity, a distinct color per action card, responsive layout, `material_ui` migration, docstrings, widget tests |
| Tutorial 09 | Navigation, layouts, forms and input elements | `LeftDrawer`, Add Project form with validation and a result dialog, `screens/` and `widgets/` folders |
| Assignment 8 | A new form for my own portfolio | Add Education form based on my Django `Education` model, date pickers, URL and date-order validation, drawer and action-card navigation, Home stack fix, reusable validators, 13 new tests |

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

### Assignment 8

1. **Explain the differences between `Navigator.push()`, `Navigator.pushReplacement()`, and `Navigator.pop()`. Which method opens the form from the action card? Explain how the Home option in the drawer takes the user back to the home screen.**
   Flutter keeps pages in a stack. `Navigator.push()` puts a new page on top and keeps the old one underneath, so you can go back to it. `Navigator.pushReplacement()` also shows a new page, but it removes the current one first, so there's nothing to go back to on that page. `Navigator.pop()` removes the top page and shows whatever was under it. The system Back button and the dialog's **OK** button both work this way.

   The **Add Education** action card uses `Navigator.push()`. The stack becomes `[Home, Education form]`, which is why the device's Back button takes me home. In the drawer, **Add Project** and **Add Education** use `pushReplacement()`, so switching between forms doesn't keep piling up pages. For **Home**, Tutorial 09 used `pushReplacement()`, but I found a problem with it. If I opened the form from the card (`[Home, Form]`) and then chose Home in the drawer, the form got replaced by a *new* Home, so the stack became `[Home, Home]` and a back arrow appeared on the home screen. I changed Home to `Navigator.pushAndRemoveUntil(..., (route) => false)`. It pushes the home screen and removes every page under it, so Home is always the only page again.

2. **How does the arrangement of `Scaffold`, `AppBar`, and `Drawer` keep the page structure consistent? Give one example of the portfolio theme colors being used on more than one page.**
   Every page uses the same skeleton: a `Scaffold` with an `AppBar` at the top, the same `drawer: const LeftDrawer()`, and the content in `body`. Because the drawer is a single widget in `lib/widgets/left_drawer.dart`, adding the Add Education option there automatically added it on all three pages. The AppBar always sits in the same place with the title and the ☰ button, so the app feels like one app instead of separate screens.

   For colors, the theme is set once in `MaterialApp` (`ColorScheme.fromSeed(seedColor: Colors.indigo)`), and the pages read it with `Theme.of(context).colorScheme.primary`. That same primary color is used for the home AppBar, the Add Project AppBar and Save button, the Add Education AppBar and Save button, and the drawer header. Tutorial 09 had `Colors.indigo` hard-coded in the project form and the drawer, so I switched those to the theme color too. If I ever change the seed color, every page changes together.

3. **Why was this layout chosen for the form? Explain what the spacing and scrolling widgets do when screen space is limited.**
   The form is one column of full-width fields, in the same order as the fields in my Django `Education` model, with the Save button at the bottom. On a phone, one field per row is easier to read and tap than a side-by-side layout. The widgets I used:
   - `SingleChildScrollView`: the form is taller than a small phone screen, and when the keyboard opens the `Scaffold` shrinks the body even more. Without scrolling, the bottom fields and the Save button would get cut off with an overflow error. With it, the user can always scroll down to Save. My test checks this on a 320×568 screen.
   - `Center` + `ConstrainedBox(maxWidth: 800)`: on Chrome or a tablet the fields would stretch across the whole screen, so I cap the width like on the home screen.
   - `SizedBox(height: 16)` and `padding`: give even spacing between fields so the labels and error messages don't touch each other.
   - `isExpanded: true` on the dropdown: it makes the dropdown fill the field width instead of sizing itself to the longest item. Without it, the form overflowed by 14 pixels on a 320px-wide phone.

4. **What roles do `GlobalKey<FormState>`, `validator`, and `validate()` play when Save is pressed? Give one example of a value the form rejects and explain why choosing an input widget or keyboard type alone is insufficient.**
   `GlobalKey<FormState>` is attached to the `Form`, and it lets the Save button reach the form's state from outside the fields. Each field has a `validator` function that returns `null` if the value is fine, or an error message if it isn't. When Save is pressed, `_formKey.currentState!.validate()` runs every field's validator at once and shows each error message under its field. It returns `true` only if all of them passed, and only then do I open the summary dialog.

   One example of a rejected value is a logo URL like `ui.ac.id` (or `ftp://ui.ac.id`). It's rejected because my Django `URLField` expects a full `http://` or `https://` URL. I set `keyboardType: TextInputType.url` on that field, but that only changes which keyboard pops up (it adds `/` and `.com` keys). It doesn't stop anyone from typing or pasting anything they want, and on Chrome there's no special keyboard at all. In the same way, a date picker makes sure the date *format* is right, but it can't know that my end date must not be before my start date. Only a validator can check rules like that, so I use the `optionalUrl` and `endDateAfterStart` functions in `lib/utils/form_validators.dart`.

## AI Disclosure

### Tools Used

| Tool | Version / Model | Used for |
|---|---|---|
| Claude App | Claude Opus 5.5 | Assignment 7: refactoring the Flutter code, writing widget tests, running `flutter analyze` / `flutter test`, and drafting the README |
| Claude Code (VS Code extension) | Claude Opus 5.5 | Assignment 8: planning, the Education form, navigation changes, tests and the README draft |

### Prompt Strategy

I gave the AI clear context and goals at the start, then guided it with short follow-up prompts and specific feedback until the result was what I wanted.

For Assignment 8, I first gave the AI the assignment PDF and had it **plan only** (no code) and explain my project and what would change. I made the key decisions myself: Education as the section (so the fields match my Django `Education` model), and a `feat/assignment-8` branch off `tutor/9`. I told it to use conventional commits and **not** to commit, push or add itself as co-author, so every commit is mine. After the plan was approved, it implemented the plan, and I reviewed the diff, ran the app in Chrome and committed in small steps.

### AI-Assisted Parts

| Part | File(s) | How the AI helped | What I did myself |
|---|---|---|---|
| `material_ui` migration | `pubspec.yaml`, `lib/*.dart`, `test/widget_test.dart` | Found that `flutter analyze` flagged `package:flutter/material.dart` as deprecated in Flutter 3.50, then added `material_ui` and switched the imports | Approved the extra dependency, reviewed and committed |
| Responsive layout | `lib/menu.dart` | Added `SingleChildScrollView`, `Expanded`, `IntrinsicHeight`, `LayoutBuilder`, `ConstrainedBox` and `FittedBox` | Chose this as my extra feature, tested in Chrome |
| Widget tests | `test/widget_test.dart` | Replaced the broken counter test with 10 home-screen tests | Reviewed and committed |
| README | `README.md` | Drafted the project overview, setup, structure, weekly progress and reflective answers (template only for reflective) |
| Education form (A8) | `lib/screens/education_form.dart` | Wrote the form with date pickers, the ongoing switch and the summary dialog | Chose Education and matched the fields to my Django model, tested it in Chrome |
| Validators (A8) | `lib/utils/form_validators.dart` | Moved the validation rules into small reusable functions | Reviewed the rules against my model (255 limit, URL, dates) |
| Navigation (A8) | `lib/screens/menu.dart`, `lib/widgets/project_card.dart`, `lib/widgets/left_drawer.dart` | Added the card and drawer option, replaced the `if (name == ...)` check with a `destination` field, changed Home to `pushAndRemoveUntil` | Checked the back and Home flows on Chrome |
| Tests (A8) | `test/education_form_test.dart` | Wrote 13 tests for validators, navigation, errors, the dialog and small screens | Ran `flutter test` and `flutter analyze` |
| README (A8) | `README.md` | Drafted the structure, weekly progress and Assignment 8 answers | Rewrote the answers in my own words |

### Prompt Log
- Assignment 7: https://claude.ai/share/e18f44c2-f338-47e5-80f7-91e0b75ae41c
- Assignment 8: *(add your Claude Code session share link / exported log here)*

### Limitations of the AI

- **It changed my files without asking first.** When I asked it to make my code responsive, it edited `menu.dart` and `widget_test.dart` on my computer directly instead of showing me the changes first. I had to ask it to undo them.
- **It couldn't test its own code.** It said itself that it couldn't run Flutter, so its responsive changes and new tests were never run before it gave them to me.
- **Its test guide mostly repeated my existing tests.** Because it could read my project, its "how to write tests" answer was almost the same as my existing `widget_test.dart`, instead of a fresh explanation.
- **Some of its claims were unverified.** It said replacing `SingleChildScrollView` with `Padding` would make both the small-phone and landscape tests fail, but it never checked that. It also said passing tests print a ✓, but `flutter test` actually shows counters like `+10: All tests passed!`.

All these limitations, I fixed it myself.

**Assignment 8:**

- **Its first tests failed, and some of the failures were its own mistakes.** Three tests failed on the first run. Two came from the tests themselves: the "You pressed the button" SnackBar was covering the Save button, and on a small screen the action card was below the fold, so the tap missed. The test had to dismiss the SnackBar and scroll first.
- **It missed real layout bugs until the tests caught them.** The level dropdown overflowed by 14 pixels on a 320px phone because it sized itself to "Middle School" (fixed with `isExpanded: true`). The Tutorial 09 `DrawerHeader` has a fixed height, so with bigger text the title overflowed (replaced with a `Container` that grows with its content). Neither showed up in its plan.
- **It never ran the app itself.** It only checked its work with `flutter analyze` and widget tests (which use a fake test font, not a real browser), so I still had to run the app in Chrome and try every flow by hand: card, drawer, Back, Home, empty Save, valid Save.
- **The reflective answers are a draft.** They describe its own changes, so I checked each claim against the code and rewrote them in my own words.
