import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/About.dart';
import 'package:shared/custom_app_bar.dart';
import 'package:shared/server_url_widget.dart';
import 'package:shared/snack.dart';
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
            GestureDetector(
              onTap: () => {
                Provider.of<AppThemeNotifier>(context, listen: false)
                    .fetch(context)
                    .then(
                  (value) {
                    snack(context, "Success: Theme Synced to Server");
                  },
                )
              },
              child: SettingsItem(
                child: Text(
                  "Sync App Theme",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
            const VertSpace(),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                            appBar: CustomAppBar(
                              // 1/10 of screen height
                              height: MediaQuery.of(context).size.height / 10,
                              title: "Line-Up Guru",
                            ),
                            body: const AboutPage(),
                          )),
                )
              },
              child: SettingsItem(
                child: Text("About The App",
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
