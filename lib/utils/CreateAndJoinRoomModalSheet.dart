import 'package:flutter/material.dart';
import 'package:just_split/utils/MyTextFieldTwo.dart';

Widget createAndJoinRoomModalSheet(
    BuildContext context,
    cooloors,
    _formKey,
    _formKeyTwo,
    roomEditingController,
    joinEditingController,
    addRoom,
    joinRoom,
    isJoin) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        // height: 700.0,
        decoration: const BoxDecoration(
            // color: Color.fromARGB(255, 24, 24, 24),
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5.0),
          topRight: Radius.circular(5.0),
        )),
        child: Column(
          children: [
            !isJoin
                ? Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "Create new room",
                            style: TextStyle(
                                // color: Colors.white,
                                color: cooloors.darkTextColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MyTextFieldTwo(
                            hintText: "Room name",
                            inputController: roomEditingController,
                            errorText: "Enter a valid name",
                            // formkey: _formKey,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: ElevatedButton(
                              onPressed: () {
                                //todo : add room
                                addRoom(context);
                              },
                              child: SizedBox(
                                height: 50.0,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: const Center(
                                  child: Text(
                                    "Create Room",
                                    style: TextStyle(
                                        // color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _formKeyTwo,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(
                          height: 5.0,
                          // color: Colors.white,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "Join room",
                            style: TextStyle(
                                // color: Colors.white,
                                color: cooloors.darkTextColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MyTextFieldTwo(
                            hintText: "Room Code",
                            inputController: joinEditingController,
                            errorText: "Enter a room code.",
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: ElevatedButton(
                              onPressed: () async {
                                joinRoom(context);
                              },
                              child: SizedBox(
                                height: 50.0,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: const Center(
                                  child: Text(
                                    "Join Room",
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
      ),
    ],
  );
}
