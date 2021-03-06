import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pizarro_app/models/playback_id.dart';
import 'package:pizarro_app/models/stream_key.dart';

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

  Future<List<PlaybackId>?> getLiveStream(
      String? basicAuth, int page, int limit) async {
    if (basicAuth != null) {
      try {
        var url = Uri.parse(
            'https://api.mux.com/video/v1/live-streams?page=$page&limit=$limit');
        var response = await http.get(url, headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json'
        });

        final Map parsed = json.decode(response.body);
        final List<PlaybackId> streamKeys = [];
        for (var i = 0; i < parsed["data"].length; i++) {
          final String userID = "";
          final String playbackId = parsed["data"][i]["playback_ids"][0]["id"];
          final String status = parsed["data"][i]["status"];
          bool isActive = false;
          if (status == "active") {
            isActive = true;
          }
          streamKeys.add(PlaybackId(
              userId: userID, playbackId: playbackId, isActive: isActive));
        }
        return streamKeys;
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      return null;
    }
  }
}
