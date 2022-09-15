import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/chat.dart';
import 'package:pizarro_app/models/chat_message.dart';
import 'package:pizarro_app/models/chat_user.dart';
import 'package:pizarro_app/models/trip_location.dart';
import 'package:pizarro_app/pages/trip_update_page.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/database_service.dart';

import '../models/trip.dart';
import '../pages/trips_page.dart';
import '../services/navigation_service.dart';

class TripsPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;
  late DatabaseService _db;
  late NavigationService _navigation;

  List<Trip>? trips;
  Trip? selectedTrip;

  late StreamSubscription _tripsStream;

  TripsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getTrips();
  }

  @override
  void dispose() {
    _tripsStream.cancel();
    super.dispose();
  }

  void getTrips() async {
    try {
      _tripsStream =
          _db.getTripsForUser(_auth.user.uid).listen((_snapshot) async {
        trips = await Future.wait(
          _snapshot.docs.map(
            (_d) async {
              Map<String, dynamic> _chatData =
                  _d.data() as Map<String, dynamic>;
              //Get users in trip
              List<ChatUser> _members = [];
              for (var _uid in _chatData['members']) {
                DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
                Map<String, dynamic> _userData =
                    _userSnapshot.data() as Map<String, dynamic>;
                _userData['uid'] = _userSnapshot.id;
                _members.add(
                  ChatUser.fromJSON(_userData),
                );
              }
              //Get last message for chat
              List<TripLocation> _location = [];
              QuerySnapshot _tripLocation =
                  await _db.getLastLocationForTrip(_d.id);
              if (_tripLocation.docs.isNotEmpty) {
                Map<String, dynamic> _locationData =
                    _tripLocation.docs.first.data()! as Map<String, dynamic>;
                TripLocation _loc = TripLocation.fromJSON(_locationData);
                _location.add(_loc);
              }
              //Return chat instance
              return Trip(
                uid: _d.id,
                title: "Undefined",
                imageURL: DEFAULT_TRIP_IMAGE,
                members: _members,
                locations: _location,
              );
            },
          ).toList(),
        );
        notifyListeners();
      });
    } catch (e) {
      print("Error getting chats: $e");
    } catch (e) {
      print("Error getting chats: $e");
    }
  }

  Future<String?> updateTrip(Trip _trip) async {
    try {
      await _db.updateTrip(
        _trip,
      );
      return _trip.uid;
    } catch (de) {
      print(de);
    } catch (e) {
      print(e);
    }
  }

  void goToTripModifyPage() {
    if (selectedTrip != null) {
      TripUpdatePage _uTrip = TripUpdatePage(
        trip: selectedTrip!,
      );
      notifyListeners();
      _navigation.navigateToPage(_uTrip);
    }
  }
}
