import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_split/utils/Cooloors.dart';

class RoomDetailScreen extends StatelessWidget {
  final dynamic roomID;
  final String roomName;
  RoomDetailScreen({Key? key, required this.roomID, required this.roomName})
      : super(key: key);
  final Cooloors cooloors = Cooloors();

  @override
  Widget build(BuildContext context) {
    Stream documentStream =
        FirebaseFirestore.instance.collection('rooms').doc(roomID).snapshots();
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
                    roomCardWidget(size),
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

  Widget roomCardWidget(Size size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: size.width,
        height: 200,
        decoration: BoxDecoration(
            color: cooloors.lightTileColor,
            borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(roomName),
            const Spacer(),
            const Center(
                child: Text(
              "₹ 20030",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26.0,
              ),
            )),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
