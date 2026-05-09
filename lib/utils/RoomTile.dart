import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:intl/intl.dart';

Widget roomTile(BuildContext context, Map<String, dynamic> data,
    DocumentSnapshot<Object?> document, Function deleteRoom) {
  final colorScheme = Theme.of(context).colorScheme;
  final DateFormat formatter = DateFormat('dd MMM yy');
  
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black, width: 3),
      boxShadow: Cooloors.neoShadow,
    ),
    child: Row(
      children: [
        Hero(
          tag: 'room_icon_${data["roomUID"]}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(Icons.meeting_room_rounded, color: colorScheme.primary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'room_name_${data["roomUID"]}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    data["roomName"],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Active ${formatter.format((data['time'] as Timestamp).toDate())}",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            var roomUID = data["roomUID"];
            var roomID = data["roomID"];
            var userRoomID = document.id;
            deleteRoom(context, roomUID, userRoomID, roomID);
          },
          icon: Icon(
            Icons.delete_rounded,
            color: colorScheme.error,
            size: 24,
          ),
        )
      ],
    ),
  );
}
