import 'package:firebase_auth/firebase_auth.dart';
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
      await _firebaseAuth.signOut();
      preferenceService.saveAuthStatus(false);
    } catch (e) {
      print(e);
      // throw Exception(e);
    }
  }

  Future<User?> signUpWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      var usercred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      preferenceService.saveAuthStatus(true);

      return usercred.user;
    } catch (e) {
      preferenceService.saveAuthStatus(false);
      print("error : " + e.toString());
      return null;
      // throw Exception(e.toString());
    }
    return null;
  }

  User? getUser() {
    return FirebaseAuth.instance.currentUser!;
  }
}
