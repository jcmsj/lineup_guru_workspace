import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerUrlNotifier extends ChangeNotifier {
  String _serverUrl =
      "http://lineup-gu.ru.larkspur.website"; //"http://localhost:88";

  String get serverUrl => _serverUrl;
  final trailingSlash = RegExp("/\$");

  set serverUrl(String url) {
    //Important: Strip trailing slash
    _serverUrl = url.replaceAll(trailingSlash, "");
    notifyListeners();
  }

  Future<void> tryCandidate(String serverCandidate) async {
    log("pinging $serverCandidate");
    // strip the trailing slash
    serverCandidate = serverCandidate.replaceAll(trailingSlash, "");
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

  Future<SharedPreferences> restore() async {
    final prefs = await SharedPreferences.getInstance();
    await tryCandidate(prefs.getString('server-url') ?? "");
    return prefs;
  }

  Future<void> onChange() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'server-url',
      serverUrl,
    );
  }
}
