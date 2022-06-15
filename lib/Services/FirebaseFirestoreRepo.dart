import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/PreferenceService.dart';
import 'package:just_split/utils/RandomCodeGenerator.dart';

class FirebaseFirestoreRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final PreferenceService preferenceService = PreferenceService();
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
    if (userExists) {
      var udet =
          await users.doc(user.uid).collection("userDetails").limit(1).get();
      var userdet = udet.docs[0].data();
      preferenceService.saveAvatarName(userdet["username"]);
      preferenceService.saveAvatarIndex(userdet["avatar"]);
      return;
    }
    DocumentSnapshot userDocMap = await rooms.doc("userMap").get();
    Map<String, dynamic> userMapTemp =
        userDocMap.data()! as Map<String, dynamic>;
    List userMap = userMapTemp["userList"];
    users.doc(user.uid).collection("userDetails").add({
      'username': username,
      'avatar': avatar, // 42
    }).then((value) async {
      print("User Added");
      userMap.add(user.uid);
      rooms.doc("userMap").update({"userList": userMap});
      await preferenceService.saveAvatarName(username);
      await preferenceService.saveAvatarIndex(avatar);
    }).catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> changeUserName(String username, User user) async {
    // Call the user's CollectionReference to add a new user
    DocumentSnapshot userDocMap = await rooms.doc("userMap").get();
    Map<String, dynamic> userMapTemp =
        userDocMap.data()! as Map<String, dynamic>;
    List userMap = userMapTemp["userList"];
    var udet =
        await users.doc(user.uid).collection("userDetails").limit(1).get();
    var docid = udet.docs[0].id;
    await users.doc(user.uid).collection("userDetails").doc(docid).set({
      "username": username,
    }, SetOptions(merge: true)).then((value) async {
      await preferenceService.saveAvatarName(username);
    }).catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> changeAvatar(int index, User user) async {
    // Call the user's CollectionReference to add a new user
    DocumentSnapshot userDocMap = await rooms.doc("userMap").get();
    Map<String, dynamic> userMapTemp =
        userDocMap.data()! as Map<String, dynamic>;
    List userMap = userMapTemp["userList"];
    var udet =
        await users.doc(user.uid).collection("userDetails").limit(1).get();
    var docid = udet.docs[0].id;
    await users.doc(user.uid).collection("userDetails").doc(docid).set({
      "avatar": index,
    }, SetOptions(merge: true)).then((value) async {
      await preferenceService.saveAvatarIndex(index);
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
    var userName = await preferenceService.getAvatarName();
    var roomUID = await rooms.add({
      "roomID": roomID,
      "roomName": roomName,
      "users": [user.uid],
      "totalSpent": 0,
      "bills": [],
      "userMap": {user.uid: userName},
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
    Map userMap = roomData["userMap"];
    final deletedRoom = rooms.doc(roomDocID);
    print(deletedRoom);
    final userDeletedRoom = users.doc(uid).collection("rooms").doc(userRoomID);
    var userCount = usersList.length;
    await userDeletedRoom.delete().catchError((e) => print(e));
    if (userCount == 1) {
      await deletedRoom.delete().catchError((e) => print(e));
    } else {
      usersList.remove(uid);
      userMap.remove(uid);
      roomData["users"] = usersList;
      roomData["userMap"] = userMap;
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
      Map userMap = roomData["userMap"];
      if (usersList.contains(uid)) {
        return {
          "success": false,
          "message": "Room already exists.",
        };
      }
      var userName = await preferenceService.getAvatarName();
      usersList.add(uid);
      userMap[uid] = userName;
      final updatedRoom = rooms.doc(roomDocID);
      roomData["users"] = usersList;
      roomData["userMap"] = userMap;
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

  Future<dynamic> getAvatar(uid) async {
    try {
      var temp = await users.doc(uid).collection("userDetails").get();
      return {
        "avatar": temp.docs[0]["avatar"],
        "username": temp.docs[0]["username"]
      };
    } catch (e) {
      return 0;
    }
  }

  Future<void> addBill({roomDocID, amount, desc}) async {
    try {
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      List bills = roomData["bills"];
      User user = authRepository.getUser()!;
      var uid = user.uid;
      var userName = await preferenceService.getAvatarName();
      bills.add({
        "userName": userName,
        "amount": amount,
        "desc": desc,
        "time": Timestamp.now(),
        "uid": uid,
        "active": true,
      });
      var total = roomData["totalSpent"];
      total = total + amount;
      await rooms
          .doc(roomDocID)
          .set({"bills": bills, "totalSpent": total}, SetOptions(merge: true));
    } catch (e) {}
  }

  Future<void> deleteBill(index, roomDocID) async {
    try {
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      List bills = roomData["bills"];
      num deleteAmount = bills[index]["amount"];
      bills.removeAt(index);
      var total = roomData["totalSpent"];
      total = total - deleteAmount;
      await rooms
          .doc(roomDocID)
          .set({"bills": bills, "totalSpent": total}, SetOptions(merge: true));
    } catch (e) {}
  }

  Future<void> storeResolvedBill(roomDocID, resolved) async {
    try {
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      var resolvedBills = roomData["resolvedBills"] ?? {};
      for (var v in resolved) {
        resolvedBills['${v[1]}:${v[0]}'] = v[2];
      }
      List bills = roomData["bills"];
      for (var bill in bills) {
        bill["active"] = false;
      }
      await rooms.doc(roomDocID).set({
        "resolvedBills": resolvedBills,
        "bills": bills,
      }, SetOptions(merge: true));
    } catch (e) {}
  }
}
