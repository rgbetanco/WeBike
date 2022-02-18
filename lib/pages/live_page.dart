import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/playback_id.dart';
import 'package:pizarro_app/providers/global.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LivePage extends StatefulWidget {
  LivePage({Key? key}) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late Global _global;

  @override
  Widget build(BuildContext context) {
    _global = GetIt.instance.get<Global>();
    String pid = _global.get();
    String url = 'https://stream.mux.com/$pid.m3u8';
    return Scaffold(
      body:
          WebView(initialUrl: url, javascriptMode: JavascriptMode.unrestricted),
    );
  }
}
