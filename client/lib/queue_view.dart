import 'package:flutter/material.dart';
import 'package:shared/custom_app_bar.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/queue/notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared/queue/shop_queue.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/settings_item.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/themed_bar.dart';

class JoinOrQRFab extends StatelessWidget {
  final bool isQueued;
  final bool multiJoinOn;
  // add an onTap callback field
  final Function() onTap;

  final bool hasJoinedOtherQueues;
  const JoinOrQRFab({
    super.key,
    required this.isQueued,
    required this.multiJoinOn,
    required this.hasJoinedOtherQueues,
    required this.onTap,
  });
  // Check if there are other active queues
  @override
  Widget build(BuildContext context) {
    if (isQueued) {
      // Show nothing
      return const Text("");
    } else if (multiJoinOn || !multiJoinOn && !hasJoinedOtherQueues) {
      // Allow to join queue
      return FloatingActionButton.extended(
          disabledElevation: 0,
          onPressed: onTap,
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
    }
    // Dont allow to join
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: SurfaceVariant.bg(context),
      label: Text(
        "You are in a different queue",
        style: TextStyle(
          color: SurfaceVariant.fg(context),
        ),
      ),
      icon: Icon(
        Icons.warning,
        color: SurfaceVariant.fg(context),
      ),
    );
  }
}

class QueueView extends StatefulWidget {
  final int activeId;
  const QueueView({super.key, required this.activeId});

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  // Poll server for latest queue every 2 seconds
  late ShopQueue queue;
  int assignedNumber = -1;
  bool get isQueued => assignedNumber > -1;
  @override
  void initState() {
    super.initState();
    // Monitor QueueListNotifier for changes in the active queue id
    final ql = Provider.of<QueueListNotifier>(context, listen: false);
    final _q = ql.active(widget.activeId);
    if (_q != null) {
      queue = _q;
    } else {
      return;
    }
    ql.addListener(onQueueListChange);
    final activeQueues =
        Provider.of<ActiveQueuesNotifier>(context, listen: false);
    onQueueNotifierChange();
    activeQueues.addListener(onQueueNotifierChange);
  }

  void onQueueListChange() {
    if (!mounted) {
      return;
    }
    final ql = Provider.of<QueueListNotifier>(context, listen: false);
    try {
      setState(() {
        queue = ql.queues.firstWhere((q) => q.id == widget.activeId);
      });
    } on StateError catch (_) {
      Navigator.pop(context);
    }
  }

  void onQueueNotifierChange() {
    if (!mounted) {
      return;
    }
    final qn = Provider.of<ActiveQueuesNotifier>(context, listen: false);
    setState(() {
      assignedNumber = qn.joinedQueueIDs[widget.activeId] ?? -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ActiveQueuesNotifier, ServerUrlNotifier>(
        builder: (context, activeQueueNotifier, serverUrlNotifier, child) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "Queue  Details",
          height: MediaQuery.of(context).size.height / 10,
        ),
        floatingActionButton: JoinOrQRFab(
            isQueued: isQueued,
            multiJoinOn: queue.isMultiJoin,
            hasJoinedOtherQueues: activeQueueNotifier.joinedQueueIDs.isNotEmpty,
            onTap: () async {
              activeQueueNotifier.join(queue, serverUrlNotifier.serverUrl);
            }),
        body: Center(
          child: Column(
            children: [
              PageTitleWidget(title: "Queue: ${queue.name}"),
              const VertSpace(),
              CurrentlyServing(queue: queue),
              const VertSpace(),
              lastNumber(activeQueueNotifier),
              const VertSpace(),
              PositionStatus(
                assignedNumber: assignedNumber,
              ),
              const VertSpace(),
              // Add a text that says that the user is  allowed to join other queues if multiJoinOn is true

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: queue.isMultiJoin
                      ? const Text("Note:\n You may join other queues")
                      : const Text(
                          "Note: \n This queue does not allow to join other queues"),
                ),
              ),
              const VertSpace(),
              isQueued
                  ? ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          onLongPress: () async {
                            Provider.of<ActiveQueuesNotifier>(context,
                                    listen: false)
                                .leave(widget.activeId);
                            Provider.of<QueueNotifier>(context, listen: false)
                                .queue = null;
                            setState(() {
                              assignedNumber = -1;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                          ),
                          child: Text("Leave Queue",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                      ],
                    )
                  : const Text(""),
            ],
          ),
        ),
      );
    });
  }

  Card lastNumber(ActiveQueuesNotifier queueNotifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Last Number in Queue:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "# ${queue.lastPosition}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class PositionStatus extends StatelessWidget {
  const PositionStatus({
    super.key,
    required this.assignedNumber,
  });

  final int assignedNumber;
  bool get isQueued => assignedNumber > -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const Text("Status:"),
          isQueued
              ? Text(
                  "You are # $assignedNumber",
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              : Text(
                  "You are not in this queue",
                  style: Theme.of(context).textTheme.bodyLarge,
                )
        ]),
      ),
    );
  }
}

class CurrentlyServing extends StatelessWidget {
  final ShopQueue queue;

  const CurrentlyServing({
    super.key,
    required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Currently Serving:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "# ${queue.current}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
