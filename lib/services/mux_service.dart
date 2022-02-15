import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:pizarro_app/models/stream_key.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/database_service.dart';

class MuxService {
  late final msg;

  MuxService() {}

  Future<StreamKey?> createLiveStream(String? basicAuth) async {
    if (basicAuth != null) {
      try {
        msg = jsonEncode({
          "playback_policy": ["public"],
          "new_asset_settings": {
            "playback_policy": ["public"]
          }
        });
        var url = Uri.parse('https://api.mux.com/video/v1/live-streams');
        var response = await http.post(url,
            body: msg,
            headers: <String, String>{
              'Authorization': basicAuth,
              'Content-Type': 'application/json'
            });
        //print('Response status: ${response.statusCode}');
        //print('Response body: ${response.body}');
        final Map parsed = json.decode(response.body);
        final String streamKey = parsed["data"]["stream_key"];
        final String playbackId = parsed["data"]["playback_ids"][0]["id"];
        return StreamKey(streamKey: streamKey, playbackId: playbackId);
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      return null;
    }
  }
}
