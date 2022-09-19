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
import '../pages/live_location.dart';
import '../pages/trips_page.dart';
import '../services/navigation_service.dart';

class TripPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late NavigationService _navigation;

  TripPageProvider() {
    _db = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void goToTripMapPage(Trip _trip) {
    LiveLocationPage _uTrip = LiveLocationPage(
      trip: _trip,
    );
    _navigation.navigateToPage(_uTrip);
  }

  Future<void> updateTrip(Trip _trip) async {
    try {
      await _db.updateTrip(
        _trip,
      );
      goToTripMapPage(_trip);
    } catch (de) {
      print(de);
    } catch (e) {
      print(e);
    }
  }
}
