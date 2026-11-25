import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Side navigation drawer shared by every screen, so the app has one
/// consistent way to move between pages.
///
/// - **Home** clears the navigation stack and makes [MyHomePage] the only
///   route again, so there is never a stray Back arrow on the home screen.
/// - **View Experience** / **Add Experience** / **Add Education** replace
///   the current page, so switching pages through the drawer doesn't pile
///   up routes. **Add Experience** asks the user to log in first.
/// - **Login** or **Logout** is shown depending on [AuthState]; the drawer
///   rebuilds automatically because it watches [AuthState].
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  /// Replaces the current route with [page]. Used for the page options.
  void _replaceWith(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Guarded option: log in first if needed, then open [page].
  Future<void> _replaceIfLoggedIn(BuildContext context, Widget page) async {
    if (!await ensureLoggedIn(context) || !context.mounted) return;
    _replaceWith(context, page);
  }

  /// Closes the drawer, then opens the login screen.
  void _login(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  /// Closes the drawer, revokes the token and confirms with a SnackBar.
  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthState>();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    await auth.logout();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('You have been logged out.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    // watch (not read): rebuild the drawer when the user logs in or out.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

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
            leading: const Icon(Icons.work_outline),
            title: const Text('View Experience'),
            onTap: () => _replaceWith(context, const ExperienceListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Experience'),
            onTap: () =>
                _replaceIfLoggedIn(context, const ExperienceFormPage()),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () => _replaceWith(context, const EducationFormPage()),
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _login(context),
            ),
        ],
      ),
    );
  }
}
