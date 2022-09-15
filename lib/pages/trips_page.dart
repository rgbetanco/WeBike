import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/chat.dart';
import 'package:pizarro_app/models/chat_message.dart';
import 'package:pizarro_app/models/trip.dart';
import 'package:pizarro_app/pages/chat_page.dart';
import 'package:pizarro_app/pages/live_location.dart';
import 'package:pizarro_app/pages/trip_update_page.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/providers/chats_page_provider.dart';
import 'package:pizarro_app/services/database_service.dart';
import 'package:pizarro_app/services/mux_service.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:pizarro_app/widgets/custom_list_view_tiles.dart';
import 'package:pizarro_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

import '../models/chat_user.dart';
import '../providers/trip_page_provider.dart';
import '../providers/trips_page_provider.dart';
import '../pages/trip_update_page.dart';
import '../widgets/rounded_button.dart';

class TripsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TripsPageState();
  }
}

class TripsPageState extends State<TripsPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late TripsPageProvider _tripsPageProvider;
  late DatabaseService _db;
  late NavigationService _nav;
  //late Trip _selectedTrip;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _nav = GetIt.instance.get<NavigationService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TripsPageProvider>(
          create: (_) => TripsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext _context) {
        _tripsPageProvider = _context.watch<TripsPageProvider>();
        return Scaffold(
          body: Container(
            height: _deviceHeight * 0.98,
            width: _deviceWidth * 0.97,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopBar(
                  'Trips',
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
                _locationList(),
                SizedBox(
                  height: _deviceHeight * 0.02,
                ),
                _updateTripButton(),
                SizedBox(
                  height: _deviceHeight * 0.02,
                ),
                //_goToMap(),
                SizedBox(
                  height: _deviceHeight * 0.02,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _locationList() {
    List<Trip>? _trips = _tripsPageProvider.trips;
    return Expanded(
      child: (() {
        if (_trips != null) {
          if (_trips.length != 0) {
            return ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (BuildContext _context, int _index) {
                return _tripTile(
                  _trips[_index],
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No trips yet',
                style: TextStyle(
                  fontSize: _deviceHeight * 0.03,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      })(),
    );
  }

  Widget _tripTile(Trip _trip) {
    List<ChatUser> _members = _trip.members;
    bool _isActive = true;
    String _subtitleText = "";
    if (_trip.members.isNotEmpty) {
      _subtitleText = _trip.members.first.name;
    }
    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: _trip.title,
      subtitle: _subtitleText,
      imagePath: "",
      isActive: _isActive,
      isActivity: false,
      onTap: (context) {
        _tripsPageProvider.selectedTrip = _trip;
        setState(() {});
      },
    );
  }

  Widget _updateTripButton() {
    if (_tripsPageProvider.selectedTrip != null) {
      return Visibility(
        visible: _tripsPageProvider.selectedTrip != null,
        child: RoundedButton(
          name: "Edit ${_tripsPageProvider.selectedTrip?.title}",
          height: _deviceHeight * 0.05,
          width: _deviceWidth * 0.60,
          onPressed: () {
            if (_tripsPageProvider.selectedTrip != null) {
              _tripsPageProvider.goToTripModifyPage();
            }
          },
        ),
      );
    } else {
      return Container();
    }
  }

  // Widget _goToMap() {
  //   return Visibility(
  //     visible: true,
  //     child: RoundedButton(
  //       name: "Go to Map",
  //       height: _deviceHeight * 0.05,
  //       width: _deviceWidth * 0.60,
  //       onPressed: () {
  //         _nav.navigateToPage(
  //           LiveLocationPage(
  //             trip: _selectedTrip,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
