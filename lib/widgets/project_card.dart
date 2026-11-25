import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

/// A tappable, colored card that renders one [ItemHomepage].
///
/// Tapping it replaces any visible SnackBar with
/// `"You pressed the [name] button!"`, using the item's name, then runs the
/// item's [ItemHomepage.action] (open a screen with `Navigator.push`, open a
/// login-protected screen, or log out).
class ItemCard extends StatelessWidget {
  /// The action this card represents.
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          // hideCurrentSnackBar first so rapid taps don't queue messages.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("You pressed the ${item.name} button!")),
            );

          // Screens are opened with push (not pushReplacement), so the home
          // screen stays underneath and the system Back button returns to it.
          item.action?.call(context);
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
                Icon(item.icon, color: Colors.white, size: 30.0),
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
