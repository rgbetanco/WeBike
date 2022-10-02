import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:pizarro_app/models/chat_user.dart';
import 'package:pizarro_app/models/trip.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/providers/users_page_provider.dart';
import 'package:provider/provider.dart';
import 'package:pizarro_app/widgets/rounded_marker.dart';

import '../services/database_service.dart';
import '../widgets/top_bar.dart';

class LiveLocationPage extends StatefulWidget {
  final Trip trip;
  static const String route = '/live_location';

  const LiveLocationPage({Key? key, required this.trip}) : super(key: key);

  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  LocationData? _currentLocation;
  late ChatUser member;
  late final MapController _mapController;

  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;

  List<Marker> allMarkers = [];

  bool _liveUpdate = true;
  bool _permission = false;

  String? _serviceError = '';

  int interActiveFlags = InteractiveFlag.all;

  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    initLocationService();
  }

  void initLocationService() async {
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );

    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        final permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService.onLocationChanged
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                _currentLocation = result;

                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.move(
                    LatLng(_currentLocation!.latitude!,
                        _currentLocation!.longitude!),
                    _mapController.zoom,
                  );
                  updateMarkers();
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        _serviceError = e.message;
      }
      location = null;
    }
  }

  void updateMarkers() {
    Future.microtask(() async {
      allMarkers.clear();
      for (var x = 0; x < widget.trip.members.length; x++) {
        //TODO
        //call db to get current location of all members
        List latlog = await _db.getMemberLocation(widget.trip.members[x].uid);
        widget.trip.members[x].lat = latlog[0];
        widget.trip.members[x].long = latlog[1];
        if (widget.trip.members[x].lat != null &&
            widget.trip.members[x].long != null) {
          print(
              "Adding marker ${x} : LAT - ${widget.trip.members[x].lat} , LONG - ${widget.trip.members[x].long}");
          allMarkers.add(
            Marker(
              point: LatLng(
                double.parse(widget.trip.members[x].lat!),
                double.parse(widget.trip.members[x].long!),
              ),
              builder: (context) => const Icon(
                Icons.circle,
                color: Colors.blue,
                size: 12,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    member = _auth.user;
    LatLng currentLatLng;
    // Until currentLocation is initially updated, Widget can locate to 0, 0
    if (_currentLocation != null) {
      _db.updateUserLocation(member.uid, _currentLocation!);

      currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      if (member.lat != "null" && member.long != "null") {
        currentLatLng = LatLng(
          double.parse(member.lat!),
          double.parse(member.long!),
        );
      } else {
        currentLatLng = LatLng(0, 0);
      }
    }

    // final markers = <Marker>[
    //   Marker(
    //     width: 24,
    //     height: 24,
    //     point: currentLatLng,
    //     builder: (ctx) => RoundedMarker(
    //       name: '王',
    //       height: 12,
    //       width: 12,
    //       color: Colors.blue,
    //       onPressed: () async {},
    //     ),
    //   ),
    // ];

    return Scaffold(
      body: Container(
        height: _deviceHeight,
        width: _deviceWidth,
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
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center:
                      LatLng(currentLatLng.latitude, currentLatLng.longitude),
                  zoom: 14,
                  interactiveFlags: interActiveFlags,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(
                      markers: allMarkers.sublist(0, allMarkers.length)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          onPressed: () {
            setState(() {
              _liveUpdate = !_liveUpdate;

              if (_liveUpdate) {
                interActiveFlags = InteractiveFlag.rotate |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom;

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'In live update mode only zoom and rotation are enable'),
                ));
              } else {
                interActiveFlags = InteractiveFlag.all;
              }
            });
          },
          child: _liveUpdate
              ? const Icon(Icons.location_on)
              : const Icon(Icons.location_off),
        );
      }),
    );
  }
}
