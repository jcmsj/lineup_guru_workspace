import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/queue/shop_queue.dart';
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
              Card(
                color: SurfaceVariant.bg(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    label: Text(model.serverUrl),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          SurfaceVariant.fg(context)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          SurfaceVariant.bg(context)),
                    ),
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Copy to clipboard
                      Clipboard.setData(
                        ClipboardData(text: model.serverUrl),
                      );
                      // Show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          showCloseIcon: true,
                          backgroundColor: Surface.bg(context),
                          closeIconColor: Surface.fg(context),
                          content: Text('Copied to Clipboard',
                              style: TextStyle(
                                color: Surface.fg(context),
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
