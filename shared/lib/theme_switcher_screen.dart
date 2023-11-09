import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'server_url_notifier.dart';

const int defaultSeed = 0xFFFFBD59;

final AppTheme defaultAppTheme = AppTheme(
  seed: 0xFFFFBD59,
  brightness: Brightness.light,
  appBar: BGFG(
    background: const Color(0xFFFFEB96),
    foreground: Colors.black,
  ),
  queueItem: BGFG(
    background: const Color(0xFF403734),
    foreground: Colors.white,
  ),
  appBackground: const Color(0xFFFFF7CF),
);

class BGFG {
  final Color background;
  final Color foreground;

  BGFG({required this.background, required this.foreground});

  factory BGFG.fromJson(Map<String, dynamic> json) {
    return BGFG(
      background: Color(int.parse(json['background'], radix: 16)),
      foreground: Color(int.parse(json['foreground'], radix: 16)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background': background.value.toRadixString(16),
      'foreground': foreground.value.toRadixString(16),
    };
  }

  // create a copyWith method
  BGFG copyWith({
    Color? background,
    Color? foreground,
  }) {
    return BGFG(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
    );
  }
}

class AppTheme {
  final int seed;
  final Brightness brightness;
  final ThemeData theme;
  final BGFG appBar;
  final BGFG queueItem;
  final Color appBackground;
  AppTheme({
    required this.seed,
    required this.brightness,
    required this.appBar,
    required this.queueItem,
    required this.appBackground,
  }) : theme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(seed),
            surface: queueItem.background,
            onSurfaceVariant: appBar.foreground,
            surfaceVariant: appBar.background,
            onSurface: queueItem.foreground,
            background: appBackground,
            brightness: brightness,
          ),
        );

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    final brightness = json['brightness'] == "Brightness.dark"
        ? Brightness.dark
        : Brightness.light;

    return AppTheme(
      seed: int.parse(json['seed'], radix: 16),
      brightness: brightness,
      appBar: BGFG.fromJson(json['appBar']),
      queueItem: BGFG.fromJson(json['queueItem']),
      appBackground: Color(int.parse(json['appBackground'], radix: 16)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seed': seed.toRadixString(16),
      'brightness': brightness.toString(),
      'appBar': appBar.toJson(),
      'queueItem': queueItem.toJson(),
      'appBackground': appBackground.value.toRadixString(16),
    };
  }

  // Create a fetch and submit method for the AppTheme
  Future<http.Response> submit(String url) {
    // print(jsonEncode(toJson()));

    return http.post(
      Uri.parse("$url/theme"),
      body: {
        'theme': jsonEncode(toJson()),
      },
    );
  }

  Future<AppTheme> fetch(String url) async {
    final result = await http.get(Uri.parse("$url/theme"));
    if (result.statusCode == 200) {
      return AppTheme.fromJson(
        jsonDecode(result.body),
      );
    }
    throw Exception('Failed to load theme from server');
  }

  AppTheme toggleBrightness() {
    return AppTheme(
      seed: seed,
      brightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      appBar: appBar,
      queueItem: queueItem,
      appBackground: appBackground,
    );
  }

  // create a copyWith method
  AppTheme copyWith({
    int? seed,
    Brightness? brightness,
    BGFG? appBar,
    BGFG? queueItem,
    Color? appBackground,
  }) {
    return AppTheme(
      seed: seed ?? this.seed,
      brightness: brightness ?? theme.brightness,
      appBar: appBar ?? this.appBar,
      queueItem: queueItem ?? this.queueItem,
      appBackground: appBackground ?? this.appBackground,
    );
  }
}

// Crate a AppThemeNotifier for the AppTheme that extends ChangeNotifier
class AppThemeNotifier extends ChangeNotifier {
  AppTheme _theme = defaultAppTheme;
  AppTheme get theme => _theme;
  AppTheme? snapshot;
  int get seed => _theme.seed;

  set theme(AppTheme value) {
    _theme = value;
    notifyListeners();
  }

  set seed(int value) {
    theme = _theme.copyWith(seed: value);
  }

  parse(String value) {
    final maybeSeed = int.tryParse(value, radix: 16);
    if (maybeSeed != null) {
      theme = AppTheme(
        seed: maybeSeed,
        brightness: theme.brightness,
        appBar: theme.appBar,
        queueItem: theme.queueItem,
        appBackground: theme.appBackground,
      );
    }
  }

  static AppThemeNotifier of(BuildContext context, {bool listen = false}) {
    return Provider.of<AppThemeNotifier>(context, listen: listen);
  }

  void snap() {
    snapshot = theme.copyWith();
  }

  void revert() {
    if (snapshot != null) {
      theme = snapshot!;
    }
  }

  Future<void> submit(context) async {
    final url = Provider.of<ServerUrlNotifier>(
      context,
      listen: false,
    ).serverUrl;
    final response = await theme.submit(url);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Theme saved"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save theme"),
        ),
      );
    }
  }

  Future<void> fetch(context) async {
    final url = Provider.of<ServerUrlNotifier>(
      context,
      listen: false,
    ).serverUrl;
    theme = await theme.fetch(url);
  }

  void toggleBrightness() {
    theme = theme.toggleBrightness();
  }
}

class AppThemeEditor extends StatefulWidget {
  final AppThemeNotifier themeNotifier;

  const AppThemeEditor({super.key, required this.themeNotifier});

  @override
  _AppThemeEditorState createState() => _AppThemeEditorState();
}

class _AppThemeEditorState extends State<AppThemeEditor> {
  late TextEditingController _seedController;
  late TextEditingController _appBgController;
  late TextEditingController _appBarFgController;
  late TextEditingController _appBarBgController;
  late TextEditingController _queueItemFgController;
  late TextEditingController _queueItemBgController;

  @override
  void initState() {
    super.initState();
    // sync when ServerUrl changes
    // Provider.of<ServerUrlNotifier>(
    //   context,
    //   listen: false,
    // ).addListener(fetchAndSync);
    sync();
  }

  void sync() {
    final theme = widget.themeNotifier.theme;
    _seedController = TextEditingController(text: theme.seed.toRadixString(16));
    _appBgController = TextEditingController(
        text: theme.appBackground.value.toRadixString(16));
    _appBarFgController = TextEditingController(
        text: theme.appBar.foreground.value.toRadixString(16));
    _appBarBgController = TextEditingController(
        text: theme.appBar.background.value.toRadixString(16));
    _queueItemFgController = TextEditingController(
        text: theme.queueItem.foreground.value.toRadixString(16));
    _queueItemBgController = TextEditingController(
        text: theme.queueItem.background.value.toRadixString(16));
  }

  void fetchAndSync() {
    widget.themeNotifier.fetch(context).then((value) {
      sync();
    });
  }

  @override
  void dispose() {
    _seedController.dispose();
    _appBarFgController.dispose();
    _appBarBgController.dispose();
    _queueItemFgController.dispose();
    _queueItemBgController.dispose();
    _appBgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title("App: "),
        ColorField(
          controller: _appBgController,
          label: "Background Color",
          onChange: (color) {
            widget.themeNotifier.theme =
                widget.themeNotifier.theme.copyWith(appBackground: color);
          },
        ),
        ColorField(
            controller: _seedController,
            label: "Seed color",
            onChange: (color) {
              widget.themeNotifier.seed = color.value;
            }),
        SwitchListTile(
          title: Text('Dark Mode',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              )),
          value: Brightness.dark == widget.themeNotifier.theme.brightness,
          onChanged: (value) {
            widget.themeNotifier.toggleBrightness();
          },
        ),
        title("App Bar: "),
        ColorField(
          controller: _appBarFgController,
          label: "Text Color",
          onChange: (color) {
            widget.themeNotifier.theme = widget.themeNotifier.theme.copyWith(
                appBar: widget.themeNotifier.theme.appBar
                    .copyWith(foreground: color));
          },
        ),
        ColorField(
          controller: _appBarBgController,
          label: "Background Color",
          onChange: (color) {
            widget.themeNotifier.theme = widget.themeNotifier.theme.copyWith(
                appBar: widget.themeNotifier.theme.appBar
                    .copyWith(background: color));
          },
        ),
        title("Queue Item: "),
        ColorField(
          controller: _queueItemFgController,
          label: "Text Color",
          onChange: (color) {
            widget.themeNotifier.theme = widget.themeNotifier.theme.copyWith(
                queueItem: widget.themeNotifier.theme.queueItem
                    .copyWith(foreground: color));
          },
        ),
        ColorField(
          controller: _queueItemBgController,
          label: "Background Color",
          onChange: (color) {
            widget.themeNotifier.theme = widget.themeNotifier.theme.copyWith(
                queueItem: widget.themeNotifier.theme.queueItem
                    .copyWith(background: color));
          },
        ),

        // Add a button to fetch server's theme
        FloatingActionButton.extended(
          onPressed: fetchAndSync,
          label: Text("Sync from Server",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        )
      ],
    );
  }

  Widget title(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
          ),
        ],
      ),
    );
  }
}

typedef ColorChange = void Function(Color color);

class ColorField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ColorChange onChange;
  const ColorField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        decoration: InputDecoration(
          icon: Icon(
            Icons.square,
            color: Color(
              int.parse(controller.text, radix: 16),
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
          focusColor: Theme.of(context).colorScheme.surfaceVariant,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          onChange(Color(
            int.parse(value, radix: 16),
          ));
        },
      ),
    );
  }
}

class ThemeSwitcherScreen extends StatelessWidget {
  const ThemeSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        title: const Text('Theme Switcher'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(
          Icons.save,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          Provider.of<AppThemeNotifier>(context, listen: false).submit(context);
        },
        label: Text(
          "Save",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: Center(
        child: AppThemeEditor(
          themeNotifier: Provider.of<AppThemeNotifier>(context),
        ),
      ),
    );
  }
}
