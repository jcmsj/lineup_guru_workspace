import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/save_fab.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/themed_bar.dart';
import 'notifier.dart';
import 'color_field.dart';

// Crate a AppThemeNotifier for the AppTheme that extends ChangeNotifier

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
    return ListView(
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
                color: Theme.of(context).colorScheme.inverseSurface,
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
        ButtonBar(alignment: MainAxisAlignment.center, children: [
          TextButton.icon(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    SurfaceVariant.fg(context)),
                backgroundColor: MaterialStateProperty.all<Color>(
                    SurfaceVariant.bg(context)),
              ),
              icon: const Icon(
                Icons.cloud_download,
              ),
              onPressed: fetchAndSync,
              label: const Text(
                "Sync from Server",
              )),
        ])
      ],
    );
  }

  Widget title(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
      ),
    );
  }
}

class ThemeSwitcherScreen extends StatelessWidget {
  const ThemeSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedBar(
        context: context,
        title: const Text('Theme Switcher'),
      ),
      floatingActionButton: SaveFAB(
        onPressed: () {
          Provider.of<AppThemeNotifier>(context, listen: false).submit(context);
        },
      ),
      body: AppThemeEditor(
        themeNotifier: Provider.of<AppThemeNotifier>(context),
      ),
    );
  }
}
