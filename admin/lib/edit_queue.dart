import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared/queue/notifier.dart';
import 'package:shared/queue/shop_queue.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/service_card.dart';
import 'package:shared/settings_item.dart';
import 'package:shared/snack.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/save_fab.dart';
import 'package:shared/theme/themed_bar.dart';
import 'package:flutter/services.dart';

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
  bool isMultiJoin = false;
  @override
  void initState() {
    super.initState();
    // set the queue name and current number from the queueNotifier
    final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);

    if (queueNotifier.queue == null) {
      return;
    }

    _queueNameController.text = queueNotifier.queue!.name;
    _iconNameController.text =
        queueNotifier.queue!.iconName; // set the icon name controller
    _queueCurrent = queueNotifier.queue!.current;
    isMultiJoin = queueNotifier.queue!.isMultiJoin;
    // Every second, poll for the latest queue position
    Future.doWhile(() async {
      if (!mounted) {
        return false;
      }
      final serverUrl =
          Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl;
      final response = await http
          .get(Uri.parse('$serverUrl/queue/${queueNotifier.queue!.name}'));
      if (response.statusCode == 200) {
        final queue = ShopQueue.fromJson(jsonDecode(response.body));
        queueNotifier.queue = queueNotifier.queue?.copyWith(
          lastPosition: queue.lastPosition,
        );
        setState(() {});
      }
      await Future.delayed(const Duration(seconds: 1));
      return true;
    });
  }

  @override
  void activate() {
    final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);
    _queueNameController.text = queueNotifier.queue!.name;
    _iconNameController.text = queueNotifier.queue!.iconName;
    _queueCurrent = queueNotifier.queue!.current;
    didChangeDependencies();
    super.activate();
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
        'multi_join_on': isMultiJoin ? '1' : '0',
      },
    );
    if (response.statusCode == 200) {
      queueNotifier.queue = queueNotifier.queue?.copyWith(
        name: newName,
        iconName: newIconName, // update the icon name
        current: _queueCurrent,
        isMultiJoin: isMultiJoin,
      );
      showSavedToast();
    }
  }

  void showSavedToast() {
    snack(context, "Queue updated");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedBar(
        context: context,
        title: const Text("Edit Queue"),
        actions: const [
          DeleteQueueBtn(),
        ],
      ),
      floatingActionButton: saveBtn(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            text("Queue name:"),
            inputQueueName(),
            const VertSpace(),
            text("Icon name:"), // add the icon name text field
            inputIconName(),
            const VertSpace(),
            copyUrlBtn(),
            const VertSpace(),
            text("Preview:"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  // height & width is 1/5 of shortest side
                  height: MediaQuery.of(context).size.shortestSide * 0.4,
                  width: MediaQuery.of(context).size.shortestSide * 0.4,
                  child: ServiceCard(
                    _queueNameController.text,
                    _iconNameController.text,
                  ),
                ),
              ],
            ),
            const VertSpace(),
            text('Current queue number:'),
            const VertSpace(),
            positionControls(context),
            const VertSpace(),
            text('Last number served:'),
            lastServed(context),
            const VertSpace(),
            SwitchListTile(
              value: isMultiJoin,
              // activeColor: SurfaceVariant.bg(context),
              // inactiveTrackColor: SurfaceVariant.fg(context),
              onChanged: (val) {
                setState(() {
                  isMultiJoin = val;
                });
              },
              title: Text(
                "Allow multiple joins",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextButton copyUrlBtn() {
    return TextButton.icon(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: iconLibrary.toString()));
          snack(context, 'Copied to Clipboard');
        },
        icon: const Icon(Icons.copy),
        label: const Text("See icons by visiting this URL"));
  }

  Text text(String data) {
    return Text(
      data,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );
  }

  Row lastServed(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<QueueNotifier>(builder: (context, model, child) {
              return Text(
                '${model.queue?.lastPosition}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              );
            }),
          ),
        ),
      ],
    );
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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
          _queueCurrent == model.queue?.current &&
          isMultiJoin == model.queue?.isMultiJoin) {
        return const Text("");
      }

      return SaveFAB(onPressed: updateQueue);
    });
  }
}

class DeleteQueueBtn extends StatefulWidget {
  const DeleteQueueBtn({
    super.key,
  });

  @override
  State<DeleteQueueBtn> createState() => _DeleteQueueBtnState();
}

class _DeleteQueueBtnState extends State<DeleteQueueBtn> {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DeleteQueueDialog();
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
}

class DeleteQueueDialog extends StatelessWidget {
  const DeleteQueueDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SurfaceVariant.bg(context),
      title: Text("Confirm Delete",
          style: TextStyle(
            color: SurfaceVariant.fg(context),
          )),
      content: Consumer<QueueNotifier>(builder: (context, model, child) {
        return Text(
          "Are you sure you want to delete this queue '${model.queue!.name}'?",
          style: TextStyle(
            color: SurfaceVariant.fg(context),
          ),
        );
      }),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          // emphasize the cancel button
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final serverUrl =
                Provider.of<ServerUrlNotifier>(context, listen: false)
                    .serverUrl;
            final queue =
                Provider.of<QueueNotifier>(context, listen: false).queue;
            http.delete(Uri.parse('$serverUrl/queue/${queue!.id}')).then(
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
              color: SurfaceVariant.fg(context),
            ),
          ),
        )
      ],
    );
  }
}
