import 'package:flutter/material.dart';

Widget roomCardWidget(
    Size size,
    BuildContext context,
    String totalSpent,
    final String roomCode,
    final String roomName,
    final String roomUID,
    copyText,
    {required num youPaid,
    required num yourBalance,
    required List usersList,
    required Map userMap,
    String? leftTab,
    String? rightTab,
    Gradient? customGradient,
    bool useHero = true}) {
  String formattedTotal;
  try {
    formattedTotal = (double.parse(totalSpent)).toStringAsFixed(2);
  } catch (e) {
    formattedTotal = totalSpent;
  }

  bool isBalances = (leftTab?.toUpperCase() == "BALANCES") ||
      (rightTab?.toUpperCase() == "BALANCES");

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: isBalances ? const Color(0xFF50C878) : const Color(0xFFA693F5),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Vertical Tab Labels
            if (leftTab != null)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      leftTab.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 2,
                          color: Colors.black54),
                    ),
                  ),
                ),
              ),
            if (rightTab != null)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      rightTab.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 2,
                          color: Colors.black54),
                    ),
                  ),
                ),
              ),

            // Main Content
            Padding(
              padding: EdgeInsets.only(
                left: leftTab != null ? 32.0 : 20.0,
                right: rightTab != null ? 32.0 : 20.0,
                top: 20.0,
                bottom: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row: Nav and Room Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: const Center(
                                  child: Icon(Icons.arrow_back_ios_new,
                                      color: Colors.black, size: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _showParticipantsSheet(
                                context, usersList, userMap),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black, offset: Offset(2, 2))
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.people_alt_rounded,
                                      color: Colors.black, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${usersList.length} Members",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(roomCode,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Colors.black)),
                          IconButton(
                            onPressed: () => copyText(context),
                            icon: const Icon(Icons.copy_rounded,
                                color: Colors.black, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Middle Row: Spending vs Balances Layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT SIDE CONTENT
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBalances
                                ? "Your Net Balance"
                                : "Total Room Spend",
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14.0,
                                color: Colors.black87),
                          ),
                          Text(
                            isBalances
                                ? (yourBalance == 0
                                    ? "Settled"
                                    : "${yourBalance > 0 ? '+' : '-'} ₹${yourBalance.abs().toStringAsFixed(2)}")
                                : "₹ $formattedTotal",
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 28.0,
                                color: Colors.black,
                                letterSpacing: -1),
                          ),
                          const SizedBox(height: 12),
                          useHero
                              ? Hero(
                                  tag: 'room_name_$roomUID',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(roomName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                            color: Colors.black)),
                                  ),
                                )
                              : Text(roomName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                      color: Colors.black)),
                        ],
                      ),

                      // RIGHT SIDE CONTENT
                      if (!isBalances)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Your Share",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.0,
                                    color: Colors.black87)),
                            Text(
                              yourBalance == 0
                                  ? "Settled"
                                  : (yourBalance > 0
                                      ? "Owed ₹${yourBalance.abs().toStringAsFixed(2)}"
                                      : "You owe ₹${yourBalance.abs().toStringAsFixed(2)}"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.0,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "You paid ₹${youPaid.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.0,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                      if (isBalances)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(
                                height: 60), // Push to bottom alignment
                            Text(
                              "Activity: ₹$formattedTotal total",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.0,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showParticipantsSheet(BuildContext context, List usersList, Map userMap) {
  final colorScheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        side: BorderSide(color: Colors.black, width: 4),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Room Members",
                  style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    final uid = usersList[index];
                    final name = userMap[uid] ?? "Unknown";
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            radius: 18,
                            child: Text(name[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        title: Text(name,
                            style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      });
}
