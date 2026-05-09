import 'package:flutter/material.dart';
import 'package:just_split/utils/MyTextFieldTwo.dart';
import 'package:just_split/utils/Cooloors.dart';

Widget createAndJoinRoomModalSheet(
    BuildContext context,
    cooloors,
    formKey,
    formKeyTwo,
    roomEditingController,
    joinEditingController,
    addRoom,
    joinRoom,
    isJoin) {
  final colorScheme = Theme.of(context).colorScheme;
  
  return Container(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      left: 20,
      right: 20,
      top: 24,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: const Border(top: BorderSide(color: Colors.black, width: 4)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        !isJoin
            ? Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create new room",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextFieldTwo(
                      hintText: "Room name",
                      inputController: roomEditingController,
                      errorText: "Enter a valid name",
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: Cooloors.neoShadow,
                      ),
                      child: ElevatedButton(
                        onPressed: () => addRoom(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          "Create Room",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Form(
                key: formKeyTwo,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Join room",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextFieldTwo(
                      hintText: "Room Code",
                      inputController: joinEditingController,
                      errorText: "Enter a room code.",
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: Cooloors.neoShadow,
                      ),
                      child: ElevatedButton(
                        onPressed: () => joinRoom(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          "Join Room",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    ),
  );
}
