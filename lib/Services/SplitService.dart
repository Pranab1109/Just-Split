import 'package:flutter/material.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import '../utils/onWillSplit.dart';

class SplitService {
  List<dynamic> bills;
  List<dynamic> users;
  SplitService({required this.bills, required this.users});

  List<dynamic> getActiveBills() {
    return bills.where((element) => element["active"] == true).toList();
  }

  Map<int, List<List<dynamic>>> billmap = <int, List<List<dynamic>>>{};
  int minDepth = 1000000000;

  int recursion(List<List<dynamic>> positives, List<List<dynamic>> negatives,
      List<List<dynamic>> bills, int depth) {
    if (depth >= minDepth) {
      return 1000000000;
    }
    if (positives.isEmpty && negatives.isEmpty) {
      List<List<dynamic>>? x = billmap[depth];
      if (x == null) {
        minDepth = depth;
        x = List.from(bills);
        billmap[depth] = x;
      }
      return 0;
    }
    if (positives.isEmpty || negatives.isEmpty) {
      return 1000000000;
    }
    var negative = negatives.elementAt(0);
    num n = negative[0];
    var nuid = negative[1];
    int count = 1000000000;
    int c = depth;
    num amount;
    for (var positive in positives) {
      List<List<dynamic>> newPositives = List.from(positives);
      List<List<dynamic>> newNegatives = List.from(negatives);
      num p = positive[0];
      var puid = positive[1];
      newNegatives.remove(negative);
      newPositives.remove(positive);
      amount = p + n;
      if (-n == p || (p + n).abs() < 0.0001) {
      } else if (-n > p) {
        newNegatives.add([amount, nuid]);
      } else {
        newPositives.add([amount, puid]);
      }
      var x = p > -n ? -n : p;
      var tmp = [positive[1], negative[1], x];
      bills.add(tmp);
      int nextCount = recursion(newPositives, newNegatives, bills, c + 1);
      if (nextCount < count) {
        count = nextCount;
      }
      bills.remove(tmp);
    }
    return count + 1;
  }

  List<List<dynamic>> calculateLiveSettlements() {
    List<dynamic> activeBills = getActiveBills();
    if (activeBills.isEmpty) {
      return [];
    }

    List<num> individualPay = [];
    Map<dynamic, int> usersMap = {};
    int i = 0;
    for (var element in users) {
      usersMap[element] = i;
      individualPay.add(0.0);
      i++;
    }

    // Phase 1: Compute Net Balances
    for (var element in activeBills) {
      num amount = element["amount"] ?? 0;
      String payerUid = element["uid"];
      if (!usersMap.containsKey(payerUid)) continue;

      if (element["isSettlement"] == true) {
        // A settlement is a direct transfer from payer to a specific recipient
        individualPay[usersMap[payerUid]!] += amount;

        // Find the recipient from splitAmong or splitDetails
        String? recipientUid;
        if (element["splitAmong"] != null &&
            (element["splitAmong"] as List).isNotEmpty) {
          recipientUid = element["splitAmong"][0];
        } else if (element["splitDetails"] != null &&
            (element["splitDetails"] as Map).isNotEmpty) {
          recipientUid = (element["splitDetails"] as Map).keys.first;
        }

        if (recipientUid != null && usersMap.containsKey(recipientUid)) {
          individualPay[usersMap[recipientUid]!] -= amount;
        }
      } else {
        // Payer gets credited for what they paid
        individualPay[usersMap[payerUid]!] += amount;

        if (element.containsKey("splitDetails") &&
            element["splitDetails"] != null) {
          Map<String, dynamic> splitDetails =
              Map<String, dynamic>.from(element["splitDetails"]);
          splitDetails.forEach((uid, share) {
            if (usersMap.containsKey(uid)) {
              individualPay[usersMap[uid]!] -= share;
            }
          });
        } else if (element.containsKey("splitAmong") &&
            element["splitAmong"] != null) {
          List<dynamic> splitAmong = element["splitAmong"];
          if (splitAmong.isNotEmpty) {
            num share = amount / splitAmong.length;
            for (String uid in splitAmong) {
              if (usersMap.containsKey(uid)) {
                individualPay[usersMap[uid]!] -= share;
              }
            }
          }
        } else {
          num share = amount / users.length;
          for (int j = 0; j < users.length; j++) {
            individualPay[j] -= share;
          }
        }
      }
    }

    // Phase 2: Separate into creditors (getters) and debtors (payers)
    List<List<dynamic>> payers = [], getters = [];
    double totalNet = 0;
    for (int j = 0; j < individualPay.length; j++) {
      // Round to 2 decimal places to fix floating point issues
      double roundedVal = double.parse(individualPay[j].toStringAsFixed(2));
      totalNet += roundedVal;

      if (roundedVal < -0.01) {
        payers.add([roundedVal, j]);
      } else if (roundedVal > 0.01) {
        getters.add([roundedVal, j]);
      }
    }

    // Edge case: if sums don't match due to rounding, adjust the largest getter/payer
    if (totalNet.abs() > 0.01 && getters.isNotEmpty) {
      getters[0][0] =
          double.parse((getters[0][0] - totalNet).toStringAsFixed(2));
    }

    billmap.clear();
    minDepth = payers.length + getters.length;

    if (payers.isEmpty || getters.isEmpty) {
      return [];
    }

    List<List<dynamic>> transactionPath = [];
    int x = recursion(getters, payers, transactionPath, 0);
    List<List<dynamic>> ans = billmap[x] ?? [];

    // FALLBACK: If recursion failed to find a path (should be rare now), use a greedy approach
    if (ans.isEmpty) {
      ans = _greedySettlement(List.from(getters), List.from(payers));
    }

    // Format the final answers: [from_uid, to_uid, amount]
    for (var tr in ans) {
      var getterUid = users[tr[0]];
      var payerUid = users[tr[1]];
      tr[0] = payerUid; // from_uid (Payer)
      tr[1] = getterUid; // to_uid (Recipient)
      tr[2] = double.parse((tr[2]).toStringAsFixed(2)); // formatted amount
    }

    return ans;
  }

  // Guaranteed fallback algorithm if the recursive optimizer fails
  List<List<dynamic>> _greedySettlement(
      List<List<dynamic>> getters, List<List<dynamic>> payers) {
    List<List<dynamic>> results = [];
    int g = 0, p = 0;

    while (g < getters.length && p < payers.length) {
      double gAmt = getters[g][0];
      double pAmt = -payers[p][0];
      double amount = gAmt < pAmt ? gAmt : pAmt;

      results.add([getters[g][1], payers[p][1], amount]);

      getters[g][0] -= amount;
      payers[p][0] += amount;

      if (getters[g][0].abs() < 0.01) g++;
      if (payers[p][0].abs() < 0.01) p++;
    }
    return results;
  }
}
