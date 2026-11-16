import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of MyPortfolio Mobile.
///
/// [MaterialApp] provides the app-wide theme (indigo seed color with an
/// amber secondary), navigation, and Material defaults that every screen
/// inherits through [BuildContext].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber[700],
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
