import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'queue_list.dart';
import 'second_route.dart';
import 'server_url_widget.dart';

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
            Provider.of<QueueNotifier>(context, listen: false).setQueue(queue);
            Navigator.pushNamed(context, "/editor");
          });
        });
      },
      backgroundColor: const Color.fromARGB(255, 255, 189, 89),
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
  print(response.body);
  return response.statusCode == 200;
}
