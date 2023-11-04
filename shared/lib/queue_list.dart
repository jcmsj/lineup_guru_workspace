import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'server_url_notifier.dart';
import 'shop_queue.dart';

// ignore: non_constant_identifier_names
Future<List<ShopQueue>> fetchQueues(String url) async {
  final response = await http.get(Uri.parse('$url/queue'));
  print(response.body);
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

class QueueBuilder extends StatefulWidget {
  final QueueWidgetBuilder builder;
  const QueueBuilder({super.key, required this.builder});

  @override
  State<StatefulWidget> createState() {
    return _QueueBuilderState();
  }
}

class _QueueBuilderState extends State<QueueBuilder> {
  Future<List<ShopQueue>> _future = Future.value([]);
  late Timer timer;
  @override
  void initState() {
    super.initState();
    getQueues();
    setUpTimedFetch();
  }

  setUpTimedFetch() {
    timer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      getQueues();
    });
  }

  void getQueues() {
    setState(() {
      _future = fetchQueues(
        Provider.of<ServerUrlNotifier>(
          context,
          listen: false,
        ).serverUrl,
      );
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ShopQueue>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ShopQueue>? data = snapshot.data;
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 40,
                  crossAxisSpacing: 0,
                ),
                itemCount: data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return widget.builder(data[index]);
                });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const LoadingQueueWidget();
        });
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
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 25),
        Text(
          'Loading Queues...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
