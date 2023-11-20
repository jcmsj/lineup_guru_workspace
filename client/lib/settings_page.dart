import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/server_url_widget.dart';
import 'package:shared/theme/notifier.dart';
import 'package:shared/settings_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    AppThemeNotifier.of(context).fetch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SettingsItem(
              child: ServerDialogOpener(),
            ),
            const VertSpace(),
            const SettingsItem(
              child: Text(
                "Manual",
                style: TextStyle(fontSize: 25),
              ),
            ),
            const VertSpace(),
            GestureDetector(
              onTap: () => {
                Provider.of<AppThemeNotifier>(context, listen: false)
                    .fetch(context)
              },
              child: SettingsItem(
                child: Text(
                  "Sync App Theme",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
            const VertSpace(),
            const SettingsItem(
              child: Text(
                "About Us",
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
