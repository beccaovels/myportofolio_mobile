import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Home screen of MyPortfolio Mobile.
///
/// Shows the portfolio owner's identity as three [InfoCard]s, a greeting,
/// and a grid of [ItemCard] action buttons. It is a [StatelessWidget]
/// because everything it displays is fixed at build time; the only
/// interaction (a SnackBar) is handled by [ScaffoldMessenger], not by
/// state stored in this widget.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  /// Student ID (NPM) of the portfolio owner.
  static const String npm = "2506637110";

  /// Full name of the portfolio owner.
  static const String nama = "Rebecca Love Lianov Simanjuntak";

  /// PBP class of the portfolio owner.
  static const String kelas = "KI";

  /// Action buttons shown in the grid, each with its own background color.
  /// Declared `const` so the list is created once at compile time.
  static const List<ItemHomepage> items = [
    ItemHomepage("View Projects", Icons.folder, Colors.blue),
    ItemHomepage(
      "Add Project",
      Icons.add_circle,
      Colors.green,
      destination: ProjectFormPage(),
    ),
    ItemHomepage(
      "Add Education",
      Icons.school,
      Colors.teal,
      destination: EducationFormPage(),
    ),
    ItemHomepage("Logout", Icons.logout, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      // Scrollable so nothing overflows on short screens or in landscape.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Caps the content width so it stays readable on web/tablet.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Row of 3 InfoCards sharing the width equally; IntrinsicHeight
                // keeps them the same height when a long name wraps.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: InfoCard(title: 'NPM', content: npm),
                      ),
                      const Expanded(
                        child: InfoCard(title: 'Name', content: nama),
                      ),
                      const Expanded(
                        child: InfoCard(title: 'Class', content: kelas),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Welcome to MyPortfolio Mobile!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),

                // Action grid whose column count adapts to the available width.
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.count(
                      // The outer SingleChildScrollView handles scrolling.
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: gridColumnsFor(constraints.maxWidth),
                      children: items.map((ItemHomepage item) {
                        return ItemCard(item);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maximum width of the page content on wide screens (web, tablet).
  static const double maxContentWidth = 800;

  /// Returns how many action-card columns fit in [width]:
  /// 2 on very narrow phones, 3 on regular phones, 4 on tablets/web.
  ///
  /// The result never exceeds the number of [items], so wide screens don't
  /// leave an empty slot next to the last card (3 cards fill 3 columns).
  static int gridColumnsFor(double width) {
    final int columns;
    if (width < 360) {
      columns = 2;
    } else if (width < 600) {
      columns = 3;
    } else {
      columns = 4;
    }
    return columns.clamp(1, items.length);
  }
}

/// A small elevated card showing one piece of owner information,
/// e.g. `title: 'NPM'` with `content: '2506637110'`.
///
/// It takes its width from the parent (an [Expanded] on the home screen),
/// so long [content] such as a full name wraps instead of overflowing.
class InfoCard extends StatelessWidget {
  /// Bold label shown at the top of the card.
  final String title;

  /// Value shown under [title].
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      // Width comes from the parent (Expanded), so long text wraps
      // instead of overflowing on narrow screens.
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Data model for one action button on the home screen.
///
/// Keeping the [color] and [destination] here (instead of if-else logic
/// on the name inside [ItemCard]) means adding a new button only requires
/// a new entry in [MyHomePage.items].
class ItemHomepage {
  /// Label shown on the card and used in the SnackBar message.
  final String name;

  /// Icon shown above the label.
  final IconData icon;

  /// Background color of the card; each item uses a distinct color.
  final Color color;

  /// Screen opened with `Navigator.push` when the card is tapped, or
  /// `null` if the card only shows a SnackBar.
  final Widget? destination;

  const ItemHomepage(this.name, this.icon, this.color, {this.destination});
}
