import 'package:flutter/material.dart';
import 'package:just_split/utils/BlobDesign.dart';
import 'package:just_split/utils/Cooloors.dart';

Widget roomCardWidget(Size size, BuildContext context, String totalSpent,
    final String roomCode, final String roomName, copyText) {
  final Cooloors cooloors = Cooloors();
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
