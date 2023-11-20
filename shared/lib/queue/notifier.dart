import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared/queue/server_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list.dart';
import 'shop_queue.dart';

class QueueListNotifier extends ChangeNotifier {
  List<ShopQueue> queues = [];
  int _intervalMS = 1000;

  int get intervalMS => _intervalMS;

  set intervalMS(int value) {
    _intervalMS = value;
  }

  Timer? timer;
  Future<void> getQueues(String url) async {
    queues = await fetchQueues(url);
    notifyListeners();
  }

  Future<void> getQueue(String url, String queueName) async {
    queues = [await fetchQueue(url, queueName)];
    notifyListeners();
  }

  void clear() {
    queues.clear();
    notifyListeners();
  }

  void startTimedFetch(String url) {
    timer = Timer.periodic(Duration(milliseconds: intervalMS), (timer) {
      getQueues(url);
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  ShopQueue? active(int id) {
    try {
      return queues.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
}

class ActiveQueuesNotifier extends ChangeNotifier {
  Map<int, int> joinedQueueIDs = {};
  Future<void> join(ShopQueue q, String url) async {
    final assignedNumber = await joinQueue(q, url);
    add(q.id, assignedNumber);
  }

  void add(int id, int pos) {
    joinedQueueIDs[id] = pos;
    notifyListeners();
  }

  List<String> toCompactList() {
    return joinedQueueIDs.entries
        .map((e) => "${e.key}:${e.value}")
        .toList()
        .cast<String>();
  }

  void clear() {
    joinedQueueIDs.clear();
    notifyListeners();
  }

  void leave(int id) {
    joinedQueueIDs.remove(id);
    notifyListeners();
  }

  void start() {
    addListener(onChanges);
  }

  void onChanges() {
    final serialized = toCompactList();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('queue-positions', serialized);
    });
  }

  void load(SharedPreferences prefs) {
    prefs.getStringList("queue-positions")?.forEach((id) {
      final split = id.split(":");
      add(int.parse(split[0]), int.parse(split[1]));
    });
  }
}

class QueueNotifier extends ChangeNotifier {
  ShopQueue? _queue;
  ShopQueue? get queue => _queue;
  QueueNotifier();

  set queue(ShopQueue? value) {
    _queue = value;
    notifyListeners();
  }
}
