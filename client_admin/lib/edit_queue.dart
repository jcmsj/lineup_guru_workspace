import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared/queue/notifier.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/service_card.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/save_fab.dart';
import 'package:url_launcher/url_launcher.dart';

class EditQueueScreen extends StatefulWidget {
  const EditQueueScreen({super.key});

  @override
  _EditQueueScreenState createState() => _EditQueueScreenState();
}

class _EditQueueScreenState extends State<EditQueueScreen> {
  final _queueNameController = TextEditingController();
  final Uri iconLibrary = Uri.parse(
      'https://api.flutter.dev/flutter/material/Icons-class.html#constants');
  final _iconNameController =
      TextEditingController(); // added icon name controller
  int _queueCurrent = 0;

  @override
  void initState() {
    super.initState();
    // set the queue name and current number from the queueNotifier
    final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);
    // TODO: Prevent navigating here if queue is null
    if (queueNotifier.queue == null) {
      return;
    }

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Queue has been updated',
          style: TextStyle(color: Surface.fg(context)),
        ),
        backgroundColor: Surface.bg(context),
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QueueNotifier, ServerUrlNotifier>(
      builder: (BuildContext context, QueueNotifier model,
          ServerUrlNotifier server, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Queue'),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          floatingActionButton: saveBtn(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                text("Queue name:"),
                inputQueueName(),
                space(),
                text("Icon name:"), // add the icon name text field
                inputIconName(),
                space(),
                seeAvailable(),
                text("Preview:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      // height & width is 1/5 of shortest side
                      height: MediaQuery.of(context).size.shortestSide * 0.4,
                      width: MediaQuery.of(context).size.shortestSide * 0.4,
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
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    deleteBtn(model, server, context),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  TextButton deleteBtn(
    QueueNotifier model,
    ServerUrlNotifier server,
    BuildContext context,
  ) {
    return TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                title: Text("Confirm Delete",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
                content: Text(
                  "Are you sure you want to delete this queue '${model.queue!.name}'?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
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
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ))
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
          launchUrl(iconLibrary);
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$_queueCurrent',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
              ),
            ),
          ),
        ),
        nextNumberBtn(context),
      ],
    );
  }

  // add the inputIconName method
  TextField inputIconName() {
    return TextField(
      controller: _iconNameController,
      decoration: const InputDecoration(
        hintText: 'Enter icon name',
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
      ),
      onChanged: forceRebuild,
    );
  }

  ElevatedButton previousNumberBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _queueCurrent--;
        });
      },
      child: Icon(
        Icons.remove,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  ElevatedButton nextNumberBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _queueCurrent++;
        });
      },
      child: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  TextField inputQueueName() {
    return TextField(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
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
        return const Text("");
      }

      return SaveFAB(onPressed: updateQueue);
    });
  }
}

class ShowQR extends StatelessWidget {
  const ShowQR({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueNotifier>(builder: (context, model, child) {
      return TextButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/qr',
            arguments: model.queue,
          );
        },
        icon: const Icon(
          Icons.qr_code_outlined,
        ),
        label: const Text(
          "Show QR",
        ),
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary),
      );
    });
  }
}
