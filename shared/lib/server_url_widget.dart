import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/theme/app_theme.dart';

class ServerDialog extends StatefulWidget {
  final String url;
  const ServerDialog({
    super.key,
    required this.url,
  });

  @override
  State<ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<ServerDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.text = widget.url;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SurfaceVariant.bg(context),
      title: Text(
        "Server URL",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: SurfaceVariant.fg(context),
        ),
      ),
      content: TextField(
        controller: controller,
        style: TextStyle(
          color: SurfaceVariant.fg(context),
        ),
      ),
      actions: [
        // add a cancel button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: SurfaceVariant.fg(context),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: Text(
            "Save",
            style: TextStyle(
              color: SurfaceVariant.fg(context),
            ),
          ),
        ),
      ],
    );
  }
}

// Create
class ServerDialogOpener extends StatelessWidget {
  const ServerDialogOpener({super.key});

  void snackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SurfaceVariant.bg(context),
        showCloseIcon: true,
        content: Text(
          "Invalid URL",
          style: TextStyle(
            color: SurfaceVariant.fg(context),
          ),
        ),
      ),
    );
  }

  void tryCandidateOrErrorSnackbar(
    BuildContext context,
    String? candidate,
  ) {
    if (candidate != null) {
      print(candidate);
      Provider.of<ServerUrlNotifier>(context, listen: false)
          .tryCandidate(candidate)
          .onError((error, stackTrace) => snackbar(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.cloud,
        color: Surface.fg(context),
      ),
      title: const Text(
        "Server URL",
        textAlign: TextAlign.center,
      ),
      onTap: () {
        // Create a dialog that uses the SurfaceVariant's bg and fg for the user to enter the server URL, set the default value as the current url
        final serverNotifier =
            Provider.of<ServerUrlNotifier>(context, listen: false);
        showDialog(
          context: context,
          builder: (context) {
            return ServerDialog(url: serverNotifier.serverUrl);
          },
        ).then((candidate) => tryCandidateOrErrorSnackbar(context, candidate));
      },
    );
  }
}
