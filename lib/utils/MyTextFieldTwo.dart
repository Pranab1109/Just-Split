import 'package:flutter/material.dart';

class MyTextFieldTwo extends StatelessWidget {
  final TextEditingController inputController;
  final String hintText;
  bool isNum;
  MyTextFieldTwo(
      {Key? key,
      required this.inputController,
      required this.hintText,
      this.isNum = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.white;
    const accentColor = Colors.black38;
    const errorColor = Color(0xffEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 70,
          child: TextFormField(
            controller: inputController,
            // autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Enter a valid name';
              } else {
                return null;
              }
            },
            // keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              label: Text(hintText),
              labelStyle: const TextStyle(color: primaryColor),
              // prefixIcon: Icon(Icons.email),

              filled: true,
              fillColor: accentColor,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(.75)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: errorColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
