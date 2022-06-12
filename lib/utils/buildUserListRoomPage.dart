import 'package:flutter/material.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/utils/Avatars.dart';
import 'package:just_split/utils/TextStyler.dart';

class BuildUserList extends StatefulWidget {
  const BuildUserList({Key? key, required this.roomID}) : super(key: key);
  final String roomID;
  @override
  State<BuildUserList> createState() => _BuildUserListState();
}

class _BuildUserListState extends State<BuildUserList> {
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Participants",
              style: TextStyle(color: cooloors.lightTileColor, fontSize: 20.0),
              textAlign: TextAlign.left,
            ),
            const SizedBox(
              height: 12.0,
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                  stream: documentStream,
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    if (data == null) {
                      return Center(
                          child: Center(
                              child: LinearProgressIndicator(
                        color: cooloors.darkTextColor,
                      )));
                    } else {
                      userList = data["users"];
                      return ListView.builder(
                        itemCount: userList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, i) {
                          return FutureBuilder<dynamic>(
                              future: firebaseFirestoreRepo
                                  .getAvatar(userList[i].toString()),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return const LinearProgressIndicator();
                                }
                                return Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5.0),
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        // color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: avatars[snapshot.data["avatar"]],
                                      ),
                                    ),
                                    Text(
                                      snapshot.data["username"],
                                      style: TextStyle(
                                          color: cooloors.darkTextColor),
                                    ),
                                  ],
                                );
                              });
                        },
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
