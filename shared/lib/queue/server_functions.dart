import 'shop_queue.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
