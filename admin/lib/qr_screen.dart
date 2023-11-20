import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/queue/shop_queue.dart';
import 'package:shared/server_url_widget.dart';
import 'package:shared/snack.dart';
import 'package:shared/theme/app_theme.dart';

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract the shopQueue
    // see https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
    final shopQueue = ModalRoute.of(context)!.settings.arguments as ShopQueue;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: shopQueue.name,
            version: QrVersions.auto,
            // Use 1/2 of screen width as the size
            size: MediaQuery.of(context).size.width * 0.5,
          ),
          const SizedBox(height: 20.0),
          Text(
            shopQueue.name,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class QRServerScreen extends StatelessWidget {
  const QRServerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract the shopQueue
    // see https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
    return Scaffold(
      body: Center(
        child: Consumer(builder: (
          context,
          ServerUrlNotifier model,
          child,
        ) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data: model.serverUrl,
                version: QrVersions.auto,
                // Use 3/4 of screen width as the size
                size: MediaQuery.of(context).size.width * 0.5,
              ),
              const SizedBox(height: 20.0),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  // Add a copy button and edit dialog
                  CopyBtn(url: model.serverUrl),
                  // add a button with an edit icon, on pressed show a dialog of ServerDialog
                  IconButton(
                    icon: const Icon(Icons.edit),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          SurfaceVariant.bg(context)),
                    ),
                    onPressed: () async {
                      // Show the dialog
                      await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            ServerDialog(url: model.serverUrl),
                      ).then((value) =>
                          value != null &&
                          ServerDialog.onChange(context, value));
                    },
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class CopyBtn extends StatelessWidget {
  final String url;

  const CopyBtn({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text(url),
      style: ButtonStyle(
        foregroundColor:
            MaterialStateProperty.all<Color>(SurfaceVariant.fg(context)),
        backgroundColor:
            MaterialStateProperty.all<Color>(SurfaceVariant.bg(context)),
      ),
      icon: const Icon(Icons.copy),
      onPressed: () {
        // Copy to clipboard
        Clipboard.setData(
          ClipboardData(text: url),
        );
        // Show a snackbar
        snack(context, 'Copied to Clipboard');
      },
    );
  }
}
