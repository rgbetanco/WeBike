import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LivePage extends StatefulWidget {
  LivePage({Key? key}) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WebView(
          initialUrl:
              'https://stream.mux.com/syXDzUajzfjPhb00MC5bgofwe02BzgTAea8islZaxhAAg.m3u8',
          javascriptMode: JavascriptMode.unrestricted),
    );
  }
}
