import 'package:flutter/material.dart';
import 'package:shared/server_url_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Item(
              child: ListTile(
                leading: Icon(
                  Icons.brush_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: const Text("App Theme"),
                onTap: () {
                  Navigator.pushNamed(context, "/theme-editor");
                },
              ),
            ),
            const SizedBox(height: 50.0),
            const _Item(
              child: Text(
                "Manual",
                style: TextStyle(fontSize: 25),
              ),
            ),
            const SizedBox(height: 50.0),
            const _Item(child: ServerUrlWidget()),
            const SizedBox(height: 50.0),
            const _Item(
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
