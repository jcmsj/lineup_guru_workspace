import 'package:flutter/material.dart';
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
              Text(
                model.serverUrl,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Surface.bg(context),
                    ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
