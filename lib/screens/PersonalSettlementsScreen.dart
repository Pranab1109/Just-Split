import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:rxdart/rxdart.dart';

class PersonalSettlementsScreen extends StatefulWidget {
  final User user;
  const PersonalSettlementsScreen({super.key, required this.user});

  @override
  State<PersonalSettlementsScreen> createState() => _PersonalSettlementsScreenState();
}

class _PersonalSettlementsScreenState extends State<PersonalSettlementsScreen> {
  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();
  Stream<List<Map<String, dynamic>>>? _combinedRoomStream;

  @override
  void initState() {
    super.initState();
    _initRoomStream();
  }

  void _initRoomStream() {
    // 1. Get the list of room references for this user
    final roomRefsStream = FirebaseFirestore.instance
        .collection('USERS')
        .doc(widget.user.uid)
        .collection('rooms')
        .snapshots();

    // 2. Map those references to a combined stream of actual room data
    _combinedRoomStream = roomRefsStream.switchMap((snapshot) {
      if (snapshot.docs.isEmpty) {
        return Stream.value([]);
      }

      // For each room document in USERS/uid/rooms, listen to the actual ROOMS/roomDocID
      final roomStreams = snapshot.docs.map((doc) {
        final roomUID = doc["roomUID"];
        return FirebaseFirestore.instance
            .collection('ROOMS')
            .doc(roomUID)
            .snapshots()
            .map((snap) {
              if (!snap.exists) return null;
              final data = snap.data()!;
              data["roomDocID"] = roomUID;
              return data;
            });
      }).toList();

      // Combine all individual room streams into one list of room data
      return CombineLatestStream.list(roomStreams).map((list) => 
        list.where((item) => item != null).cast<Map<String, dynamic>>().toList()
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Global Balances", 
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24)
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ThemeToggle(),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _combinedRoomStream,
        builder: (context, snapshot) {
          // If we have no data yet and we're waiting, show spinner
          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If we had data but are waiting for an update, we keep showing the old data 
          // to prevent the "infinite spinner" experience.
          final roomData = snapshot.data ?? [];

          if (roomData.isEmpty) {
            return Center(
              child: Text("No active rooms.", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold))
            );
          }

          final allBalances = _aggregateBalances(roomData, widget.user.uid);
          final sortedPeople = allBalances.keys.toList()
            ..sort((a, b) => allBalances[b]!["net"].abs().compareTo(allBalances[a]!["net"].abs()));

          double totalOwe = 0;
          double totalGet = 0;
          allBalances.forEach((key, val) {
            double net = val["net"];
            if (net > 0) totalGet += net;
            else totalOwe += net.abs();
          });

          return ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSummaryCard(context, totalOwe, totalGet),
              const SizedBox(height: 32),
              Text(
                "BY PERSON",
                style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              if (sortedPeople.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text(
                      "All settled up! 🎉", 
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.w900)
                    )
                  ),
                ),
              ...sortedPeople.map((otherUid) {
                final data = allBalances[otherUid]!;
                return _buildPersonTile(context, otherUid, data);
              }),
            ],
          );
        },
      ),
    );
  }

  Map<String, Map<String, dynamic>> _aggregateBalances(List<Map<String, dynamic>> rooms, String myUid) {
    Map<String, Map<String, dynamic>> aggregated = {};

    for (var room in rooms) {
      final settlements = room["liveSettlements"] as Map<String, dynamic>? ?? {};
      final userMap = room["userMap"] as Map<String, dynamic>? ?? {};
      final roomName = room["roomName"] ?? "Unknown Room";

      settlements.forEach((key, value) {
        final parts = key.split(':');
        if (parts.length != 2) return;

        final debtor = parts[0];
        final creditor = parts[1];
        final amount = (value as num).toDouble();

        if (debtor == myUid || creditor == myUid) {
          final otherUid = (debtor == myUid) ? creditor : debtor;
          final isGetter = (creditor == myUid);

          if (!aggregated.containsKey(otherUid)) {
            aggregated[otherUid] = {
              "name": userMap[otherUid] ?? "Unknown User",
              "net": 0.0,
              "breakdown": <Map<String, dynamic>>[]
            };
          }

          double netChange = isGetter ? amount : -amount;
          aggregated[otherUid]!["net"] += netChange;
          (aggregated[otherUid]!["breakdown"] as List).add({
            "roomName": roomName,
            "roomDocID": room["roomDocID"],
            "amount": netChange,
          });
        }
      });
    }
    
    aggregated.removeWhere((key, value) => value["net"].abs() < 0.01);
    return aggregated;
  }

  Widget _buildSummaryCard(BuildContext context, double totalOwe, double totalGet) {
    final colorScheme = Theme.of(context).colorScheme;
    final net = totalGet - totalOwe;
    final isPositive = net >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPositive ? colorScheme.primary : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: Cooloors.neoShadow,
      ),
      child: Column(
        children: [
          Text(
            "TOTAL NET BALANCE", 
            style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)
          ),
          const SizedBox(height: 8),
          Text(
            "₹${net.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("YOU GET", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w900)),
                      Text("₹${totalGet.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Container(width: 2, height: 30, color: Colors.black),
                Expanded(
                  child: Column(
                    children: [
                      const Text("YOU OWE", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w900)),
                      Text("₹${totalOwe.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPersonTile(BuildContext context, String uid, Map<String, dynamic> data) {
    final colorScheme = Theme.of(context).colorScheme;
    final net = data["net"] as double;
    final isGetting = net > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: isGetting ? const Color(0xFF34D399) : const Color(0xFFEF4444),
              child: Text(
                data["name"][0].toUpperCase(), 
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)
              ),
            ),
          ),
          title: Text(data["name"], style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 16)),
          subtitle: Text(
            isGetting ? "owes you ₹${net.toStringAsFixed(2)}" : "you owe ₹${net.abs().toStringAsFixed(2)}",
            style: TextStyle(color: isGetting ? const Color(0xFF059669) : const Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 13),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 8),
                  ...(data["breakdown"] as List).map((item) {
                    final amt = item["amount"] as double;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item["roomName"], style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(
                            amt > 0 ? "+₹${amt.toStringAsFixed(2)}" : "-₹${amt.abs().toStringAsFixed(2)}",
                            style: TextStyle(color: amt > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: isGetting ? const Color(0xFF34D399) : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _showSettleConfirmation(context, uid, data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: const Center(
                        child: Text("Record Settlement",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSettleConfirmation(BuildContext context, String otherUid, Map<String, dynamic> data) {
    final colorScheme = Theme.of(context).colorScheme;
    final net = data["net"] as double;
    final isGetting = net > 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
          border: const Border(top: BorderSide(color: Colors.black, width: 4)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: isGetting ? const Color(0xFF34D399) : const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const Icon(Icons.handshake_rounded, color: Colors.black, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              isGetting ? "Confirm Payment" : "Settle Dues",
              style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              isGetting 
                ? "Did ${data["name"]} pay you ₹${net.toStringAsFixed(2)}?" 
                : "Have you paid ${data["name"]} ₹${net.abs().toStringAsFixed(2)}?",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: isGetting ? const Color(0xFF34D399) : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _settleGlobally(context, otherUid, data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Center(
                        child: Text("Yes, Settle All", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                      ),
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

  Future<void> _settleGlobally(
      BuildContext context, String otherUid, Map<String, dynamic> data) async {
    final breakdown = data["breakdown"] as List;
    final myUid = widget.user.uid;
    final isGetting = (data["net"] as double) > 0;

    // Capture states before async work to avoid "deactivated widget" errors
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    bool isLoaderVisible = true;

    // Show loading dialog and track its visibility
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    ).then((_) => isLoaderVisible = false);

    try {
      for (var item in breakdown) {
        final roomDocID = item["roomDocID"];
        final amount = (item["amount"] as double).abs();
        final payer = isGetting ? otherUid : myUid;
        final recipient = isGetting ? myUid : otherUid;

        await firebaseFirestoreRepo.recordPayment(
          roomDocID: roomDocID,
          payerUID: payer,
          recipientUID: recipient,
          amount: amount,
        );
      }

      // Close loader only if it hasn't been closed already (prevents popping the screen)
      if (isLoaderVisible) {
        navigator.pop();
      }

      messenger.showSnackBar(
        const SnackBar(content: Text("All balances settled successfully! 🎉")),
      );
    } catch (e) {
      if (isLoaderVisible) {
        navigator.pop();
      }
      messenger.showSnackBar(
        SnackBar(content: Text("Error settling balances: $e")),
      );
    }
  }
}
