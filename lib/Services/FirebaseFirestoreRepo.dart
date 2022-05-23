import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_split/Services/AuthRepo.dart';

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
    var roomUID = await rooms.add({
      "roomID": roomID,
      "roomName": roomName,
      "users": [user.uid]
    });
    rooms.doc("map").update({roomID: roomUID.id});
    await users
        .doc(user.uid)
        .collection("rooms")
        .add({
          "roomID": roomID,
          "roomName": roomName,
          "time": Timestamp.now(),
          "roomUID": roomUID.id
        })
        .then((value) => print("Room Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> deleteTask({roomDocID, userRoomID}) async {
    AuthRepository authRepository = AuthRepository();
    var uid = authRepository.getUser().uid;
    print(uid);
    DocumentSnapshot temp = await rooms.doc(roomDocID).get();
    Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
    var usersList = roomData["users"];
    final deletedRoom = rooms.doc(roomDocID);
    print(deletedRoom);
    final userDeletedRoom = users.doc(uid).collection("rooms").doc(userRoomID);
    var userCount = usersList.length;
    await userDeletedRoom.delete().catchError((e) => print(e));
    if (userCount == 1) {
      await deletedRoom.delete().catchError((e) => print(e));
    } else {
      usersList.remove(uid);
      roomData["users"] = usersList;
      deletedRoom.update(roomData);
    }
  }
}
