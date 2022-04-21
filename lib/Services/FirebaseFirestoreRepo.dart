import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFirestoreRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseFirestoreRepo();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference rooms = FirebaseFirestore.instance.collection('rooms');
  Future<void> addUser(String username, int avatar, User user) {
    // Call the user's CollectionReference to add a new user
    return users
        .doc(user.uid)
        .collection("userDetails")
        .add({
          'username': username,
          'avatar': avatar, // 42
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addRoom(String roomID, String roomName, User user) async {
    // Call the user's CollectionReference to add a new user
    await rooms.add({
      "roomID": roomID,
      "roomName": roomName,
      "users": [user.uid]
    });
    return await users
        .doc(user.uid)
        .collection("rooms")
        .add({
          "roomID": roomID,
          "roomName": roomName,
          "time": Timestamp.now(),
        })
        .then((value) => print("Room Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
