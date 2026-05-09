import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/utils/Cooloors.dart';

class BuildResolvedList extends StatelessWidget {
  final roomID;
  final uid;
  BuildResolvedList({
    super.key,
    required this.roomID,
    required this.uid,
  });
  final Cooloors cooloors = Cooloors();

  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Stream documentStream = firebaseFirestoreRepo.rooms.doc(roomID).snapshots();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Suggested Settlements",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<dynamic>(
                stream: documentStream,
                builder: (context, snapshot) {
                  var data = snapshot.data;
                  if (data == null || !data.exists) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.primary));
                  } else {
                    Map<String, dynamic> docData =
                        data.data() as Map<String, dynamic>;
                    Map userMap = docData["userMap"] ?? {};
                    var resolvedBillsMap = docData["liveSettlements"] ?? {};

                    if (resolvedBillsMap.isEmpty) {
                      return Center(
                        child: Text("All settled! 🥳",
                            style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      );
                    }

                    List resolvedBills = [];
                    resolvedBillsMap.forEach((k, v) {
                      String from = k.toString().split(":")[0];
                      String to = k.toString().split(":")[1];
                      resolvedBills.add({"from": from, "to": to, "amount": v});
                    });

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: resolvedBills.length,
                      itemBuilder: (context, index) {
                        final bill = resolvedBills[index];
                        final fromUid = bill["from"];
                        final toUid = bill["to"];
                        final fromName = userMap[fromUid] ?? "User";
                        final toName = userMap[toUid] ?? "User";
                        final amount = (bill["amount"] as num).toDouble();
                        final isPayer = uid == fromUid;
                        final isRecipient = uid == toUid;

                        return GestureDetector(
                          onTap: (isPayer || isRecipient)
                              ? () => _showRoomSettleConfirmation(
                                  context,
                                  fromUid,
                                  toUid,
                                  fromName,
                                  toName,
                                  amount,
                                  roomID)
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black, offset: Offset(4, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildUserAvatar(
                                    context,
                                    fromName,
                                    isPayer
                                        ? const Color(0xFFEF4444)
                                        : colorScheme.primary),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              fromName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: colorScheme.onSurface,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.black,
                                                size: 18),
                                          ),
                                          Flexible(
                                            child: Text(
                                              toName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: colorScheme.onSurface,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isPayer
                                            ? "You are paying $toName"
                                            : isRecipient
                                                ? "$fromName is paying you"
                                                : "Settlement flow",
                                        style: TextStyle(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${amount.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: isPayer
                                            ? const Color(0xFFEF4444)
                                            : isRecipient
                                                ? const Color(0xFF10B981)
                                                : colorScheme.onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                    if (isPayer || isRecipient)
                                      const Text("Tap to settle",
                                          style: TextStyle(
                                              color: Colors.black38,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  void _showRoomSettleConfirmation(
      BuildContext context,
      String fromUid,
      String toUid,
      String fromName,
      String toName,
      double amount,
      String roomID) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Colors.black, width: 4),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF34D399),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const Icon(Icons.handshake_rounded,
                  color: Colors.black, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              "Confirm Settlement",
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              "Record a payment of ₹${amount.toStringAsFixed(2)} from $fromName to $toName?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(3, 3))
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        RepositoryProvider.of<FirebaseFirestoreRepo>(context)
                            .recordPayment(
                          roomDocID: roomID,
                          payerUID: fromUid,
                          recipientUID: toUid,
                          amount: amount,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent),
                      child: const Text("Yes, Settle",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, String name, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: color,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}
