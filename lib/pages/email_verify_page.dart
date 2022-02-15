import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:provider/provider.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  _EmailVerifyScreenState createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late User user;
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _auth.checkEmailVerification().then((value) {
        if (value) {
          timer.cancel();
          _navigation.removeAndNavigateToRoute('/home');
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return const Scaffold(
      body: Center(
        child: Text('An email has been sent to test, please verify'),
      ),
    );
  }
}
