import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Side navigation drawer shared by every screen (home, Add Project and
/// Add Education), so the app has one consistent way to move between pages.
///
/// - **Home** clears the navigation stack and makes [MyHomePage] the only
///   route again, so there is never a stray Back arrow on the home screen.
/// - **Add Project** / **Add Education** replace the current page with the
///   chosen form, so switching forms through the drawer doesn't pile up
///   routes.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  /// Replaces the current route with [page]. Used for the form options.
  void _replaceWith(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // A Container instead of DrawerHeader: DrawerHeader has a fixed
          // height, so the title overflowed with large text sizes. This
          // header grows with its content instead.
          Container(
            // Theme primary color, same as every AppBar in the app.
            color: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.fromLTRB(
              16,
              16 + MediaQuery.paddingOf(context).top,
              16,
              24,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // pushAndRemoveUntil with `(route) => false` removes every route
            // below, so Home becomes the root again. A plain pushReplacement
            // would leave [Home, Home] when the form was opened with push
            // from an action card.
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _replaceWith(context, const ProjectFormPage()),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () => _replaceWith(context, const EducationFormPage()),
          ),
        ],
      ),
    );
  }
}
