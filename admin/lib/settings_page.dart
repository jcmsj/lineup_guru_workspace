import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/snack.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/settings_item.dart';
import 'package:shared/theme/editor.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onBackground,
          indicatorColor: Theme.of(context).colorScheme.onBackground,
          unselectedLabelColor: Theme.of(context).colorScheme.onBackground,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Theme Editor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SettingsItem(
                //   child: Text(
                //     "Manual",
                //     style: TextStyle(fontSize: 25),
                //   ),
                // ),
                // VertSpace(),
                SettingsItem(
                  child: Text(
                    "About Us",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ],
            ),
          ),
          ThemeSwitcherScreen(),
        ],
      ),
    );
  }
}

class ServerField extends StatefulWidget {
  final String url;

  const ServerField({
    super.key,
    required this.url,
  });

  @override
  State<ServerField> createState() => _ServerFieldState();
}

class _ServerFieldState extends State<ServerField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.text = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A text field with a Outline indicator using the Surface colors and the label "Server URL"
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Server URL",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Surface.bg(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: SurfaceVariant.fg(context),
                ),
              ),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  // Set controller text back to the url
                  controller.text = widget.url;
                },
                child: Text(
                  "Reset",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: SurfaceVariant.bg(context),
                ),
                onPressed: () async {
                  if (controller.text == widget.url) {
                    return;
                  }
                  // Set the url to the controller text
                  Provider.of<ServerUrlNotifier>(context, listen: false)
                      .tryCandidate(controller.text)
                      .onError((error, stackTrace) =>
                          snackErr(context, 'Error: $error'))
                      .then((_) => {
                            snack(context, 'Success!'),
                          });
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: SurfaceVariant.fg(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
