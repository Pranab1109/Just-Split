import 'package:cloud_firestore/cloud_firestore.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_split/utils/Cooloors.dart';

import '../utils/BlobDesign.dart';
import '../utils/MyTextFieldTwo.dart';

class RoomDetailScreen extends StatelessWidget {
  final dynamic roomID;
  final String roomName;
  final String roomCode;
  RoomDetailScreen(
      {Key? key,
      required this.roomID,
      required this.roomName,
      required this.roomCode})
      : super(key: key);
  final Cooloors cooloors = Cooloors();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController joinEditingController = TextEditingController();

  void copyText(context) {
    Clipboard.setData(ClipboardData(text: roomCode.toString()))
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Room Code Copied"),
              behavior: SnackBarBehavior.floating,
            )));
  }

  @override
  Widget build(BuildContext context) {
    Stream documentStream = firebase.FirebaseFirestore.instance
        .collection('ROOMS')
        .doc(roomID)
        .snapshots();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<dynamic>(
            stream: documentStream,
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Column(
                  children: [
                    roomCardWidget(
                        size, context, data["totalSpent"].toString()),
                    Expanded(
                      child: ListView.builder(
                          itemCount: data["users"].length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, i) {
                            return Text(
                              data["users"][i].toString(),
                              style: const TextStyle(color: Colors.amber),
                            );
                          }),
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
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25.0))),
                              context: (context),
                              builder: (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                            // color: Color.fromARGB(255, 24, 24, 24),
                                            borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5.0),
                                          topRight: Radius.circular(5.0),
                                        )),
                                        child: Column(
                                          children: [
                                            Form(
                                              key: _formKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child: Text(
                                                      "Add Bill",
                                                      style: TextStyle(
                                                          // color: Colors.white,
                                                          color: cooloors
                                                              .darkTextColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 12.0,
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: MyTextFieldTwo(
                                                      hintText: "Amount",
                                                      inputController:
                                                          joinEditingController,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: MyTextFieldTwo(
                                                      hintText: "Description",
                                                      inputController:
                                                          joinEditingController,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom,
                                                      left: 8.0,
                                                      right: 8.0,
                                                    ),
                                                    child: ElevatedButton(
                                                        onPressed: () async {
                                                          //todo : join room
                                                        },
                                                        child: SizedBox(
                                                          height: 50.0,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          child: const Center(
                                                            child: Text(
                                                              "Send",
                                                              style: TextStyle(
                                                                  // color: Colors.black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      18.0),
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
                                          ],
                                        ),
                                      )
                                    ],
                                  ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: MediaQuery.of(context).size.width * 0.87,
                          height: 50,
                          child: const Center(
                              child: Text(
                            "Add Bill",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          )),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
    );
  }

  Widget roomCardWidget(Size size, BuildContext context, String totalSpent) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          width: size.width,
          height: 200,
          color: cooloors.lightTileColor,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              ...designs,
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        roomCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          copyText(context);
                        },
                        icon: const Icon(Icons.copy),
                        splashRadius: 32.0,
                        splashColor: Colors.black87,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                      child: Text(
                    "₹ $totalSpent",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26.0,
                    ),
                  )),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Text(
                        roomName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
