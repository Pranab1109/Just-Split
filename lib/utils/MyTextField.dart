import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController inputController;
  final String hintText;
  final bool isEmail;
  final bool isName;
  final bool isPassword;
  final GlobalKey<FormState> formkey;
  @override
  const MyTextField(
      {Key? key,
      required this.inputController,
      required this.hintText,
      required this.formkey,
      this.isEmail = false,
      this.isName = false,
      this.isPassword = false})
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
            obscureText: isPassword,
            controller: inputController,
            onChanged: (value) {
              //Do something
            },
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (isEmail) {
                return value != null && !EmailValidator.validate(value)
                    ? 'Enter a valid email'
                    : null;
              } else if (isPassword) {
                return value != null && value.length < 6
                    ? "Enter min. 6 characters"
                    : null;
              } else if (isName) {
                return value != null && value.length < 3
                    ? "Enter min. 3 characters"
                    : null;
              }
              return null;
            },
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
