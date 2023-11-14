import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../service_card.dart';
import '/theme/app_theme.dart';
import '/server_url_notifier.dart';
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
  final int intervalMs = 3000;
  @override
  void initState() {
    super.initState();
    getQueues();
    setUpTimedFetch();
  }

  setUpTimedFetch() {
    timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<List<ShopQueue>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<ShopQueue>? data = snapshot.data;
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
                  itemCount: data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return widget.builder(data[index]);
                  });
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const LoadingQueueWidget();
          }),
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
