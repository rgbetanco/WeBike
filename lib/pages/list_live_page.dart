import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:pizarro_app/models/playback_id.dart';
import 'package:pizarro_app/models/stream_key.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/providers/global.dart';
import 'package:pizarro_app/services/database_service.dart';
import 'package:pizarro_app/services/mux_service.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:pizarro_app/widgets/rounded_button.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_list_view_tiles.dart';
import '../widgets/top_bar.dart';

class ListLivePage extends StatefulWidget {
  const ListLivePage({Key? key}) : super(key: key);

  @override
  _ListLiveState createState() => _ListLiveState();
}

class _ListLiveState extends State<ListLivePage> {
  late AuthenticationProvider _auth;
  late MuxService _mux;
  late DatabaseService _db;
  late Global _global;
  late NavigationService _navigation;

  final _baseUrl = 'https://api.mux.com/video/v1/live-streams';

  int _page = 0;
  int _limit = 20;
  String _status = 'active';
  bool _isFirstRun = true;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;

  late double _deviceHeight;
  late double _deviceWidth;

  List _posts = [];
  late List<PlaybackId>? playbackIds = [];

  void _firstLoad() async {
    _isFirstRun = false;
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      final String? muxToken = await _db.getMuxToken();
      if (muxToken == null) {
        throw Exception('Mux token is null');
      }
      playbackIds = await _mux.getLiveStream(muxToken, _page, _limit);
      if (playbackIds == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading live streams"),
          ),
        );
      } else {
        for (int i = 0; i < playbackIds!.length; ++i) {
          var user = await _db.getUserFromStreamKey(playbackIds![i].playbackId);
          playbackIds![i].userId = user![0];
          playbackIds![i].profilePhotoUrl = user[1];
          playbackIds![i].name = user[2];
        }
      }
    } catch (err) {
      print(err);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(err.toString()),
      //   ),
      // );
    }
    _cleanUp();
    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _cleanUp() {
    // print(_auth.user.uid);
    if (playbackIds != null) {
      for (var i = 0; i < playbackIds!.length; i++) {
        // print(playbackIds![i].userId);
        if (playbackIds![i].name == null ||
            playbackIds![i].name == '' ||
            playbackIds![i].userId == _auth.user.uid) {
          playbackIds!.removeAt(i);
          i--;
        }
      }
    }
  }

  void _updateList() async {
    try {
      final String? muxToken = await _db.getMuxToken();
      if (muxToken == null) {
        throw Exception('Mux token is null');
      }
      List<PlaybackId>? playbackIdsTemp =
          await _mux.getLiveStream(muxToken, _page, _limit);
      if (playbackIdsTemp == null || playbackIdsTemp.isEmpty) {
        _hasNextPage = false;
        print('Stream keys is null');
      } else {
        for (int i = 0; i < playbackIdsTemp.length; ++i) {
          for (int j = 0; j < playbackIds!.length; ++j) {
            if (playbackIdsTemp[i].playbackId == playbackIds![j].playbackId) {
              playbackIds![j].isActive = playbackIdsTemp[i].isActive;
            }
          }
        }
        setState(() {});
      }
    } catch (err) {
      print(err);
    }
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      try {
        final String? muxToken = await _db.getMuxToken();
        if (muxToken == null) {
          throw Exception('Mux token is null');
        }
        List<PlaybackId>? playbackIdsTemp =
            await _mux.getLiveStream(muxToken, _page, _limit);
        if (playbackIdsTemp == null || playbackIdsTemp.isEmpty) {
          _hasNextPage = false;
          print('Stream keys is null');
        } else {
          for (int i = 0; i < playbackIdsTemp.length; ++i) {
            var user =
                await _db.getUserFromStreamKey(playbackIdsTemp[i].playbackId);
            playbackIdsTemp[i].userId = user![0];
            playbackIdsTemp[i].profilePhotoUrl = user[1];
            playbackIdsTemp[i].name = user[2];
          }
          setState(() {
            playbackIds!.addAll(playbackIdsTemp);
          });
        }
      } catch (err) {
        print(err);
      }
      _cleanUp();
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = new ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  late ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _mux = GetIt.instance.get<MuxService>();
    _db = GetIt.instance.get<DatabaseService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _global = GetIt.instance.get<Global>();
    _navigation = GetIt.instance.get<NavigationService>();

    if (_isFirstRun) {
      _firstLoad();
    }
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              'Creators',
              fontSize: 10,
              primaryAction: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                ),
                onPressed: () {
                  _auth.logout();
                },
              ),
              secondaryAction: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                ),
                onPressed: () {
                  _navigation.goBack();
                },
              ),
            ),
            _isFirstLoadRunning
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _controller,
                            itemCount: playbackIds!.length,
                            itemBuilder: (_, index) => _chatTile(
                                playbackIds![index].name.toString(),
                                playbackIds![index].profilePhotoUrl.toString(),
                                playbackIds![index].playbackId,
                                playbackIds![index].isActive),
                          ),
                        ),
                        if (_isLoadMoreRunning == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 40),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),

                        // When nothing else to load
                        if (_hasNextPage == false)
                          Container(
                            padding: EdgeInsets.only(top: 40, bottom: 40),
                            color: Colors.amber,
                            child: Center(
                              child: Text('No more posts broadcasts'),
                            ),
                          ),
                      ],
                    ),
                  ),
            _createUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _newW() {
    return Builder(
      builder: (BuildContext _context) {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Live Broadcast',
                primaryAction: IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                  onPressed: () {
                    _auth.logout();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _oldW() {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Live'),
      ),
      body: _isFirstLoadRunning
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: playbackIds!.length,
                    itemBuilder: (_, index) => _chatTile(
                        playbackIds![index].name.toString(),
                        playbackIds![index].profilePhotoUrl.toString(),
                        playbackIds![index].playbackId,
                        playbackIds![index].isActive),
                  ),
                ),
                if (_isLoadMoreRunning == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // When nothing else to load
                if (_hasNextPage == false)
                  Container(
                    padding: EdgeInsets.only(top: 40, bottom: 40),
                    color: Colors.amber,
                    child: Center(
                      child: Text('No more posts broadcasts'),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _chatList(
      String title, String imageUrl, String playbackId, bool isActive) {
    return Expanded(
      child: _chatTile(title, imageUrl, playbackId, isActive),
    );
  }

  Widget _chatTile(_title, _imageUrl, _playbackId, _isActive) {
    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: _title,
      subtitle: _playbackId,
      imagePath: _imageUrl,
      isActive: _isActive,
      isActivity: false,
      onTap: (context) {
        if (_isActive) {
          _global.set(_playbackId);
          _navigation.navigateToRoute('/live');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Creator is not live, please check back later"),
            ),
          );
        }
      },
    );
  }

  Widget _createUpdateButton() {
    return Visibility(
      visible: true,
      child: RoundedButton(
        name: "Update",
        height: _deviceHeight * 0.08,
        width: _deviceWidth * 0.80,
        onPressed: () {
          _updateList();
        },
      ),
    );
  }
}
