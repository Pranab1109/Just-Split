import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/PreferenceService.dart';
import 'package:just_split/Services/SplitService.dart';
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
      "resolvedBills": {},
      "logs": []
    });
    rooms.doc("map").update({roomID: roomUID.id});
    await users
        .doc(user.uid)
        .collection("rooms")
        .add({
          "roomID": roomID,
          "roomName": roomName,
          "time": Timestamp.now(),
          "roomUID": roomUID.id,
        })
        .then((value) => print("Room Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> deleteRoom(
      {roomDocID, userRoomID, required String roomID}) async {
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
      DocumentSnapshot roomMapTemp = await rooms.doc("map").get();
      Map<String, dynamic> roomMap =
          roomMapTemp.data()! as Map<String, dynamic>;
      roomMap.remove(roomID);
      final updatedMap = rooms.doc("map");
      updatedMap.set(roomMap);
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

  Future<void> addBill(
      {required String roomDocID,
      required num amount,
      required String desc,
      String splitMode = "equal",
      List<dynamic>? splitAmong,
      Map<String, dynamic>? splitDetails}) async {
    try {
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      List bills = roomData["bills"];
      List users = roomData["users"];
      User user = authRepository.getUser()!;
      var uid = user.uid;
      var userName = await preferenceService.getAvatarName();

      Map<String, dynamic> newBill = {
        "userName": userName,
        "amount": amount,
        "desc": desc,
        "time": Timestamp.now(),
        "uid": uid,
        "active": true,
        "splitMode": splitMode,
      };

      if (splitAmong != null) newBill["splitAmong"] = splitAmong;
      if (splitDetails != null) newBill["splitDetails"] = splitDetails;

      bills.add(newBill);
      
      // Recalculate total spent from all active non-settlement bills
      num total = bills.where((b) => (b["active"] ?? true) && !(b["isSettlement"] ?? false))
                       .fold(0, (sum, b) => sum + (b["amount"] ?? 0));

      // Auto-compute live settlements
      SplitService splitService = SplitService(bills: bills, users: users);
      List<List<dynamic>> liveSettlementsList =
          splitService.calculateLiveSettlements();

      Map<String, dynamic> liveSettlementsMap = {};
      for (var tr in liveSettlementsList) {
        liveSettlementsMap['${tr[0]}:${tr[1]}'] = tr[2];
      }

      await rooms.doc(roomDocID).update({
        "bills": bills,
        "totalSpent": total,
        "liveSettlements": liveSettlementsMap
      });
    } catch (e) {
      print(e);
      throw Exception('Failed to add bill');
    }
  }

  Future<void> updateBill(
      {required String roomDocID,
      required int billIndex,
      required num amount,
      required String desc,
      String splitMode = "equal",
      List<dynamic>? splitAmong,
      Map<String, dynamic>? splitDetails}) async {
    try {
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      List bills = roomData["bills"];
      List users = roomData["users"];

      num oldAmount = bills[billIndex]["amount"] ?? 0;
      String oldDesc = bills[billIndex]["desc"] ?? "";
      List oldSplitAmong = bills[billIndex]["splitAmong"] ?? [];

      bills[billIndex]["amount"] = amount;
      bills[billIndex]["desc"] = desc;
      bills[billIndex]["splitMode"] = splitMode;

      if (splitAmong != null) bills[billIndex]["splitAmong"] = splitAmong;
      if (splitDetails != null) bills[billIndex]["splitDetails"] = splitDetails;

      // Logging logic
      String userName = await preferenceService.getAvatarName();
      List<String> changes = [];
      if (oldAmount != amount) changes.add("amount to ₹$amount (was ₹$oldAmount)");
      if (oldDesc != desc) changes.add("description to '$desc' (was '$oldDesc')");
      
      // Detailed participant change check
      if (splitAmong != null) {
        Map userMap = roomData["userMap"] ?? {};
        List added = splitAmong.where((u) => !oldSplitAmong.contains(u)).toList();
        List removed = oldSplitAmong.where((u) => !splitAmong.contains(u)).toList();

        if (added.isNotEmpty) {
          List addedNames = added.map((u) => (userMap[u] ?? "Unknown").toString().split(' ')[0]).toList();
          changes.add("added ${addedNames.join(", ")}");
        }
        if (removed.isNotEmpty) {
          List removedNames = removed.map((u) => (userMap[u] ?? "Unknown").toString().split(' ')[0]).toList();
          changes.add("removed ${removedNames.join(", ")}");
        }
      }

      List logs = roomData["logs"] ?? [];
      if (changes.isNotEmpty) {
        logs.add({
          "msg": "$userName updated '$oldDesc' bill: ${changes.join(", ")}",
          "time": Timestamp.now()
        });
      }

      // Recalculate total spent from all active non-settlement bills
      num total = bills.where((b) => (b["active"] ?? true) && !(b["isSettlement"] ?? false))
                       .fold(0, (sum, b) => sum + (b["amount"] ?? 0));

      // Auto-compute live settlements
      SplitService splitService = SplitService(bills: bills, users: users);
      List<List<dynamic>> liveSettlementsList =
          splitService.calculateLiveSettlements();

      Map<String, dynamic> liveSettlementsMap = {};
      for (var tr in liveSettlementsList) {
        liveSettlementsMap['${tr[0]}:${tr[1]}'] = tr[2];
      }

      await rooms.doc(roomDocID).update({
        "bills": bills,
        "totalSpent": total,
        "liveSettlements": liveSettlementsMap,
        "logs": logs,
      });
    } catch (e) {
      print(e);
      throw Exception('Failed to update bill');
    }
  }

  Future<void> deleteBill(index, roomDocID) async {
    try {
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      List bills = roomData["bills"];
      num deleteAmount = bills[index]["amount"];
      String deleteDesc = bills[index]["desc"] ?? "Expense";
      bills.removeAt(index);
      
      String userName = await preferenceService.getAvatarName();
      List logs = roomData["logs"] ?? [];
      logs.add({
        "msg": "$userName deleted the '$deleteDesc' bill",
        "time": Timestamp.now()
      });

      // Recalculate total spent from all active non-settlement bills
      num total = bills.where((b) => (b["active"] ?? true) && !(b["isSettlement"] ?? false))
                       .fold(0, (sum, b) => sum + (b["amount"] ?? 0));

      // Auto-compute live settlements after deletion
      SplitService splitService = SplitService(bills: bills, users: roomData["users"]);
      List<List<dynamic>> liveSettlementsList =
          splitService.calculateLiveSettlements();

      Map<String, dynamic> liveSettlementsMap = {};
      for (var tr in liveSettlementsList) {
        liveSettlementsMap['${tr[0]}:${tr[1]}'] = tr[2];
      }

      await rooms.doc(roomDocID).update({
        "bills": bills,
        "totalSpent": total,
        "liveSettlements": liveSettlementsMap,
        "logs": logs
      });
    } catch (e) {
      print("Error deleting bill: $e");
    }
  }

  Future<void> storeResolvedBill(roomDocID, resolved) async {
    try {
      DocumentSnapshot temp = await rooms.doc(roomDocID).get();
      Map<String, dynamic> roomData = temp.data()! as Map<String, dynamic>;
      Map resolvedBills = roomData["resolvedBills"] ?? {};
      for (var v in resolved) {
        resolvedBills['${v[1]}:${v[0]}'] =
            resolvedBills['${v[1]}:${v[0]}'] == null
                ? v[2]
                : resolvedBills['${v[1]}:${v[0]}'] + v[2];
        if (resolvedBills.containsKey('${v[0]}:${v[1]}')) {
          if (resolvedBills['${v[1]}:${v[0]}'] >
              resolvedBills['${v[0]}:${v[1]}']) {
            resolvedBills['${v[1]}:${v[0]}'] =
                resolvedBills['${v[1]}:${v[0]}'] -
                    resolvedBills['${v[0]}:${v[1]}'];
            resolvedBills.remove('${v[0]}:${v[1]}');
          } else if (resolvedBills['${v[1]}:${v[0]}'] ==
              resolvedBills['${v[0]}:${v[1]}']) {
            resolvedBills.remove('${v[0]}:${v[1]}');
            resolvedBills.remove('${v[1]}:${v[0]}');
          } else {
            resolvedBills['${v[0]}:${v[1]}'] =
                resolvedBills['${v[0]}:${v[1]}'] -
                    resolvedBills['${v[1]}:${v[0]}'];
            resolvedBills.remove('${v[1]}:${v[0]}');
          }
        }
      }
      List bills = roomData["bills"];
      for (var bill in bills) {
        bill["active"] = false;
      }
      await rooms.doc(roomDocID).update({
        "resolvedBills": resolvedBills,
        "bills": bills,
      });
    } catch (e) {}
  }

  Future<void> recordPayment({
    required String roomDocID,
    required String payerUID,
    required String recipientUID,
    required num amount,
  }) async {
    final docRef = rooms.doc(roomDocID);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Room does not exist!");

      Map<String, dynamic> roomData = snapshot.data()! as Map<String, dynamic>;
      List bills = List.from(roomData["bills"] ?? []);
      List users = roomData["users"] ?? [];
      Map userMap = roomData["userMap"] ?? {};

      String payerName = userMap[payerUID] ?? "User";
      String recipientName = userMap[recipientUID] ?? "User";

      Map<String, dynamic> settlementBill = {
        "userName": payerName,
        "amount": amount,
        "desc": "💸 Settlement to $recipientName",
        "time": Timestamp.now(),
        "uid": payerUID,
        "active": true,
        "splitMode": "unequal",
        "splitAmong": [recipientUID],
        "splitDetails": {recipientUID: amount},
        "isSettlement": true,
      };

      bills.add(settlementBill);

      // Re-calculate live settlements within the transaction
      SplitService splitService = SplitService(bills: bills, users: users);
      List<List<dynamic>> liveSettlementsList =
          splitService.calculateLiveSettlements();

      Map<String, dynamic> liveSettlementsMap = {};
      for (var tr in liveSettlementsList) {
        liveSettlementsMap['${tr[0]}:${tr[1]}'] = tr[2];
      }

      transaction.update(docRef, {
        "bills": bills,
        "liveSettlements": liveSettlementsMap,
      });
    });
  }
}
