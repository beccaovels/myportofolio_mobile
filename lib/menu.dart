import 'package:material_ui/material_ui.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506637110";
  final String nama = "Rebecca Love Lianov Simanjuntak";
  final String kelas = "KI";

  final List<ItemHomepage> items = [
    ItemHomepage("View Projects", Icons.folder, Colors.blue),
    ItemHomepage("Add Project", Icons.add_circle, Colors.green),
    ItemHomepage("Logout", Icons.logout, Colors.red),
  ];

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
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
                      Expanded(child: InfoCard(title: 'NPM', content: npm)),
                      Expanded(child: InfoCard(title: 'Name', content: nama)),
                      Expanded(child: InfoCard(title: 'Class', content: kelas)),
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
  static int gridColumnsFor(double width) {
    if (width < 360) return 2;
    if (width < 600) return 3;
    return 4;
  }
}

class InfoCard extends StatelessWidget {
  // Information card displaying a title and its associated content.
  final String title;
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("You pressed the ${item.name} button!"))
            );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          // scaleDown shrinks the icon+label only when the card is too small
          // (narrow screens, large accessibility text) instead of overflowing.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
