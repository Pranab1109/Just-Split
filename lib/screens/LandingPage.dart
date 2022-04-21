import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/bloc/auth/auth_bloc.dart';
import 'package:just_split/screens/LoginPage.dart';
import 'package:just_split/utils/MyTextFieldTwo.dart';
import 'package:just_split/utils/RandomCodeGenerator.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key? key, required this.user}) : super(key: key);
  final User user;
  final TextEditingController roomEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKeyTwo = GlobalKey<FormState>();
  void _signOut(context) {
    BlocProvider.of<AuthBloc>(context).add(
      SignOutRequested(),
    );
  }

  void addRoom(context) {
    if (_formKey.currentState!.validate()) {
      RepositoryProvider.of<FirebaseFirestoreRepo>(context)
          .addRoom(generateRandomString(6), roomEditingController.text, user);
      roomEditingController.text = "";
      Navigator.pop(context);
    }
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Just Split"),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  // expand: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0))),
                  context: (context),
                  builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            // height: 700.0,
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 24, 24, 24),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  topRight: Radius.circular(5.0),
                                )),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      "Create new room",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyTextFieldTwo(
                                      hintText: "Room name",
                                      inputController: roomEditingController,
                                      // formkey: _formKey,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.white),
                                        onPressed: () {
                                          //todo : add room
                                          addRoom(context);
                                        },
                                        child: SizedBox(
                                          height: 50.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: const Center(
                                            child: Text(
                                              "Create Room",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0),
                                            ),
                                          ),
                                        )),
                                  ),
                                  const Divider(
                                    height: 5.0,
                                    color: Colors.white,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      "Join room",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyTextFieldTwo(
                                      hintText: "Room Code",
                                      inputController: roomEditingController,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.white),
                                        onPressed: () {
                                          //todo : add room
                                          addRoom(context);
                                        },
                                        child: SizedBox(
                                          height: 50.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: const Center(
                                            child: Text(
                                              "Join Room",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0),
                                            ),
                                          ),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ));
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
              onPressed: () {
                _signOut(context);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder<dynamic>(
          stream: documentStream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
              children:
                  snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                // print(data["time"]);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 80.0,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(150, 66, 66, 66),
                        borderRadius: BorderRadius.all(Radius.circular(2.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            data["roomName"],
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            DateTime.parse(data["time"].toDate().toString())
                                .toString()
                                .split(" ")[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                // return ListTile(
                //   title: Text(
                //     data["roomName"],
                //     style: const TextStyle(color: Colors.white),
                //   ),
                // );
              }).toList(),
            );
          }),
    );
  }
}


//35 Pranab
//69 Soham
//Pranab->Soham : 