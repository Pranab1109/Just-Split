import 'package:flutter/material.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/utils/Cooloors.dart';

class BuildResolvedList extends StatelessWidget {
  final roomID;
  final uid;
  BuildResolvedList({
    Key? key,
    required this.roomID,
    required this.uid,
  }) : super(key: key);
  final Cooloors cooloors = Cooloors();

  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();
  @override
  Widget build(BuildContext context) {
    print(uid);
    Stream documentStream = firebaseFirestoreRepo.rooms.doc(roomID).snapshots();
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Resolved Bills",
            style: TextStyle(color: cooloors.lightTileColor, fontSize: 20.0),
            textAlign: TextAlign.left,
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
                    Map userMap = data["userMap"];
                    var resolvedBillsMap = data["resolvedBills"];

                    if (resolvedBillsMap.isEmpty) {
                      return const Center(
                        child: Text("No bills resolved."),
                      );
                    }
                    String from;
                    String to;
                    //74lah36Sy8YP9RLy3lSkiIhNlwS2
                    List resolvedBills = [];
                    resolvedBillsMap.forEach((k, v) {
                      from = k.toString().split(":")[0];
                      to = k.toString().split(":")[1];
                      resolvedBills.add({"from": from, "to": to, "amount": v});
                    });
                    return SizedBox(
                      height: size.height / 2.05,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: resolvedBills.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      color: cooloors.darkTileColor
                                          .withOpacity(0.95),
                                      border: Border.all(
                                          width: 2.0,
                                          color: uid ==
                                                  resolvedBills[index]["from"]
                                              ? const Color(0xfff07167)
                                              : uid ==
                                                      resolvedBills[index]["to"]
                                                  ? const Color(0xff87B28A)
                                                  : Colors.transparent)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            userMap[resolvedBills[index]
                                                ["from"]],
                                            style: TextStyle(
                                              color: cooloors.darkTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "to",
                                            style: TextStyle(
                                              color: cooloors.darkTextColor,
                                            ),
                                          ),
                                          Text(
                                            userMap[resolvedBills[index]["to"]],
                                            style: TextStyle(
                                              color: cooloors.darkTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₹ ' +
                                            resolvedBills[index]["amount"]
                                                .toString(),
                                        style: TextStyle(
                                            color: cooloors.darkTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      )
                                    ],
                                  )),
                            );
                          }),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }
}
