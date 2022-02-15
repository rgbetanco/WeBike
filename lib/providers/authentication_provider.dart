import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/chat_user.dart';
import 'package:the_apple_sign_in/scope.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';

//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late ChatUser user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
    //_auth.signOut();
    _auth.authStateChanges().listen((_user) {
      if (_user != null) {
        _databaseService.updateUserLastSeenTime(_user.uid);
        _databaseService.getUser(_user.uid).then((_snapshot) {
          Map<String, dynamic> userData =
              _snapshot.data()! as Map<String, dynamic>;
          user = ChatUser.fromJSON(
            {
              "uid": _user.uid,
              "name": userData["name"],
              "email": userData["email"],
              "image": userData["image"],
              "playbackId": userData["playbackId"],
              "streamKey": userData["streamKey"],
              "last_active": userData["last_active"]
            },
          );
          if (_user.emailVerified == true) {
            _navigationService.removeAndNavigateToRoute('/home');
          } else {
            _navigationService.removeAndNavigateToRoute('/emailverify');
          }
        });
      } else {
        _navigationService.removeAndNavigateToRoute('/login');
      }
    });
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<bool> checkEmailVerification() async {
    if (_auth.currentUser != null) {
      User user = _auth.currentUser!;
      await user.reload();
      return user.emailVerified;
    } else {
      return false;
    }
  }

  Future<void> loginUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException catch (de) {
      print(
          "Firebase Auth Exception while logging in: ${de.code}, ${de.message}");
    } catch (e) {
      print("General Exception while logging in: $e");
    }
  }

  Future<void> resetPasswordUsingEmail(String _email) async {
    try {
      await _auth.sendPasswordResetEmail(email: _email);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    } catch (e) {
      print(e);
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      UserCredential _credentials = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      return _credentials.user!.uid;
    } on FirebaseAuthException catch (de) {
      print(de.message);
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<User> signInWithApple() async {
    final result = await TheAppleSignIn.performRequests([
      const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: appleIdCredential.identityToken.toString(),
          accessToken: appleIdCredential.authorizationCode.toString(),
        );
        final userCredential = await _auth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;
        final fullName = appleIdCredential.fullName;
        if (fullName != null &&
            fullName.givenName != null &&
            fullName.familyName != null) {
          final displayName = '${fullName.givenName} ${fullName.familyName}';
          await firebaseUser.updateDisplayName(displayName);
        }
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString());
      case AuthorizationStatus.cancelled:
        throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
      default:
        throw UnimplementedError();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e.message);
      throw e;
    }
  }
}
