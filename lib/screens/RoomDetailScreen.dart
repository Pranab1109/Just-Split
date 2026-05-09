import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/Services/SplitService.dart';
import 'package:just_split/utils/BuildResolvedBills.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/RoomCardWidget.dart';
import 'package:just_split/utils/StackedCardTabs.dart';
import 'package:just_split/utils/AddBillBottomSheet.dart';
import 'package:just_split/utils/CategoryPredictor.dart';
import 'package:just_split/utils/buildUserListRoomPage.dart';
import 'package:just_split/utils/onDeleteWillPop.dart';
import 'package:intl/intl.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomID;
  final String roomName;
  final String roomCode;

  RoomDetailScreen({
    Key? key,
    required this.roomID,
    required this.roomName,
    required this.roomCode,
  }) : super(key: key);

  final Cooloors cooloors = Cooloors();
  final ScrollController _controller = ScrollController();
  final user = AuthRepository().getUser();
  final FirebaseFirestoreRepo firebaseFirestoreRepo = FirebaseFirestoreRepo();
  final DateFormat formatter = DateFormat('dd MMM yy');
  final DateFormat timeformatter = DateFormat('jm');

  void _scrollToLatest() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void copyText(context) {
    Clipboard.setData(ClipboardData(text: roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.down,
        padding: const EdgeInsets.all(0),
        content: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF34D399),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: Cooloors.neoShadow,
          ),
          child: const Center(
            child: Text(
              "Room code copied!",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = user?.uid;
    Stream documentStream = firebaseFirestoreRepo.rooms.doc(roomID).snapshots();
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header with Stacked Cards
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: StackedCardTabs(
                  expensesCard: StreamBuilder<dynamic>(
                    stream: documentStream,
                    builder: (context, snapshot) {
                      return _buildCard(context, snapshot, uid, size,
                          isBalances: false);
                    },
                  ),
                  balancesCard: StreamBuilder<dynamic>(
                    stream: documentStream,
                    builder: (context, snapshot) {
                      return _buildCard(context, snapshot, uid, size,
                          isBalances: true);
                    },
                  ),
                ),
              ),

              // Content Area: List switches based on Tab
              Expanded(
                child: StreamBuilder<dynamic>(
                  stream: documentStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var data = snapshot.data;
                    if (!data.exists) {
                      return const Center(child: Text("Room not found"));
                    }

                    Map<String, dynamic> docData =
                        data.data() as Map<String, dynamic>;
                    final List bills =
                        List.from(docData["bills"] ?? []).reversed.toList();

                    return AnimatedBuilder(
                      animation: DefaultTabController.of(context).animation!,
                      builder: (context, child) {
                        int tabIndex = DefaultTabController.of(context).index;

                        return IndexedStack(
                          index: tabIndex,
                          children: [
                            // Tab 0: Expenses List
                            _buildExpensesList(
                                context, bills, uid, colorScheme, docData),

                            // Tab 1: Balances/Settlements List
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: BuildResolvedList(
                                roomID: roomID,
                                uid: uid,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom Actions
              _buildBottomActions(context, documentStream, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesList(BuildContext context, List bills, String? uid,
      ColorScheme colorScheme, Map docData) {
    // Merge bills and logs
    List logs = docData["logs"] ?? [];
    List combined = [...bills, ...logs];
    // Sort descending by time
    combined.sort((a, b) {
      Timestamp tA = a["time"];
      Timestamp tB = b["time"];
      return tB.compareTo(tA);
    });

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemCount: combined.length,
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var item = combined[index];
              bool isLog = item.containsKey("msg");

              bool isFirstInDay = index == 0 ||
                  formatter.format((item['time'] as Timestamp).toDate()) !=
                      formatter.format(
                          (combined[index - 1]['time'] as Timestamp).toDate());

              return Column(
                children: [
                  if (isFirstInDay)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          formatter
                              .format((item['time'] as Timestamp).toDate()),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  if (isLog)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item["msg"],
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeformatter
                                .format((item["time"] as Timestamp).toDate()),
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.3),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6.0),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => AddBillBottomSheet(
                              roomID: roomID,
                              usersList: docData["users"],
                              userMap: docData["userMap"],
                              initialBill: Map<String, dynamic>.from(item),
                              editIndex:
                                  (docData["bills"] as List).indexOf(item),
                              onBillAdded: () {},
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black, offset: Offset(3, 3))
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: (item["isSettlement"] ?? false)
                                      ? const Color(0xFF34D399)
                                      : CategoryPredictor.getColor(
                                          CategoryPredictor.predict(
                                              item["desc"] ?? "")),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                ),
                                child: Icon(
                                  (item["isSettlement"] ?? false)
                                      ? Icons.handshake_rounded
                                      : CategoryPredictor.getIcon(
                                          CategoryPredictor.predict(
                                              item["desc"] ?? "")),
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["desc"] == null ||
                                              item["desc"].toString().isEmpty
                                          ? "Expense"
                                          : item["desc"].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(item["userName"] ?? "Unknown",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "₹${num.parse(item["amount"].toString()).toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
      BuildContext context, Stream documentStream, ColorScheme colorScheme) {
    return StreamBuilder<dynamic>(
      stream: documentStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var data = snapshot.data;
        if (!data.exists) return const SizedBox();
        Map<String, dynamic> docData = data.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(4, 4))
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => AddBillBottomSheet(
                    roomID: roomID,
                    usersList: docData["users"],
                    userMap: docData["userMap"],
                    onBillAdded: () => _scrollToLatest(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent),
              child: const Text("Add Bill",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(
      BuildContext context, AsyncSnapshot snapshot, String? uid, Size size,
      {required bool isBalances}) {
    if (!snapshot.hasData) return const SizedBox();
    var data = snapshot.data;
    if (!data.exists) return const SizedBox();

    Map<String, dynamic> docData = data.data() as Map<String, dynamic>;
    num youPaid = 0;
    num yourBalance = 0;
    String totalSpent = docData["totalSpent"].toString();
    List usersList = docData["users"] ?? [];
    Map userMap = docData["userMap"] ?? {};

    for (var item in docData["bills"] ?? []) {
      if (item["uid"] == uid && item["active"] == true) {
        youPaid += item["amount"];
      }
    }

    if (docData.containsKey("liveSettlements") &&
        docData["liveSettlements"] != null) {
      Map settlements = docData["liveSettlements"];
      settlements.forEach((key, value) {
        List<String> parts = key.toString().split(':');
        if (parts.length == 2) {
          if (parts[1] == uid)
            yourBalance += value;
          else if (parts[0] == uid) yourBalance -= value;
        }
      });
    }

    return roomCardWidget(
      size,
      context,
      totalSpent.toString(),
      roomCode,
      roomName,
      roomID,
      copyText,
      youPaid: youPaid,
      yourBalance: yourBalance,
      usersList: usersList,
      userMap: userMap,
      leftTab: isBalances ? null : "Expenses",
      rightTab: isBalances ? "Balances" : null,
      useHero: !isBalances,
    );
  }
}
