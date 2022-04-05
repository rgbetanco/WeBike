import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/playback_id.dart';
import 'package:pizarro_app/providers/global.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LivePage1 extends StatefulWidget {
  LivePage1({Key? key}) : super(key: key);

  @override
  State<LivePage1> createState() => _LivePageState1();
}

class _LivePageState1 extends State<LivePage1> {
  late Global _global;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

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
