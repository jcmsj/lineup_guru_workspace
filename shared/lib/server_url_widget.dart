import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/save_fab.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/themed_bar.dart';

import 'server_url_notifier.dart';

class ServerUrlScreen extends StatefulWidget {
  const ServerUrlScreen({super.key});

  @override
  State<ServerUrlScreen> createState() => _ServerUrlScreenState();
}

class _ServerUrlScreenState extends State<ServerUrlScreen> {
  final textFieldCtl = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree
    textFieldCtl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    textFieldCtl.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    textFieldCtl.text = Provider.of<ServerUrlNotifier>(
      context,
      listen: false, // Be sure to listen
    ).serverUrl;
    super.didChangeDependencies();
  }

  void syncToServer() {
    Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl =
        textFieldCtl.text;
    Navigator.pop(context);
  }

  Widget? showSaveFABOrNull(String serverUrl) {
    if (serverUrl != textFieldCtl.text) {
      return SaveFAB(onPressed: syncToServer);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServerUrlNotifier>(builder: (context, model, child) {
      return Scaffold(
        appBar: ThemedBar(
          context: context,
          title: const Text('Server Url'),
        ),
        // If the server url does not match the controller text, then show SaveFAB
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 3/4 of screen width
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                // TextField with outline that is styled to use the theme's colors
                child: TextField(
                  controller: textFieldCtl,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SurfaceVariant.bg(context),
                      ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Server Url',
                    hoverColor: SurfaceVariant.bg(context),
                    labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: SurfaceVariant.bg(context),
                        ),
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: textFieldCtl.text == model.serverUrl
                    ? []
                    : [
                        TextButton.icon(
                          icon: const Icon(Icons.restore),
                          onPressed: () {
                            textFieldCtl.text = model.serverUrl;
                          },
                          label: const Text("Reset"),
                        ),
                        TextButton.icon(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                SurfaceVariant.fg(context)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                SurfaceVariant.bg(context)),
                          ),
                          icon: const Icon(Icons.save),
                          onPressed: syncToServer,
                          label: const Text("Save"),
                        ),
                      ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
