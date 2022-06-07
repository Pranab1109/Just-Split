import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/buildUserListRoomPage.dart';

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
  final TextEditingController amountEditingController = TextEditingController();
  final TextEditingController descEditingController = TextEditingController();

  void copyText(context) {
    Clipboard.setData(ClipboardData(text: roomCode.toString()))
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Room Code Copied"),
              behavior: SnackBarBehavior.floating,
            )));
  }

  final user = AuthRepository().getUser();

  void addBill(context) async {
    if (_formKey.currentState!.validate()) {
      RepositoryProvider.of<FirebaseFirestoreRepo>(context).addBill(
          amount: amountEditingController.text,
          desc: descEditingController.text,
          roomDocID: roomID,
          userName: user?.displayName);
      descEditingController.text = "";
      amountEditingController.text = "";
      Navigator.pop(context);
    }
  }

  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();

  @override
  Widget build(BuildContext context) {
    final uid = user?.uid;
    Stream documentStream = firebaseFirestoreRepo.rooms.doc(roomID).snapshots();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        backgroundColor: cooloors.darkAppBarColor,
        child: SizedBox(
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: buildUserList(
                roomID: roomID,
              )),
            ],
          ),
        ),
      ),
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
                          itemCount: data["bills"].length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, i) {
                            var item = data["bills"][i];
                            return Align(
                              alignment: item["uid"] == uid
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  // padding: const EdgeInsets.all(5.0),
                                  width: 100,
                                  color: Colors.white,

                                  // decoration: const BoxDecoration(),
                                  child: Column(
                                    children: [
                                      Text(item["userName"].toString()),
                                      Text(item["amount"].toString()),
                                      Text(item["desc"].toString()),
                                    ],
                                  ),
                                ),
                              ),
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
                                                          amountEditingController,
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
                                                          descEditingController,
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
                                                          addBill(context);
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.menu_rounded)),
                      Row(
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
