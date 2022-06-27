import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/gps_data.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/database_service.dart';
import 'package:pizarro_app/services/sqlite.dart';
import 'package:pizarro_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'dart:math';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class GpsPage extends StatefulWidget {
  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late SqliteDB _sql;

  int _speed = 0;
  int _cadence = 0;
  double _distance = 0.0;
  bool _gpsRunning = false;
  int _trackId = 0;

  //location data
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location _location = new Location();
  LocationData? _prevLocationData;
  LocationData? _locationData;
  List<GpsData> _gpsDataToFirebase = [];
  GpsData _prevGpsData = new GpsData(
    trackId: 0,
    latitude: 0.0,
    longitude: 0.0,
    altitude: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    heading: 0.0,
    accuracy: 0.0,
    timestamp: DateTime.now(),
  );
  GpsData _gpsData = new GpsData(
    trackId: 0,
    latitude: 0.0,
    longitude: 0.0,
    altitude: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    heading: 0.0,
    accuracy: 0.0,
    timestamp: DateTime.now(),
  );
  late StreamSubscription<LocationData> _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _location.changeSettings(accuracy: LocationAccuracy.high, interval: 5000);
  }

  @override
  void dispose() {
    super.dispose();
    _stopListeningLocation();
  }

  void _initializeLocation() async {
    // _permissionGranted = await _location.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await _location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     print("Location permission denied");
    //     return;
    //   }
    // }

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        print("Location service is not enabled");
        return;
      }
    }

    await enableBackgroundMode();
  }

  Future<bool> enableBackgroundMode() async {
    bool _bgModeEnabled = await _location.isBackgroundModeEnabled();
    if (_bgModeEnabled) {
      return true;
    } else {
      try {
        await _location.enableBackgroundMode();
      } catch (e) {
        debugPrint(e.toString());
      }
      try {
        _bgModeEnabled = await _location.enableBackgroundMode();
      } catch (e) {
        debugPrint(e.toString());
      }
      print(_bgModeEnabled); //True!
      return _bgModeEnabled;
    }
  }

  Future<void> _startListeningLocation() async {
    try {
      _locationData = await _location.getLocation();
      _locationSubscription = _location.onLocationChanged.listen(
        (LocationData data) {
          _gpsData.latitude = data.latitude!;
          _gpsData.longitude = data.longitude!;
          _gpsData.altitude = data.altitude!;
          _gpsData.speed = data.speed!;
          _gpsData.speedAccuracy = data.speedAccuracy!;
          _gpsData.heading = data.heading!;
          _gpsData.accuracy = data.accuracy!;
          _gpsData.timestamp = DateTime.now();
          if (data.speed != null && data.speedAccuracy! >= 0.0) {
            _speed = (data.speed! * 3.6).ceil();
          }
          if (_prevGpsData.latitude != 0.0 && _gpsData.latitude != 0.0) {
            _distance += _calcDistance(_prevGpsData, _gpsData, 1);
            //probably i need to add a check if accuracy is higher than certain number
            if (_distance > 0) {
              //add Gps Data to a sqlite database
              _sql.addGpsData(_trackId, _gpsData);
              //_gpsDataToFirebase.add(_gpsData);
            }
          }
//          print(data.satelliteNumber);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "speed:" +
                    data.speed.toString() +
                    ", speed accuracy:" +
                    data.speedAccuracy.toString() +
                    ", distance:" +
                    _distance.toString() +
                    ", distance accuracy:" +
                    data.accuracy.toString(),
              ),
            ),
          );
          _prevGpsData.latitude = _gpsData.latitude;
          _prevGpsData.longitude = _gpsData.longitude;
          _prevGpsData.altitude = data.altitude!;
          _prevGpsData.speed = data.speed!;
          _prevGpsData.speedAccuracy = data.speedAccuracy!;
          _prevGpsData.heading = data.heading!;
          _prevGpsData.accuracy = data.accuracy!;
          _prevGpsData.timestamp = DateTime.now();
          setState(() {});
        },
      );
    } catch (e) {
      _gpsRunning = false;
      print(e);
    }
  }

  double _calcDistance(GpsData l1, GpsData l2, int km) {
    double PI = 3.141592653589793238;
    double constant = 3963.0;
    if (km == 1) {
      constant = 6371;
    }
    // Convert the latitudes
    // and longitudes
    // from degree to radians.
    double lat1 = l1.latitude * PI / 180;
    double long1 = l1.longitude * PI / 180;
    double lat2 = l2.latitude * PI / 180;
    double long2 = l2.longitude * PI / 180;

    // Haversine Formula
    double dlong = long2 - long1;
    double dlat = lat2 - lat1;

    double ans =
        pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlong / 2), 2);

    ans = 2 * asin(sqrt(ans));
    ans = ans * constant;

    return ans;
  }

  void _stopListeningLocation() {
    try {
      _locationSubscription.cancel();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _sql = GetIt.instance.get<SqliteDB>();

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
              'GPS',
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
            SizedBox(
              height: _deviceHeight * 0.02,
            ),
            Container(
              child: Center(
                child: Text(
                  _distance.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 65.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Text(
              "km",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: _deviceHeight * 0.08,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "00:00",
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const Text(
                      "Time",
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _speed.toString(),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const Text(
                      "km/h",
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: _deviceHeight * 0.1,
            ),
            Container(
              child: Center(
                child: Text(
                  _cadence.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 65.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Text(
              "Cadence",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: _deviceHeight * 0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Icon(
                        _gpsRunning ? Icons.pause_sharp : Icons.play_arrow,
                        size: 50,
                      ),
                      onPressed: () async {
                        if (!_gpsRunning) {
                          //Update track number
                          _trackId = await _sql.addTrack();
                          _gpsRunning = true;
                          _startListeningLocation();
                        } else {
                          _gpsRunning = false;
                          _stopListeningLocation();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                //TODO: check if there are gps data available for that track
                                return AlertDialog(
                                  title: const Text("GPS"),
                                  content: const Text(
                                      "Do you want to record this run?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("OK"),
                                      onPressed: () {
                                        //TODO: Delete track from database
                                        // _db.addTrackToUser(
                                        //     _auth.user.uid, _gpsDataToFirebase);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent,
                        fixedSize: const Size(80, 80),
                        shape: new RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
