// import 'dart:html';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/pages/chats_page.dart';
import 'package:pizarro_app/pages/gps_layout_page.dart';
import 'package:pizarro_app/pages/gps_page.dart';
import 'package:pizarro_app/pages/live_broadcast_page.dart';
import 'package:pizarro_app/pages/live_page1.dart';
import 'package:pizarro_app/pages/trips_page.dart';
import 'package:pizarro_app/pages/users_page.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;

  final List<Widget> _pages = [
    GpsLayoutPage(),
    ChatsPage(),
    UsersPage(),
    TripsPage(),
  ];

  @override
  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  void checkPermission() async {
    await Permission.location.request().isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPage,
        onTap: (_index) {
          setState(() {
            _currentPage = _index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "GPS",
            icon: Icon(
              Icons.gps_fixed,
            ),
          ),
          BottomNavigationBarItem(
            label: "Chats",
            icon: Icon(
              Icons.chat_bubble_sharp,
            ),
          ),
          BottomNavigationBarItem(
            label: "Users",
            icon: Icon(
              Icons.supervised_user_circle_sharp,
            ),
          ),
          BottomNavigationBarItem(
            label: "Trips",
            icon: Icon(
              Icons.map_sharp,
            ),
          ),
        ],
      ),
    );
  }
}
