import 'package:flutter/material.dart';

class MyTextFieldTwo extends StatelessWidget {
  final TextEditingController inputController;
  final String hintText;
  String errorText;
  bool isNum;
  final Widget? suffixIcon;
  MyTextFieldTwo(
      {super.key,
      required this.inputController,
      required this.hintText,
      required this.errorText,
      this.isNum = false,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const errorColor = Color(0xffEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 75,
          child: TextFormField(
            controller: inputController,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            validator: (value) {
              if (isNum) {
                double? amount = double.tryParse(inputController.text);
                if (amount == null) return "Invalid";
                if (amount <= 0) return 'Invalid';
                if (amount > 10000000) return 'Limit exceeded';
                return null;
              } else {
                return (value == null || value.isEmpty) ? errorText : null;
              }
            },
            style: TextStyle(fontSize: 15, color: colorScheme.onSurface, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              label: Text(hintText),
              labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold),
              filled: true,
              fillColor: colorScheme.surface,
              hintText: hintText,
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: errorColor, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
