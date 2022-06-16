import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/gps_data.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/database_service.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:pizarro_app/services/sqlite.dart';
import 'package:pizarro_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';

class GpsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GpsListPageState();
  }
}

class GpsListPageState extends State<GpsListPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late NavigationService _nav;
  List<GpsData>? _gpsData;
  List<Track>? _tracks;
  late SqliteDB _sql;

  void getGpsDataFromFirebase() async {
    try {
      _db.getTrackOfUser(_auth.user.uid).then(
        (_snapshot) async {
          await Future.wait(
            _snapshot.docs.map(
              (e) async {
                Map<String, dynamic> _data = e.data() as Map<String, dynamic>;
                var decoded = jsonDecode(_data['data']);
                _gpsData =
                    decoded.map<GpsData>((e) => GpsData.fromJson(e)).toList();
                setState(() {});
              },
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void getTracks() async {
    _tracks = await _sql.getTracks();
  }

  @override
  void initState() async {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _sql = GetIt.instance.get<SqliteDB>();
    _nav = GetIt.instance.get<NavigationService>();

    getTracks();

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              'REC',
              primaryAction: IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                ),
                onPressed: () async {
                  _auth.logout();
                },
              ),
            ),
            ListView.builder(
              physics: ScrollPhysics(parent: null),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: _deviceHeight * 0.1,
                  width: _deviceWidth * 0.97,
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        _tracks![index].created,
                        style: TextStyle(
                          fontSize: _deviceHeight * 0.02,
                        ),
                      ),
                      subtitle: Text(
                        '${_tracks![index].id}',
                        style: TextStyle(
                          fontSize: _deviceHeight * 0.02,
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: _gpsData?.length ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}
