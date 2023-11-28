import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared/queue/notifier.dart';
import '../service_card.dart';
import '/theme/app_theme.dart';
import 'shop_queue.dart';

// ignore: non_constant_identifier_names
Future<List<ShopQueue>> fetchQueues(String url) async {
  final response = await http.get(Uri.parse('$url/queue'));
  if (response.statusCode == 200) {
    // Do something with the response body
    return jsonDecode(response.body)
        .map((data) => ShopQueue.fromJson(data))
        .toList()
        .cast<ShopQueue>();
  } else {
    throw Exception('Failed to fetch queue');
  }
}

Future<ShopQueue> fetchQueue(String url, String queueName) async {
  final response = await http.get(Uri.parse('$url/queue/$queueName'));
  if (response.statusCode == 200) {
    // Do something with the response body
    return ShopQueue.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch queue');
  }
}

typedef QueueWidgetBuilder = Widget Function(ShopQueue queue);

class QueueBuilder extends StatelessWidget {
  final QueueWidgetBuilder builder;
  const QueueBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<QueueListNotifier>(
        builder: (context, model, child) {
          return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // If the height is <= width then make cross axis count 4 else 2
                crossAxisCount: MediaQuery.of(context).size.height <=
                        MediaQuery.of(context).size.width
                    ? 4
                    : 2,

                // main axis spacing 1/10 of screenw idth
                mainAxisSpacing: MediaQuery.of(context).size.width * 0.05,
                crossAxisSpacing: MediaQuery.of(context).size.width * 0.05,
              ),
              itemCount: model.queues.length,
              itemBuilder: (BuildContext context, int index) {
                return builder(model.queues[index]);
              });
        },
      ),
    );
  }
}

class LoadingQueueWidget extends StatelessWidget {
  const LoadingQueueWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          strokeWidth: 8.0,
          color: SurfaceVariant.fg(context),
        ),
        // Add a sized box that is 1/8 of the screen height
        SizedBox(height: MediaQuery.of(context).size.height * 0.125),
        Text(
          'Loading Queues...',
          style: TextStyle(
            color: SurfaceVariant.fg(context),
          ),
        ),
      ],
    );
  }
}

class QueueItem extends StatelessWidget {
  final void Function() onTap;

  const QueueItem({
    super.key,
    required this.data,
    required this.onTap,
  });
  final ShopQueue data;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ServiceCard(
        data.name,
        data.iconName,
      ),
    );
  }
}
