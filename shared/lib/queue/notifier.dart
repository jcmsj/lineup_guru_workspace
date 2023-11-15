import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'shop_queue.dart';

class QueueNotifier extends ChangeNotifier {
  ShopQueue? _queue;
  int _myNumber = -1;
  ShopQueue? get queue => _queue;
  int get myNumber => _myNumber;

  /// The queue that the user joined
  int _activeQueueId = -1;

  /// The queue that the user joined
  int get activeQueueId => _activeQueueId;

  /// The queue that the user joined
  set activeQueueId(int value) {
    _activeQueueId = value;
    notifyListeners();
  }

  set queue(ShopQueue? queue) {
    _queue = queue;
    notifyListeners();
  }

  set myNumber(int myNumber) {
    _myNumber = myNumber;
    activeQueueId = queue?.id ?? -1;
    notifyListeners();
  }
}

Future<ShopQueue> pollQueue(String url, String name) async {
  // Get ServerURL from ServerUrlNotifier
  final response = await http.get(Uri.parse('$url/queue/$name'));
  if (response.statusCode == 200) {
    // body -> json -> Update queueNotifier
    return ShopQueue.fromJson(jsonDecode(response.body));
  }

  throw Exception(
    'Failed to fetch queue. Reason: ${response.body}',
  );
}

Future<int> joinQueue(ShopQueue q, String url) async {
  final response = await http.post(
    Uri.parse('$url/join/${q.id}'),
  );
  if (response.statusCode == 200) {
    // Do something with the response body
    Map<String, dynamic> result = jsonDecode(response.body);
    return result['number'];
  } else {
    throw Exception('Failed to join queue');
  }
}
