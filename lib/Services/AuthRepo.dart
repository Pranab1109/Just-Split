import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just_split/Services/PreferenceService.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final PreferenceService preferenceService = PreferenceService();
  Future<User?> signUp(
      {required String email, required String password}) async {
    try {
      var usercred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      preferenceService.saveAuthStatus(true);
      return usercred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      preferenceService.saveAuthStatus(false);
    } catch (e) {
      print(e);
      preferenceService.saveAuthStatus(false);
    }
    return null;
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      var userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      preferenceService.saveAuthStatus(true);
      return userCred.user!;
    } on FirebaseAuthException catch (e) {
      preferenceService.saveAuthStatus(false);
      print(e);
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      preferenceService.saveAvatarIndex(null);
      preferenceService.saveAvatarName(null);
      await _firebaseAuth.signOut();
      preferenceService.saveAuthStatus(false);
    } catch (e) {
      print(e);
      // throw Exception(e);
    }
  }

  Future<User?> signUpWithGoogle() async {
    try {
      UserCredential usercred;

      if (kIsWeb) {
        // On Web: use Firebase Auth's built-in Google popup
        // This does NOT use the google_sign_in package at all
        print("WEB: Using signInWithPopup");
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        usercred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        print("WEB: signInWithPopup succeeded");
      } else {
        // On Mobile: use the google_sign_in v7 singleton API
        print("MOBILE: Using GoogleSignIn.instance.authenticate");
        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: (await googleUser.authorizationClient
                  .authorizeScopes(['email', 'profile']))
              .accessToken,
          idToken: googleAuth.idToken,
        );
        usercred =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      preferenceService.saveAuthStatus(true);
      return usercred.user;
    } catch (e) {
      preferenceService.saveAuthStatus(false);
      print("Google Sign-In error (kIsWeb=$kIsWeb): $e");
      return null;
    }
  }

  User? getUser() {
    return FirebaseAuth.instance.currentUser!;
  }
}
