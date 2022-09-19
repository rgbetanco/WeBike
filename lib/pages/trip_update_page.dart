import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/providers/trips_page_provider.dart';
import 'package:pizarro_app/services/mux_service.dart';
import 'package:pizarro_app/widgets/rounded_image.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

//Services
import '../models/trip.dart';
import '../providers/trip_page_provider.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//Providers
import '../providers/authentication_provider.dart';

class TripUpdatePage extends StatefulWidget {
  Trip trip;

  TripUpdatePage({Key? key, required this.trip}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return TripUpdatePageState();
  }
}

class TripUpdatePageState extends State<TripUpdatePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  final _tripUpdateFormKey = GlobalKey<FormState>();

  String? _title;

  PlatformFile? _profileImage;

  late FirebaseAuth _auth;
  late AuthenticationProvider _authenticationProvider;
  late TripPageProvider _tripPageProvider;
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
    _tripPageProvider = TripPageProvider();
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
              _tripForm(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _tripButton(),
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
            imagePath: widget.trip.imageURL,
            size: _deviceHeight * 0.15,
          );
        }
      }(),
    );
  }

  Widget _tripForm() {
    return Container(
      height: _deviceHeight * 0.25,
      child: Form(
        key: _tripUpdateFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _title = _value;
                });
              },
              regEx: r'.{3,}',
              hintText: 'Title',
              obscureText: false,
              initialValue: widget.trip.title,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripButton() {
    return RoundedButton(
        name: "Trip",
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.65,
        onPressed: () async {
          if (_tripUpdateFormKey.currentState!.validate()) {
            try {
              _tripUpdateFormKey.currentState!.save();
              if (_title != null) {
                widget.trip.title = _title!;
              }

              String? _imageURL = DEFAULT_TRIP_IMAGE;
              if (_profileImage != null) {
                _imageURL =
                    await _cloudStorageService.saveTripProfileImageToStorage(
                        widget.trip.uid, _profileImage!);
                if (_imageURL != null) {
                  widget.trip.imageURL = _imageURL;
                }
              }

              await _tripPageProvider.updateTrip(widget.trip);
            } on FirebaseException catch (ex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error updating trip, Error: ${ex.message}"),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error updating trip, Error: ${e.toString()}"),
                ),
              );
            }
          }
        });
  }
}
