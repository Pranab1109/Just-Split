import 'package:flutter/material.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/utils/Avatars.dart';

class buildUserList extends StatefulWidget {
  const buildUserList({Key? key, required this.roomID}) : super(key: key);
  final String roomID;
  @override
  State<buildUserList> createState() => _buildUserListState();
}

class _buildUserListState extends State<buildUserList> {
  List<dynamic> userList = [];

  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();
  late Stream documentStream;
  @override
  void initState() {
    documentStream = firebaseFirestoreRepo.rooms.doc(widget.roomID).snapshots();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: documentStream,
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            userList = data["users"];
            print(userList);
            return ListView.builder(
              itemCount: userList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                return FutureBuilder<Object>(
                    future:
                        firebaseFirestoreRepo.getAvatar(userList[i].toString()),
                    builder: (context, snapshot) {
                      print(snapshot.data);
                      return Container(
                        padding: const EdgeInsets.all(5.0),
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: avatars[0],
                        ),
                      );
                    });
              },
            );
          }
        });
  }
}
