import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/server_url_widget.dart';
import 'package:shared/theme_switcher_screen.dart';

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
            _Item(child: ServerUrlWidget()),
            SizedBox(height: 50.0),
            _Item(
              child: Text(
                "Manual",
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(height: 50.0),
            _Item(
              child: TextButton(
                onPressed: () {
                  Provider.of<AppThemeNotifier>(context, listen: false)
                      .fetch(context);
                },
                child: Text(
                  "Sync App Theme",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
            SizedBox(height: 50.0),
            _Item(
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

class _Item extends StatelessWidget {
  final Widget child;

  const _Item({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 250,
      child: Card(
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
