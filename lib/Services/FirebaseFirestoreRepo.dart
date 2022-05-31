import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/utils/RandomCodeGenerator.dart';

class FirebaseFirestoreRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference users;
  late CollectionReference rooms;
  FirebaseFirestoreRepo() {
    users = FirebaseFirestore.instance.collection('USERS');
    rooms = FirebaseFirestore.instance.collection('ROOMS');
  }

  AuthRepository authRepository = AuthRepository();

  Future<bool> checkUserDataExist(uid) async {
    try {
      DocumentSnapshot userDocMap = await rooms.doc("userMap").get();
      Map<String, dynamic> userMapTemp =
          userDocMap.data()! as Map<String, dynamic>;
      List userMap = userMapTemp["userList"];
      if (userMap.contains(uid)) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addUser(String username, int avatar, User user) async {
    // Call the user's CollectionReference to add a new user
    bool userExists = await checkUserDataExist(user.uid);
    if (userExists) return;
    DocumentSnapshot userDocMap = await rooms.doc("userMap").get();
    Map<String, dynamic> userMapTemp =
        userDocMap.data()! as Map<String, dynamic>;
    List userMap = userMapTemp["userList"];
    users.doc(user.uid).collection("userDetails").add({
      'username': username,
      'avatar': avatar, // 42
    }).then((value) {
      print("User Added");
      userMap.add(user.uid);
      rooms.doc("userMap").update({"userList": userMap});
    }).catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addRoom(String roomName, User user) async {
    // Call the user's CollectionReference to add a new user
    String roomID = generateRandomString(6);
    DocumentSnapshot roomMapTemp = await rooms.doc("map").get();
    Map<String, dynamic> roomMap = roomMapTemp.data()! as Map<String, dynamic>;
    while (roomMap.containsKey(roomID)) {
      roomID = generateRandomString(6);
    }
    var roomUID = await rooms.add({
      "roomID": roomID,
      "roomName": roomName,
      "users": [user.uid],
      "totalSpent": 0,
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

  Future<void> deleteRoom({roomDocID, userRoomID}) async {
    AuthRepository authRepository = AuthRepository();
    var uid = authRepository.getUser()?.uid;
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

  Future<dynamic> joinRoom({roomCode}) async {
    try {
      User user = authRepository.getUser()!;
      var uid = user.uid;
      //adding the details in room
      DocumentSnapshot roomMapTemp = await rooms.doc("map").get();
      Map<String, dynamic> roomMap =
          roomMapTemp.data()! as Map<String, dynamic>;
      var roomDocID = roomMap[roomCode];
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      List usersList = roomData["users"];
      if (usersList.contains(uid)) {
        return {
          "success": false,
          "message": "Room already exists.",
        };
      }
      usersList.add(uid);
      final updatedRoom = rooms.doc(roomDocID);
      roomData["users"] = usersList;
      await updatedRoom.update(roomData);

      //adding the details in user
      await users.doc(uid).collection("rooms").add({
        "roomID": roomCode,
        "roomName": roomData["roomName"],
        "time": Timestamp.now(),
        "roomUID": roomDocID
      });
      return {
        "success": true,
        "message": "Room joined.",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Room code does not exist!",
      };
    }
  }
}
