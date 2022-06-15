import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/AvatarRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/Services/SplitService.dart';
import 'package:just_split/utils/BuildResolvedBills.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/RoomCardWidget.dart';
import 'package:just_split/utils/buildUserListRoomPage.dart';
import 'package:intl/intl.dart';
import 'package:just_split/utils/onDeleteWillPop.dart';
import 'dart:math';
import '../utils/MyTextFieldTwo.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomID;
  final String roomName;
  final String roomCode;
  RoomDetailScreen({
    Key? key,
    required this.roomID,
    required this.roomName,
    required this.roomCode,
  }) : super(key: key);
  final Cooloors cooloors = Cooloors();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountEditingController = TextEditingController();
  final TextEditingController descEditingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  void _scrollDown() {
    if (firstTime) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
      firstTime = false;
      return;
    }
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
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

  void addBill(context, name) async {
    if (_formKey.currentState!.validate()) {
      RepositoryProvider.of<FirebaseFirestoreRepo>(context).addBill(
        amount: num.parse(amountEditingController.text),
        desc: descEditingController.text,
        roomDocID: roomID,
      );
      descEditingController.text = "";
      amountEditingController.text = "";
      Navigator.pop(context);
      firstTime = true;
      _scrollDown();
    }
  }

  void deleteBill(context, index) async {
    RepositoryProvider.of<FirebaseFirestoreRepo>(context)
        .deleteBill(index, roomID);
  }

  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();
  final DateFormat formatter = DateFormat('dd MMM yy');
  final DateFormat timeformatter = DateFormat('jm');
  bool firstTime = true;
  Map userMap = {};
  @override
  Widget build(BuildContext context) {
    final uid = user?.uid;
    Stream documentStream = firebaseFirestoreRepo.rooms.doc(roomID).snapshots();
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
                if (firstTime ||
                    _controller.position.maxScrollExtent ==
                        _controller.offset) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _scrollDown();
                  });
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
                            userMap[item["uid"]] = item["userName"];
                            Widget separator = index == 0
                                ? Text(
                                    formatter.format((data["bills"][index]
                                            ['time'] as Timestamp)
                                        .toDate()),
                                    style: TextStyle(
                                        color: cooloors.darkSubTextColor),
                                  )
                                : const SizedBox();
                            if (index != 0 &&
                                formatter.format((data["bills"][index]['time']
                                            as Timestamp)
                                        .toDate()) !=
                                    formatter.format((data["bills"][index - 1]
                                            ['time'] as Timestamp)
                                        .toDate())) {
                              separator = Text(
                                formatter.format(
                                    (data["bills"][index]['time'] as Timestamp)
                                        .toDate()),
                                style:
                                    TextStyle(color: cooloors.darkSubTextColor),
                              );
                            }
                            return Column(
                              children: [
                                separator,
                                Align(
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
                                        if (item["uid"] == uid &&
                                            item["active"] == true) {
                                          var delete =
                                              await onDeleteBillPop(context);
                                          if (delete) {
                                            deleteBill(context, index);
                                          }
                                        }
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                            minWidth: size.width * 0.35,
                                            maxWidth: size.width * 0.6),
                                        padding: const EdgeInsets.all(5.0),
                                        // width: size.width * 0.35,
                                        decoration: BoxDecoration(
                                          color: item["active"]
                                              ? cooloors.darkTileColor
                                                  .withOpacity(0.99)
                                              : cooloors.inactiveColor
                                                  .withOpacity(0.80),
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
                                                  color:
                                                      cooloors.lightTileColor,
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
                                                color:
                                                    cooloors.darkSubTextColor,
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              width: max(
                                                  min(
                                                      item["desc"].length *
                                                          12.0,
                                                      size.width * 0.7),
                                                  size.width * 0.35),
                                              child: Text(
                                                timeformatter
                                                    .format((item['time']
                                                            as Timestamp)
                                                        .toDate())
                                                    .toString(),
                                                style: TextStyle(
                                                  color:
                                                      cooloors.darkSubTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      // expand: true,
                                      backgroundColor:
                                          cooloors.darkBackgroundColor,
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
                                                    borderRadius:
                                                        BorderRadius.only(
                                                  topLeft: Radius.circular(5.0),
                                                  topRight:
                                                      Radius.circular(5.0),
                                                )),
                                                child: Column(
                                                  children: [
                                                    Form(
                                                      key: _formKey,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 20.0),
                                                            child: Text(
                                                              "Add Bill",
                                                              style: TextStyle(
                                                                  // color: Colors.white,
                                                                  color: cooloors
                                                                      .darkTextColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 12.0,
                                                                    left: 8.0,
                                                                    right: 8.0),
                                                            child:
                                                                MyTextFieldTwo(
                                                              isNum: true,
                                                              hintText:
                                                                  "Amount",
                                                              inputController:
                                                                  amountEditingController,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8.0,
                                                                    right: 8.0),
                                                            child:
                                                                MyTextFieldTwo(
                                                              hintText:
                                                                  "Description",
                                                              inputController:
                                                                  descEditingController,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom,
                                                              left: 8.0,
                                                              right: 8.0,
                                                            ),
                                                            child:
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      addBill(
                                                                          context,
                                                                          context
                                                                              .read<AvatarRepo>()
                                                                              .userName);
                                                                    },
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          50.0,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.9,
                                                                      child:
                                                                          const Center(
                                                                        child:
                                                                            Text(
                                                                          "Send",
                                                                          style: TextStyle(
                                                                              // color: Colors.black,
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
                                                  ],
                                                ),
                                              )
                                            ],
                                          ));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  // width: MediaQuery.of(context).size.width * 0.87,
                                  height: 50,
                                  child: const Center(
                                      child: Text(
                                    "Add Bill",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  )),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  SplitService splitService = SplitService(
                                      bills: data["bills"],
                                      users: data["users"]);
                                  splitService.split(roomID);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  height: 50,
                                  width: 50,
                                  child: const Icon(
                                      Icons.check_circle_outline_rounded),
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
      drawer: Drawer(
        backgroundColor: cooloors.darkAppBarColor,
        child: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: BuildUserList(
                roomID: roomID,
              )),
              Expanded(child: BuildResolvedList(roomID: roomID))
            ],
          ),
        ),
      ),
    );
  }
}
