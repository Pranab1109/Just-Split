import 'package:cloud_firestore/cloud_firestore.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_split/utils/Cooloors.dart';

import '../utils/BlobDesign.dart';

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
        .collection('rooms')
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
                    roomCardWidget(size, context),
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
                    )
                  ],
                );
              }
            }),
      ),
    );
  }

  Widget roomCardWidget(Size size, BuildContext context) {
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
                  const Center(
                      child: Text(
                    "₹ 20030",
                    style: TextStyle(
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
