import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'server_url_notifier.dart';

class ServerUrlWidget extends StatefulWidget {
  const ServerUrlWidget({super.key});

  @override
  State<ServerUrlWidget> createState() => _ServerUrlState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _ServerUrlState extends State<ServerUrlWidget> {
  // Create a text controller. Later, use it to retrieve the
  // current value of the TextField.
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

    // Start listening to changes.
    textFieldCtl.addListener(syncNotifier);
  }

  void syncNotifier() {
    Provider.of<ServerUrlNotifier>(
      context,
      listen: false, // No need to listen
    ).serverUrl = textFieldCtl.text;
  }

  @override
  void didChangeDependencies() {
    textFieldCtl.text = Provider.of<ServerUrlNotifier>(
      context,
      listen: false, // Be sure to listen
    ).serverUrl;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textFieldCtl,
      style: const TextStyle(fontSize: 12),
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
          floatingLabelAlignment: FloatingLabelAlignment.center,
          hintText: 'Enter server Url'),
    );
  }
}
