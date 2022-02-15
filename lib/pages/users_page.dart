import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

class UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: Container(
        color: Colors.blue,
      ),
    );
  }
}
