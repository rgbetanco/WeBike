import 'package:flutter/material.dart';
import 'package:pizarro_app/pages/broadcast_page.dart';
import 'package:pizarro_app/pages/email_verify_page.dart';
import 'package:pizarro_app/pages/live_broadcast_page.dart';
import 'package:pizarro_app/pages/live_page.dart';

//Packages
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pizarro_app/pages/reset_password_page.dart';
import 'package:pizarro_app/providers/apple_signin_available.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:provider/provider.dart';

//Pages
import './pages/splash_page.dart';
import 'package:pizarro_app/pages/home_page.dart';
import 'package:pizarro_app/pages/login_page.dart';
import 'package:pizarro_app/pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SplashPage(
    key: UniqueKey(),
    onInitializationComplete: () async {
      final appleSignInAvailable = await AppleSignInAvailable.check();
      runApp(
        Provider<AppleSignInAvailable>.value(
          value: appleSignInAvailable,
          child: MainApp(),
        ),
      );
    },
  ));
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext _context) {
            return AuthenticationProvider();
          },
        )
      ],
      child: MaterialApp(
        title: 'WeBike',
        theme: ThemeData(
          backgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
          scaffoldBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext _context) => LoginPage(),
          '/emailverify': (BuildContext _context) => const EmailVerifyScreen(),
          '/register': (BuildContext _context) => RegisterPage(),
          '/resetPassword': (BuildContext _context) => ResetPasswordPage(),
          '/home': (BuildContext _context) => HomePage(),
          '/liveOrBroadcastPage': (BuildContext _context) =>
              LiveOrBroadcastPage(),
          '/broadcast': (BuildContext _context) => BroadcastPage(),
          '/live': (BuildContext _context) => LivePage(),
        },
      ),
    );
  }
}
