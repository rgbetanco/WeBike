import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/chat.dart';
import 'package:pizarro_app/models/chat_message.dart';
import 'package:pizarro_app/pages/chat_page.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/providers/chats_page_provider.dart';
import 'package:pizarro_app/providers/global.dart';
import 'package:pizarro_app/services/database_service.dart';
import 'package:pizarro_app/services/mux_service.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:pizarro_app/widgets/custom_list_view_tiles.dart';
import 'package:pizarro_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/chat_user.dart';

class LivePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LivePageState();
  }
}

class LivePageState extends State<LivePage> {
  late Global _global;

  late VideoPlayerController _controller;
  int _playbackTime = 0;
  double _volume = 0.5;

  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late NavigationService _nav;

  void _initPlayer() async {
    _global = GetIt.instance.get<Global>();
    String pid = _global.get();
    String url = 'https://stream.mux.com/$pid.m3u8';
    if (pid.isNotEmpty || pid != "") {
      _controller = VideoPlayerController.network(url);
    } else {
      _controller =
          VideoPlayerController.asset('assets/videos/nobroadcasting.mp4');
    }

    await _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _global.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _controller.addListener(
      () {
        setState(
          () {
            _playbackTime = _controller.value.position.inSeconds;
            _volume = _controller.value.volume;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _nav = GetIt.instance.get<NavigationService>();

    return _buildUI();
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext _context) {
        return Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03,
              vertical: _deviceHeight * 0.02,
            ),
            height: _deviceHeight * 0.98,
            width: _deviceWidth,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopBar(
                  'Live broadcast',
                  fontSize: 10,
                  primaryAction: IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Color.fromRGBO(0, 82, 218, 1.0),
                    ),
                    onPressed: () async {
                      _auth.logout();
                    },
                  ),
                  secondaryAction: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromRGBO(0, 82, 218, 1.0),
                    ),
                    onPressed: () {
                      _nav.goBack();
                    },
                  ),
                ),
                _videoPlayer(),
                FloatingActionButton(
                    onPressed: () {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    },
                    child: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _videoPlayer() {
    return Expanded(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _controller.value.isInitialized ? _playerWidget() : Container(),
      ],
    ));
  }

  Widget _playerWidget() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}
