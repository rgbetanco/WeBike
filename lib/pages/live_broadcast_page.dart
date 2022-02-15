import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../services/navigation_service.dart';
import '../widgets/rounded_button.dart';
import '../widgets/top_bar.dart';

class LiveOrBroadcastPage extends StatefulWidget {
  @override
  _LiveOrBroadcastPageState createState() => _LiveOrBroadcastPageState();
}

class _LiveOrBroadcastPageState extends State<LiveOrBroadcastPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
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
              '',
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
            _ChooseBtn(),
          ],
        ),
      ),
    );
  }

  Widget _ChooseBtn() {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedButton(
            name: "Audience",
            height: _deviceHeight * 0.065,
            width: _deviceWidth * 0.65,
            onPressed: () {
              _navigation.navigateToRoute('/live');
            }),
        SizedBox(
          height: _deviceHeight * 0.02,
        ),
        RoundedButton(
            name: "Broadcaster",
            height: _deviceHeight * 0.065,
            width: _deviceWidth * 0.65,
            onPressed: () {
              _navigation.navigateToRoute('/broadcast');
            }),
      ],
    ));
  }
}
