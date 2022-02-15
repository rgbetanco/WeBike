import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/services/navigation_service.dart';
import 'package:pizarro_app/widgets/rounded_button.dart';
import 'package:provider/provider.dart';

//Widgets
import '../widgets/custom_input_fields.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordPageState();
  }
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  String? _email;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  final _ResetPasswordFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pageTitle(),
            SizedBox(
              height: _deviceHeight * 0.04,
            ),
            _ResetPasswordForm(),
            SizedBox(
              height: _deviceHeight * 0.001,
            ),
            _ResetPasswordButton(),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Container(
      height: _deviceHeight * 0.10,
      child: Text(
        'Reset password',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _ResetPasswordForm() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Form(
        key: _ResetPasswordFormKey,
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
          ],
        ),
      ),
    );
  }

  Widget _ResetPasswordButton() {
    return RoundedButton(
        name: "Reset Password",
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.65,
        onPressed: () {
          if (_ResetPasswordFormKey.currentState!.validate()) {
            _ResetPasswordFormKey.currentState!.save();
            _auth.resetPasswordUsingEmail(_email!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Password sent to your email, please check"),
              ),
            );
            _navigation.removeAndNavigateToRoute('/login');
          }
        });
  }
}
