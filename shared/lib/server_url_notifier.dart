import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerUrlNotifier extends ChangeNotifier {
  String _serverUrl =
      "http://lineup-gu.ru.larkspur.website"; //"http://localhost:88";

  String get serverUrl => _serverUrl;

  set serverUrl(String url) {
    _serverUrl = url;
    notifyListeners();
  }

  Future<void> tryCandidate(String serverCandidate) async {
    log("pinging $serverCandidate");
    final uri = Uri.parse(serverCandidate);
    final response = await http.get(Uri.parse("$uri/ping"));
    if (response.body == "pong") {
      serverUrl = serverCandidate;
      notifyListeners();
      return;
    }

    throw Exception(
        "QR does not contain a Line-Up Guru URL or server is offline");
  }
}
