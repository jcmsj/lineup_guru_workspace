import 'package:flutter/material.dart';
import 'package:shared/server_url_widget.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/settings_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SettingsItem(
              child: ListTile(
                leading: Icon(
                  Icons.brush_outlined,
                  color: Surface.fg(context),
                ),
                title: const Text(
                  "App Theme",
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.pushNamed(context, "/theme-editor");
                },
              ),
            ),
            const VertSpace(),
            const SettingsItem(
              child: Text(
                "Manual",
                style: TextStyle(fontSize: 25),
              ),
            ),
            const VertSpace(),
            const SettingsItem(
              child: ServerDialogOpener(),
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
