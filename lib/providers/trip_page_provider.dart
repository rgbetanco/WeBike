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
}
