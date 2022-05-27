import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/bloc/auth/auth_bloc.dart';
import 'package:just_split/screens/LoginPage.dart';
import 'package:just_split/screens/RoomDetailScreen.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/CreateAndJoinRoomModalSheet.dart';
import 'package:just_split/utils/RoomTile.dart';
import '../utils/OnWillPop.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key? key, required this.user}) : super(key: key);
  final User user;
  final TextEditingController roomEditingController = TextEditingController();
  final TextEditingController joinEditingController = TextEditingController();
  final Cooloors cooloors = Cooloors();
  final _formKey = GlobalKey<FormState>();
  final _formKeyTwo = GlobalKey<FormState>();
  void _signOut(context) async {
    bool signout = await onWillPop(context);
    if (signout) {
      BlocProvider.of<AuthBloc>(context).add(
        SignOutRequested(),
      );
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  void addRoom(context) {
    if (_formKey.currentState!.validate()) {
      RepositoryProvider.of<FirebaseFirestoreRepo>(context)
          .addRoom(roomEditingController.text, user);
      roomEditingController.text = "";
      Navigator.pop(context);
    }
  }

  Future<void> joinRoom(context) async {
    if (_formKeyTwo.currentState!.validate()) {
      dynamic res = await RepositoryProvider.of<FirebaseFirestoreRepo>(context)
          .joinRoom(roomCode: joinEditingController.text);
      roomEditingController.text = "";
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.down,
          padding: const EdgeInsets.all(0),
          content: Container(
            child: Center(
              child: Text(
                res["message"],
                style: TextStyle(
                    color: cooloors.lightTextColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            height: 50,
            width: MediaQuery.of(context).size.width * 0.85,
            color:
                !res["success"] ? Colors.red.shade200 : Colors.green.shade300,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void deleteRoom(context, roomUID, userRoomID) {
    RepositoryProvider.of<FirebaseFirestoreRepo>(context)
        .deleteRoom(roomDocID: roomUID, userRoomID: userRoomID);
  }

  @override
  Widget build(BuildContext context) {
    Stream documentStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid.toString())
        .collection("rooms")
        .orderBy("time", descending: true)
        .snapshots();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Just Split"),
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () {
                _signOut(context);
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: StreamBuilder<dynamic>(
                  stream: documentStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: snapshot.data!.docs
                          .map<Widget>((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        // print(data["time"]);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RoomDetailScreen(
                                        roomID: data["roomUID"],
                                        roomName: data["roomName"])));
                              },
                              child: roomTile(
                                  context, data, document, deleteRoom)),
                        );
                      }).toList(),
                    );
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    // expand: true,
                    backgroundColor: cooloors.darkBackgroundColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0))),
                    context: (context),
                    builder: (context) => createAndJoinRoomModalSheet(
                        context,
                        cooloors,
                        _formKey,
                        _formKeyTwo,
                        roomEditingController,
                        joinEditingController,
                        addRoom,
                        joinRoom));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.87,
                height: 50,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//35 Pranab
//69 Soham
//Pranab->Soham : 