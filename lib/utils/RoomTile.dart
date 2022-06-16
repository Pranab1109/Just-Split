import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:intl/intl.dart';

Widget roomTile(BuildContext context, Map<String, dynamic> data,
    DocumentSnapshot<Object?> document, Function deleteRoom) {
  Cooloors cooloors = Cooloors();
  final DateFormat formatter = DateFormat('dd MMM yy');
  return Container(
    height: 80.0,
    width: MediaQuery.of(context).size.width * 0.8,
    decoration: BoxDecoration(
      color: cooloors.darkTileColor,
      borderRadius: const BorderRadius.all(
        Radius.circular(5.0),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data["roomName"],
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: cooloors.darkTextColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                formatter.format((data['time'] as Timestamp).toDate()),
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    color: cooloors.darkTextColor),
              ),
            ),
          ],
        ),
        IconButton(
            onPressed: () {
              var roomUID = data["roomUID"];
              var roomID = data["roomID"];
              print(roomID);
              var userRoomID = document.id;
              deleteRoom(context, roomUID, userRoomID, roomID);
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: cooloors.darkTextColor,
            ))
      ],
    ),
  );
}
