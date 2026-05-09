import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/MyTextFieldTwo.dart';
import 'package:just_split/utils/CategoryPredictor.dart';

class AddBillBottomSheet extends StatefulWidget {
  final String roomID;
  final List usersList;
  final Map userMap;
  final VoidCallback onBillAdded;
  final Map<String, dynamic>? initialBill;
  final int? editIndex;

  const AddBillBottomSheet({
    Key? key,
    required this.roomID,
    required this.usersList,
    required this.userMap,
    required this.onBillAdded,
    this.initialBill,
    this.editIndex,
  }) : super(key: key);

  @override
  State<AddBillBottomSheet> createState() => _AddBillBottomSheetState();
}

class _AddBillBottomSheetState extends State<AddBillBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String splitMode = "equal"; // 'equal', 'custom'
  Map<String, bool> selectedUsers = {};
  Map<String, TextEditingController> customAmountControllers = {};

  bool isLoading = false;
  BillCategory _currentCategory = BillCategory.misc;

  bool get isSettlement => widget.initialBill?["isSettlement"] == true;

  @override
  void initState() {
    super.initState();
    // By default, everyone is selected for an equal split
    for (var uid in widget.usersList) {
      selectedUsers[uid] = true;
      customAmountControllers[uid] = TextEditingController();
    }

    descController.addListener(_onDescChanged);

    if (widget.initialBill != null) {
      amountController.text = widget.initialBill!["amount"].toString();
      descController.text = widget.initialBill!["desc"].toString();
      _currentCategory = CategoryPredictor.predict(descController.text);
      splitMode = widget.initialBill!["splitMode"] ?? "equal";

      if (splitMode == "equal" && widget.initialBill!["splitAmong"] != null) {
        List splitAmong = widget.initialBill!["splitAmong"];
        for (var uid in widget.usersList) {
          selectedUsers[uid] = splitAmong.contains(uid);
        }
      } else if (splitMode == "custom" &&
          widget.initialBill!["splitDetails"] != null) {
        Map details = widget.initialBill!["splitDetails"];
        for (var uid in widget.usersList) {
          if (details.containsKey(uid)) {
            customAmountControllers[uid]!.text = details[uid].toString();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descController.dispose();
    for (var controller in customAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDescChanged() {
    final newCategory = CategoryPredictor.predict(descController.text);
    if (newCategory != _currentCategory) {
      setState(() {
        _currentCategory = newCategory;
      });
    }
  }

  void submitBill() async {
    if (!_formKey.currentState!.validate()) return;

    double totalAmount = double.parse(amountController.text);
    if (totalAmount <= 0) return;

    List<dynamic> splitAmong = [];
    Map<String, dynamic> splitDetails = {};

    if (splitMode == "equal") {
      selectedUsers.forEach((uid, isSelected) {
        if (isSelected) splitAmong.add(uid);
      });
      if (splitAmong.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Select at least one person!")));
        return;
      }
    } else if (splitMode == "custom") {
      double customTotal = 0;
      customAmountControllers.forEach((uid, controller) {
        double val = double.tryParse(controller.text) ?? 0;
        if (val > 0) {
          splitDetails[uid] = val;
          customTotal += val;
        }
      });

      // Allow minor floating point diff
      if ((customTotal - totalAmount).abs() > 0.05) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Custom amounts (₹$customTotal) must equal total (₹$totalAmount)!")));
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (widget.editIndex != null) {
        await RepositoryProvider.of<FirebaseFirestoreRepo>(context).updateBill(
          roomDocID: widget.roomID,
          billIndex: widget.editIndex!,
          amount: totalAmount,
          desc: descController.text,
          splitMode: splitMode,
          splitAmong: splitMode == "equal" ? splitAmong : null,
          splitDetails: splitMode == "custom" ? splitDetails : null,
        );
      } else {
        await RepositoryProvider.of<FirebaseFirestoreRepo>(context).addBill(
          roomDocID: widget.roomID,
          amount: totalAmount,
          desc: descController.text,
          splitMode: splitMode,
          splitAmong: splitMode == "equal" ? splitAmong : null,
          splitDetails: splitMode == "custom" ? splitDetails : null,
        );
      }
      widget.onBillAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void deleteBill() async {
    setState(() {
      isLoading = true;
    });

    try {
      await RepositoryProvider.of<FirebaseFirestoreRepo>(context).deleteBill(
        widget.editIndex!,
        widget.roomID,
      );
      widget.onBillAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        border: const Border(top: BorderSide(color: Colors.black, width: 4)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.editIndex != null ? "Edit Bill" : "Add New Bill",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (widget.editIndex != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: IconButton(
                        onPressed: isLoading ? null : deleteBill,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        tooltip: "Delete Bill",
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: MyTextFieldTwo(
                      isNum: true,
                      hintText: "Amount",
                      inputController: amountController,
                      errorText: "Required",
                    ),
                  ),
                  if (!isSettlement) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: MyTextFieldTwo(
                        hintText: "Description",
                        inputController: descController,
                        errorText: "Required",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: CategoryPredictor.getColor(
                                        _currentCategory),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.black, width: 2),
                              ),
                              child: Icon(
                                CategoryPredictor.getIcon(_currentCategory),
                                key: ValueKey(_currentCategory),
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              if (!isSettlement) ...[
                // Split Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 2.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => splitMode = "equal"),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                color: splitMode == "equal"
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: splitMode == "equal"
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                )),
                            child: Center(
                              child: Text(
                                "Split Equally",
                                style: TextStyle(
                                  color: splitMode == "equal"
                                      ? Colors.black
                                      : colorScheme.onSurface
                                          .withOpacity(0.5),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => splitMode = "custom"),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                color: splitMode == "custom"
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: splitMode == "custom"
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                )),
                            child: Center(
                              child: Text(
                                "Custom",
                                style: TextStyle(
                                  color: splitMode == "custom"
                                      ? Colors.black
                                      : colorScheme.onSurface
                                          .withOpacity(0.5),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic Participants List
                Text(
                  "PARTICIPANTS",
                  style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),

                ...widget.usersList.map((uid) {
                  String name = widget.userMap[uid] ?? "Unknown";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      children: [
                        if (splitMode == "equal") ...[
                          Checkbox(
                            value: selectedUsers[uid],
                            activeColor: colorScheme.primary,
                            checkColor: Colors.black,
                            side:
                                const BorderSide(color: Colors.black, width: 2),
                            onChanged: (val) {
                              setState(() {
                                selectedUsers[uid] = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(name,
                                style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ] else if (splitMode == "custom") ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(name,
                                style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900)),
                          ),
                          SizedBox(
                            width: 100,
                            height: 40,
                            child: TextFormField(
                              controller: customAmountControllers[uid],
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                prefixText: "₹ ",
                                prefixStyle: TextStyle(
                                    color: colorScheme.onSurface
                                        .withOpacity(0.5),
                                    fontWeight: FontWeight.bold),
                                filled: true,
                                fillColor: colorScheme.onSurface
                                    .withOpacity(0.05),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],

              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: Cooloors.neoShadow,
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 3),
                          ),
                        )
                      : Center(
                          child: Text(
                            widget.editIndex != null
                                ? "Save Changes"
                                : "Add Bill",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
