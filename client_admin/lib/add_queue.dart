import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared/queue_list.dart';
import 'package:shared/queue_notifier.dart';
import 'package:shared/server_url_notifier.dart';

class AddQueueBtn extends StatelessWidget {
  const AddQueueBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final serverUrl =
            Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl;
        const name = 'Untitled';
        addUntitledQueue(serverUrl, name).then((success) {
          if (!success) {
            return;
          }
          fetchQueue(serverUrl, name).then((queue) {
            Provider.of<QueueNotifier>(context, listen: false).queue = queue;
            Navigator.pushNamed(context, "/editor");
          });
        });
      },
      child: const Icon(Icons.add),
    );
  }
}

Future<bool> addUntitledQueue(String url, String name) async {
  final response = await http.post(
    Uri.parse('$url/create'),
    body: {
      'name': name,
    },
  );
  log("Queue creation response: ${response.body}");
  return response.statusCode == 200;
}
