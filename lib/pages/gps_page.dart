import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
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
  int _speed = 0;
  int _cadence = 0;
  double _distance = 0.0;

  //location data
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location _location = new Location();
  LocationData? _prevLocationData;
  LocationData? _locationData;
  late StreamSubscription<LocationData> _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);
  }

  @override
  void dispose() {
    super.dispose();
    _stopListeningLocation();
    _locationSubscription.cancel();
  }

  void _initializeLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        print("Location service is not enabled");
        return;
      }
    }
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Location permission denied");
        return;
      }
    }

    _location.enableBackgroundMode(enable: true);
  }

  void _startListeningLocation() async {
    try {
      _prevLocationData ??= await _location.getLocation();
      _locationData = await _location.getLocation();
      _locationSubscription =
          _location.onLocationChanged.listen((LocationData data) {
        print(data.latitude);
        print(data.longitude);
        print(data.accuracy);
        print(data.altitude);
        if (data.speed != null) {
          setState(() {
            _speed = data.speed!.round();
            _distance = _calcDistance(_prevLocationData!, _locationData!, 1);
          });
        }
        print(data.speedAccuracy);
        print(data.satelliteNumber);
        print(data.heading);
        print(data.headingAccuracy);
      });
    } catch (e) {
      print(e);
    }
    _prevLocationData = _locationData;
    _locationData = null;
  }

  double _calcDistance(LocationData l1, LocationData l2, int km) {
    double PI = 3.141592653589793238;
    double constant = 3963.0;
    if (km == 1) {
      constant = 1.609344;
    }
    // Convert the latitudes
    // and longitudes
    // from degree to radians.
    double lat1 = l1.latitude! * PI / 180;
    double long1 = l1.longitude! * PI / 180;
    double lat2 = l2.latitude! * PI / 180;
    double long2 = l2.longitude! * PI / 180;

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
    _locationSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);

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
                  _distance.toString(),
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
                        Icons.play_arrow,
                        size: 50,
                      ),
                      onPressed: () {},
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
