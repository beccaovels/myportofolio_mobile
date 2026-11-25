import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Makes sure the user is logged in before a protected action.
///
/// Returns `true` right away if there is already a token. Otherwise it
/// pushes [LoginScreen] and returns whether the login succeeded (`false`
/// if the user pressed Back instead).
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;

  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return loggedIn ?? false;
}

/// Runs [ensureLoggedIn], then pushes [page] if the user is logged in.
/// Used by the guarded action card and drawer option.
Future<void> pushIfLoggedIn(BuildContext context, Widget page) async {
  final allowed = await ensureLoggedIn(context);
  if (!allowed || !context.mounted) return;
  await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}
