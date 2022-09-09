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

  split(roomDocID, context) async {
    FirebaseFirestoreRepo firestoreRepo = FirebaseFirestoreRepo();
    List<dynamic> activeBills = getActiveBills();
    if (activeBills.isEmpty) {
      return;
    }
    var split = await onWillSplit(context);
    // print(activeBills);
    if (split == false) {
      return;
    }
    List<num> individualPay = [];
    Map<dynamic, int> usersMap = {};
    int i = 0;
    for (var element in users) {
      usersMap[element] = i;
      individualPay.add(0);
      i++;
    }
    num total = 0;
    for (var element in activeBills) {
      total = total + element["amount"];
      individualPay[usersMap[element["uid"]]!] += element["amount"];
    }
    num toBePaid = total / users.length;
    List<List<dynamic>> payers = [],
        getters = []; //   [ [ amount , uid ] , ... ]
    for (int i = 0; i < individualPay.length; i++) {
      individualPay[i] = individualPay[i] - toBePaid;
      if (individualPay[i] < 0) {
        payers.add([individualPay[i], i]);
      } else {
        getters.add([individualPay[i], i]);
      }
    }
    billmap.clear();
    minDepth = 1000000000;
    List<List<dynamic>> bills = [];
    if (payers.isEmpty || getters.isEmpty) {
      return;
    }
    int x = recursion(getters, payers, bills, 0);
    List<List<dynamic>> ans = billmap[x]!;
    for (var tr in ans) {
      tr[0] = users[tr[0]];
      tr[1] = users[tr[1]];
      tr[2] = double.parse((tr[2]).toStringAsFixed(2));
    }
    firestoreRepo.storeResolvedBill(roomDocID, ans);
    return ans;
  }
}
