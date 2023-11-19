import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class Surface {
  static Color bg(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color fg(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}

class SurfaceVariant {
  static Color bg(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceVariant;
  }

  static Color fg(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

Color hexStringToColor(String hexString) {
  return Color(int.parse(hexString, radix: 16));
}

class BGFG {
  final Color background;
  final Color foreground;

  BGFG({required this.background, required this.foreground});

  factory BGFG.fromJson(Map<String, dynamic> json) {
    return BGFG(
      background: hexStringToColor(json['background']),
      foreground: hexStringToColor(json['foreground']),
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
      appBackground: hexStringToColor(json['appBackground']),
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
      try {
        return AppTheme.fromJson(
          jsonDecode(result.body),
        );
      } catch (e) {
        return defaultAppTheme;
      }
    }
    throw Exception('Failed to load theme from server');
  }

  AppTheme toggleBrightness() {
    return copyWith(
      brightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
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
