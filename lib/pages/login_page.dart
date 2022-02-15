import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/providers/apple_signin_available.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/database_service.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:pizarro_app/widgets/rounded_button.dart';
import 'package:provider/provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:the_apple_sign_in/apple_sign_in_button.dart' as appleButton;

//Widgets
import '../widgets/custom_input_fields.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  String? _email;
  String? _password;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  //late DatabaseService _db;

  final _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    final appleSiginAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pageTitle(),
              SizedBox(
                height: _deviceHeight * 0.04,
              ),
              _loginForm(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _loginButton(),
              if (appleSiginAvailable.isAvailable)
                SizedBox(
                  height: _deviceHeight * 0.04,
                ),
              if (appleSiginAvailable.isAvailable) _appleLoginButton(),
              SizedBox(
                height: _deviceHeight * 0.04,
              ),
              _googleLoginButton(),
              SizedBox(
                height: _deviceHeight * 0.04,
              ),
              _registerAccountLink(),
              SizedBox(
                height: _deviceHeight * 0.04,
              ),
              _forgetPasswordLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Container(
      height: _deviceHeight * 0.10,
      child: Text(
        'WeBike',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: _deviceHeight * 0.16,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _email = _value.trim();
                });
              },
              regEx:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: "Email",
              obscureText: false,
            ),
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _password = _value;
                });
              },
              regEx: r".{8,}",
              hintText: "Password",
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return RoundedButton(
        name: "Login",
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.65,
        onPressed: () {
          if (_loginFormKey.currentState!.validate()) {
            _loginFormKey.currentState!.save();
            // ignore: avoid_print
            print("Email: $_email, Password: $_password ");
            _auth.loginUsingEmailAndPassword(_email!, _password!);
          }
        });
  }

  Widget _appleLoginButton() {
    return RoundedButton(
        name: "Signin with Apple ID",
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.65,
        onPressed: () {
          _auth.signInWithApple();
        });
  }

  Widget _googleLoginButton() {
    return RoundedButton(
        name: "Signin with Google",
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.65,
        onPressed: () {
          _auth.signInWithGoogle();
        });
  }

  Widget _registerAccountLink() {
    return GestureDetector(
      onTap: () {
        _navigation.navigateToRoute('/register');
      },
      child: Container(
        child: const Text(
          "Don't have an account?",
          style: TextStyle(
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _forgetPasswordLink() {
    return GestureDetector(
      onTap: () {
        _navigation.navigateToRoute('/resetPassword');
      },
      child: Container(
        child: const Text(
          'Forgot password?',
          style: TextStyle(
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
