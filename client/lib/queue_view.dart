import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/queue/notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/settings_item.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/themed_bar.dart';

class JoinOrQRFab extends StatefulWidget {
  const JoinOrQRFab({super.key});

  @override
  State<JoinOrQRFab> createState() => _JoinOrQRFabState();
}

class _JoinOrQRFabState extends State<JoinOrQRFab> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<QueueNotifier, ServerUrlNotifier>(
        builder: (context, queueNotifier, serverUrlNotifier, child) {
      if (queueNotifier.queue == null) {
        return const CircularProgressIndicator();
      } else if (queueNotifier.myNumber > 0) {
        if (queueNotifier.activeQueueId != queueNotifier.queue?.id) {
          return FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: SurfaceVariant.bg(context),
            label: Text(
              "You are in a different queue",
              style: TextStyle(
                color: SurfaceVariant.fg(context),
              ),
            ),
            icon: Icon(Icons.warning, color: SurfaceVariant.fg(context)),
          );
        } else {
          return const Text("");
        }
      }

      return FloatingActionButton.extended(
          disabledElevation: 0,
          onPressed: () async {
            queueNotifier.myNumber = await joinQueue(
              queueNotifier.queue!,
              serverUrlNotifier.serverUrl,
            );
            queueNotifier.queue = await pollQueue(
              serverUrlNotifier.serverUrl,
              queueNotifier.queue!.name,
            );
          },
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          label: Text(
            "Join Queue",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          icon: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ));
    });
  }
}

// Create a State class that contains the ShopQueue field
// class _SecondRouteState extends State<SecondRoute> {
class QueueView extends StatefulWidget {
  const QueueView({super.key});

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  // Poll server for latest queue every 2 seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      log("polling queue");
      final qn = Provider.of<QueueNotifier>(context, listen: false);
      qn.queue = await pollQueue(
          Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl,
          qn.queue!.name);
    });
  }

  @override // CANCAEL THE TIMER!!
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QueueNotifier, ServerUrlNotifier>(
        builder: (context, queueNotifier, serverUrlNotifier, child) {
      return Scaffold(
        appBar: ThemedBar(
          context: context,
          title: const Text("Queue  Details"),
        ),
        floatingActionButton: const JoinOrQRFab(),
        body: Center(
          child: Column(
            children: [
              PageTitleWidget(title: "Queue: ${queueNotifier.queue?.name}"),
              const VertSpace(),
              currentlyServing(queueNotifier),
              const VertSpace(),
              lastNumber(queueNotifier),
              const VertSpace(),
              queueNotifier.activeQueueId == queueNotifier.queue?.id
                  ? customerStatus(queueNotifier)
                  : const Text(""),
            ],
          ),
        ),
      );
    });
  }

  Card currentlyServing(QueueNotifier queueNotifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              "Currently Serving:",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "# ${queueNotifier.queue?.current}",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Card customerStatus(QueueNotifier queueNotifier) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text("Status:"),
              queueNotifier.myNumber < 0
                  ? const Text("Not in queue", style: TextStyle(fontSize: 20))
                  : Text(
                      "You are # ${queueNotifier.myNumber}",
                      style: const TextStyle(fontSize: 20),
                    ),
            ],
          )),
    );
  }

  Card lastNumber(QueueNotifier queueNotifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text("Last Number in Queue:", style: TextStyle(fontSize: 20)),
            Text(
              "# ${queueNotifier.queue?.lastPosition}",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
