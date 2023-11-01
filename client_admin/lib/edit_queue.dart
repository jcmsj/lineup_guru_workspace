import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'second_route.dart';
import 'server_url_widget.dart';

class EditQueueScreen extends StatefulWidget {
  const EditQueueScreen({super.key});

  @override
  _EditQueueScreenState createState() => _EditQueueScreenState();
}

class _EditQueueScreenState extends State<EditQueueScreen> {
  final _queueNameController = TextEditingController();
  final _iconNameController =
      TextEditingController(); // added icon name controller
  int _queueCurrent = 0;

  @override
  void initState() {
    super.initState();
    // set the queue name and current number from the queueNotifier
    final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);
    _queueNameController.text = queueNotifier.queue!.name;
    _iconNameController.text =
        queueNotifier.queue!.iconName; // set the icon name controller
    _queueCurrent = queueNotifier.queue!.current;
  }

  // Create a updateQueue method
  Future<void> updateQueue() async {
    final newName = _queueNameController.text;
    final newIconName = _iconNameController.text; // get the new icon name
    final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);
    final serverUrl =
        Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl;
    final response = await http.post(
      Uri.parse('$serverUrl/update/${queueNotifier.queue!.id}'),
      body: {
        'name': newName,
        'current': _queueCurrent.toString(),
        'icon': newIconName, // add the new icon name to the request body
        'last_position': queueNotifier.queue!.lastPosition.toString(),
        'created_at': queueNotifier.queue!.createdAt.toString(),
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      showSavedToast();
    }
  }

  void showSavedToast() {
    Fluttertoast.showToast(
        msg: "Queue has been updated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QueueNotifier, ServerUrlNotifier>(
      builder: (BuildContext context, QueueNotifier model,
          ServerUrlNotifier server, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Queue'),
          ),
          floatingActionButton: saveBtn(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text("Queue name:"),
                inputQueueName(),
                space(),
                text("Icon name:"), // add the icon name text field
                inputIconName(),
                seeAvailable(),
                text("Preview:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 175,
                      child: Expanded(
                        child: ServiceCard(
                          _queueNameController.text,
                          _iconNameController.text,
                        ),
                      ),
                    ),
                  ],
                ),
                space(),
                text('Current queue number:'),
                space(),
                positionControls(context),
                space(),
                deleteBtn(model, server, context),
              ],
            ),
          ),
        );
      },
    );
  }

  TextButton deleteBtn(
      QueueNotifier model, ServerUrlNotifier server, BuildContext context) {
    return TextButton.icon(
        onPressed: () {
          if (model.queue == null) {
            return;
          }
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Delete"),
                content: Text(
                    "Are you sure you want to delete this queue '${model.queue!.name}'?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    // emphasize the cancel button
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                      // style: TextButton.styleFrom(
                      //   foregroundColor: Theme.of(context).colorScheme.error,
                      //   backgroundColor:
                      //       Theme.of(context).colorScheme.errorContainer,
                      // ),
                      onPressed: () {
                        http
                            .delete(Uri.parse(
                                '${server.serverUrl}/queue/${model.queue!.id}'))
                            .then(
                          (response) {
                            // remove the dialog and editor screen
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        );
                      },
                      child: const Text("Delete"))
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.delete_forever_outlined),
        label: const Text("Delete Queue"),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ));
  }

  TextButton seeAvailable() {
    return TextButton.icon(
        onPressed: () {
          final Uri _url = Uri.parse(
              'https://api.flutter.dev/flutter/material/Icons-class.html#constants');
          launchUrl(_url);
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text("See available icons here"));
  }

  Text text(String data) {
    return Text(
      data,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }

  SizedBox space() {
    return const SizedBox(height: 16);
  }

  Row positionControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        previousNumberBtn(context),
        Text(
          '$_queueCurrent',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: Theme.of(context).cardColor,
              ),
        ),
        nextNumberBtn(context),
      ],
    );
  }

  // add the inputIconName method
  TextField inputIconName() {
    return TextField(
        style: const TextStyle(color: Colors.black),
        controller: _iconNameController,
        decoration: const InputDecoration(
          hintText: 'Enter icon name',
        ),
        onChanged: forceRebuild);
  }

  ElevatedButton previousNumberBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _queueCurrent--;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor),
      child: const Icon(Icons.remove),
    );
  }

  ElevatedButton nextNumberBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _queueCurrent++;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor),
      child: const Icon(Icons.add),
    );
  }

  TextField inputQueueName() {
    return TextField(
        style: const TextStyle(color: Colors.black),
        controller: _queueNameController,
        decoration: const InputDecoration(
          hintText: 'Enter queue name',
        ),
        onChanged: forceRebuild);
  }

  // Used to update the screen since TextFields with controllers dont rebuild
  void forceRebuild(String _) {
    setState(() {});
  }

  Consumer<QueueNotifier> saveBtn() {
    return Consumer(builder: (context, QueueNotifier model, child) {
      if (_queueNameController.text == model.queue?.name &&
          _iconNameController.text == model.queue?.iconName &&
          _queueCurrent == model.queue?.current) {
        return const Text('');
      }

      return FloatingActionButton.extended(
        onPressed: updateQueue,
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      );
    });
  }
}
