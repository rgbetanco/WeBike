import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/services/mux_service.dart';
import 'package:pizarro_app/widgets/rounded_image.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

//Services
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//Providers
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  final _registerFormKey = GlobalKey<FormState>();

  String? _name;
  String? _email;
  String? _password;

  PlatformFile? _profileImage;

  late FirebaseAuth _auth;
  late AuthenticationProvider _authenticationProvider;
  late CloudStorageService _cloudStorageService;
  late DatabaseService _db;
  late NavigationService _navigationService;
  late MuxService _mux;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _auth = FirebaseAuth.instance;
    _authenticationProvider = Provider.of<AuthenticationProvider>(context);
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    _db = GetIt.instance.get<DatabaseService>();
    _mux = GetIt.instance.get<MuxService>();
    _navigationService = GetIt.instance.get<NavigationService>();
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.78,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profileImageField(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerForm(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then((_file) {
          setState(() {
            _profileImage = _file;
          });
        });
      },
      child: () {
        if (_profileImage != null) {
          return RoundedImageFile(
            key: UniqueKey(),
            image: _profileImage!,
            size: _deviceHeight * 0.15,
          );
        } else {
          return RoundedImageNetwork(
            key: UniqueKey(),
            imagePath: DEFAULT_PROFILE_IMAGE,
            size: _deviceHeight * 0.15,
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return Container(
      height: _deviceHeight * 0.25,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _name = _value;
                  });
                },
                regEx: r'.{3,}',
                hintText: 'Name',
                obscureText: false),
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _email = _value.trim();
                  });
                },
                regEx:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: 'Email',
                obscureText: false),
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _password = _value;
                  });
                },
                regEx: r'.{8,}',
                hintText: 'Password',
                obscureText: true),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return RoundedButton(
        name: "Register",
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.65,
        onPressed: () async {
          if (_registerFormKey.currentState!.validate()) {
            try {
              _registerFormKey.currentState!.save();
              String? _uid = await _authenticationProvider
                  .registerUserUsingEmailAndPassword(_email!, _password!);

              if (_uid != null) {
                String? _imageURL = DEFAULT_PROFILE_IMAGE;
                if (_profileImage != null) {
                  _imageURL = await _cloudStorageService.saveUserImageToStorage(
                      _uid, _profileImage!);
                }
                await _db.createUser(_uid, _email!, _name!, _imageURL!, _mux);
                await _auth.signOut();

                await _authenticationProvider.loginUsingEmailAndPassword(
                    _email!, _password!);
                User? user = _authenticationProvider.getCurrentUser();
                if (user != null) {
                  user.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Confirmation email sent, please check and verify"),
                    ),
                  );
                }
              }
            } on FirebaseException catch (ex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error registering user, Error: ${ex.message}"),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text("Error registering user, Error: ${e.toString()}"),
                ),
              );
            }
          }
        });
  }
}
