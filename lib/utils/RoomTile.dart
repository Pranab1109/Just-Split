import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_split/utils/Cooloors.dart';

Widget roomTile(BuildContext context, Map<String, dynamic> data,
    DocumentSnapshot<Object?> document, Function deleteRoom) {
  Cooloors cooloors = Cooloors();
  return Container(
    height: 80.0,
    width: MediaQuery.of(context).size.width * 0.8,
    decoration: const BoxDecoration(
        color: Color.fromARGB(150, 66, 66, 66),
        borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                DateTime.parse(data["time"].toDate().toString())
                    .toString()
                    .split(" ")[0],
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
              var userRoomID = document.id;
              deleteRoom(context, roomUID, userRoomID);
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: cooloors.darkTextColor,
            ))
      ],
    ),
  );
}
