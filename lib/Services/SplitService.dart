class SplitService {
  List<dynamic> bills;
  List<dynamic> users;
  SplitService({required this.bills, required this.users});
  List<dynamic> getActiveBills() {
    return bills.where((element) => element["active"] = true).toList();
  }

  Map<int, List<List<dynamic>>> billmap = <int, List<List<dynamic>>>{};
  int recursion(List<List<dynamic>> positives, List<List<dynamic>> negatives,
      List<List<dynamic>> bills, int depth) {
    if (positives.isEmpty && negatives.isEmpty) {
      List<List<dynamic>>? x = billmap[depth];
      if (x == null) {
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

  split() {
    List<dynamic> activeBills = getActiveBills();
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
    List<List<dynamic>> bills = [];
    print(individualPay);
    print(getters);
    print(payers);
    int x = recursion(getters, payers, bills, 0);
    List<List<dynamic>> ans = billmap[x]!;
    for (var tr in ans) {
      tr[0] = users[tr[0]];
      tr[1] = users[tr[1]];
      tr[2] = double.parse((tr[2]).toStringAsFixed(2));
      print(tr);
      // print('${users[tr[0]]} to ${users[tr[1]]} : ${tr[2]}');
    }
  }
}
/* 
 List finalBill = [];
  int recursion(List<List<dynamic>> positives, List<List<dynamic>> negatives) {
    if (positives.isEmpty && negatives.isEmpty) {
      return 0;
    }
    if(positives.isEmpty || negatives.isEmpty){
      return 1000000000;
    }
    print("negatives");
    for(var x in negatives){
      print(x);
    }
    print("positives");
    for(var y in positives){
      print(y);
    }
//     print("final Bill");
//     for(var x in finalBill){
//       print(x);
//     }
    var negative = negatives.elementAt(0);
    num n = negative[0];
    var nuid = negative[1];
    int count = 1000000000;
    int idx = 0;
    List ans = [-1, -1, -1];
    num amount;
    for (var positive in positives) {
      List<List<dynamic>> newPositives = List.from(positives);
      List<List<dynamic>> newNegatives = List.from(negatives);
      num p = positive[0];
      var puid = positive[1];
      newNegatives.remove(negative);
      newPositives.remove(positive);
      amount = p + n ;
      if (-n == p) {
//         print('equality ${negative[1]} $n and ${positive[1]} $p');
        
      } else if (-n > p) {
//         print('negative ${negative[1]} $n and ${positive[1]} $p');
        newNegatives.add([amount,nuid]);
//         if(newNegatives[0][0]>0){
//           continue;
//         }  
      } else {
//         print('positive ${negative[1]} $n and ${positive[1]} $p');
        newPositives.add([amount,puid]);
//         if(newPositives[idx][0]<0){
//           continue;
//         }
      }
      int nextCount = recursion(newPositives, newNegatives);
      if (nextCount < count) {
        ans = [positive[1], negative[1], amount];
        count = nextCount;
      }
      idx = idx + 1;
    }
    if(ans[0]!=-1){
      finalBill.add(ans);
    }
    return count + 1;
  }

void main() {
  List<List<dynamic>> positives = [[400,0],[200,1],[150,3]];
  List<List<dynamic>> negatives = [[-400,4],[-300,5],[-50,6]];
  int x = recursion(positives,negatives);
  print(" ");
  print(" ");
  print(x);
  print(" ");
  print(" ");
  for(var x in finalBill){
    print(x);
  }
}

*/