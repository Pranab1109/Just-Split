import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/bloc/Avatar/avatarbloc_bloc.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController inputController;
  final String hintText;
  final bool isEmail;
  final bool isName;
  final bool isPassword;
  final GlobalKey<FormState> formkey;
  @override
  const MyTextField(
      {super.key,
      required this.inputController,
      required this.hintText,
      required this.formkey,
      this.isEmail = false,
      this.isName = false,
      this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const errorColor = Color(0xffEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 75,
          child: BlocBuilder<AvatarBloc, AvatarState>(
            builder: (context, state) {
              return TextFormField(
                obscureText: isPassword,
                controller: inputController,
                onChanged: (value) {
                  if (isName) {
                    BlocProvider.of<AvatarBloc>(context).add(
                        AvatarNameChangeRequest(name: inputController.text));
                  }
                },
                keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
                style: TextStyle(fontSize: 15, color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (isEmail) {
                    return value != null && !EmailValidator.validate(value)
                        ? 'Enter a valid email'
                        : null;
                  } else if (isPassword) {
                    return value != null && value.length < 6
                        ? "Min. 6 chars"
                        : null;
                  } else if (isName) {
                    return value != null && value.length < 3
                        ? "Min. 3 chars"
                        : null;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text(hintText),
                  labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: colorScheme.surface,
                  hintText: hintText,
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 3.5),
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
              );
            },
          ),
        ),
      ],
    );
  }
}
