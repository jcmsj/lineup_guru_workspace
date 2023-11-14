import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/server_url_notifier.dart';
import 'app_theme.dart';

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

  void parse(String value) {
    final maybeSeed = int.tryParse(value, radix: 16);
    if (maybeSeed != null) {
      theme = theme.copyWith(seed: maybeSeed);
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
