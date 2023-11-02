import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const int defaultSeed = 0xFFFFBD59;
final ThemeData defaultTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: const Color(defaultSeed),
  brightness: Brightness.light,
);

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkModeEnabled = false;
  int _seed = defaultSeed;
  bool get isDarkModeEnabled => _isDarkModeEnabled;
  ThemeData _theme = defaultTheme;
  ThemeData get theme => _theme;

  int get seed => _seed;
  set seed(int value) {
    _seed = value;
    alter(_seed);
  }

  set theme(ThemeData value) {
    _theme = value;
    notifyListeners();
  }

  parse(String value) {
    final maybeSeed = int.tryParse(value, radix: 16);
    if (maybeSeed != null) {
      seed = maybeSeed;
    }
  }

  alter(int newSeed) {
    theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Color(newSeed),
      brightness: _isDarkModeEnabled ? Brightness.dark : Brightness.light,
    );
  }

  void toggleTheme() {
    _isDarkModeEnabled = !_isDarkModeEnabled;
    alter(seed);
  }
}

class ThemeSwitcher extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const ThemeSwitcher({super.key, required this.themeNotifier});

  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  late TextEditingController _seedController;

  @override
  void initState() {
    super.initState();
    _seedController = TextEditingController(
        text: widget.themeNotifier.seed.toRadixString(16));
  }

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _seedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Color basis (seed)',
            ),
            onChanged: widget.themeNotifier.parse,
          ),
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: widget.themeNotifier.isDarkModeEnabled,
          onChanged: (value) {
            widget.themeNotifier.toggleTheme();
          },
        ),
      ],
    );
  }
}

class ThemeSwitcherScreen extends StatelessWidget {
  const ThemeSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Switcher'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: Center(
        child: ThemeSwitcher(
          themeNotifier: Provider.of<ThemeNotifier>(context),
        ),
      ),
    );
  }
}
