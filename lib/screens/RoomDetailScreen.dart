import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/RoomCardWidget.dart';
import 'package:just_split/utils/buildUserListRoomPage.dart';

import '../utils/MyTextFieldTwo.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomID;
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
  final ScrollController _controller = ScrollController();
  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    needScroll = false;
  }

  void copyText(context) {
    Clipboard.setData(ClipboardData(text: roomCode.toString()))
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Room Code Copied"),
              behavior: SnackBarBehavior.floating,
              duration: Duration(milliseconds: 700),
            )));
  }

  final user = AuthRepository().getUser();

  void addBill(context) async {
    if (_formKey.currentState!.validate()) {
      RepositoryProvider.of<FirebaseFirestoreRepo>(context).addBill(
          amount: int.parse(amountEditingController.text),
          desc: descEditingController.text,
          roomDocID: roomID,
          userName: user?.displayName);
      descEditingController.text = "";
      amountEditingController.text = "";
      Navigator.pop(context);
    }
  }

  void deleteBill(context, index) async {
    RepositoryProvider.of<FirebaseFirestoreRepo>(context)
        .deleteBill(index, roomID);
  }

  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();
  bool needScroll = false;
  bool firstTime = true;
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
              // if (needScroll &&
              //     !firstTime &&
              //     _controller.offset == _controller.position.maxScrollExtent) {
              //   print(_controller.offset);
              //   print(_controller.position.maxScrollExtent);
              //   _scrollDown();
              // }
              var data = snapshot.data;
              if (data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (firstTime ||
                    _controller.position.maxScrollExtent ==
                        _controller.offset) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _controller.animateTo(
                      _controller.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                    firstTime = false;
                  });
                  needScroll = true;
                }
                return Column(
                  children: [
                    roomCardWidget(size, context, data["totalSpent"].toString(),
                        roomCode, roomName, copyText),
                    Expanded(
                      child: ListView.builder(
                          controller: _controller,
                          itemCount: data["bills"].length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            var item = data["bills"][index];
                            // if (_controller.hasClients &&
                            //     _controller.positions.isNotEmpty) {
                            //   _controller
                            //       .jumpTo(_controller.position.maxScrollExtent);
                            // }

                            return Align(
                              alignment: item["uid"] == uid
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0)),
                                  enableFeedback: true,
                                  splashColor: Colors.white,
                                  highlightColor: Colors.white,
                                  onLongPress: () async {
                                    if (item["uid"] == uid) {
                                      var delete =
                                          await onDeleteBillPop(context);
                                      if (delete) {
                                        deleteBill(context, index);
                                      }
                                    }
                                  },
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: size.width * 0.35,
                                        maxWidth: size.width * 0.6),
                                    child: Container(
                                      padding: const EdgeInsets.all(5.0),
                                      // width: size.width * 0.35,
                                      decoration: BoxDecoration(
                                        color: cooloors.darkTileColor
                                            .withOpacity(0.99),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["userName"].toString(),
                                            style: TextStyle(
                                                color: cooloors.lightTileColor,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            "₹ ${item["amount"].toString()}",
                                            style: TextStyle(
                                                color: cooloors.darkTextColor,
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            item["desc"].toString(),
                                            style: TextStyle(
                                              color: cooloors.darkSubTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                                      isNum: true,
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
}

Future<bool> onDeleteBillPop(BuildContext context) async {
  bool signout = false;
  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.black87,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Bill?",
                    style: TextStyle(color: Colors.white),
                    // style: subtitle1White,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            //color: blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //color: blue,
                          child: const Center(
                              child: Text(
                            "No",
                            style: TextStyle(color: Colors.white),
                            // style: button.copyWith(color: blue),
                          )),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          signout = true;
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //color: blue,
                          child: const Center(
                              child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.white),
                            // style: button,
                          )),
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          ));
  return signout;
}
