import 'package:flutter/material.dart';

Future<bool> onWillPop(BuildContext context) async {
  bool signout = false;
  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.black87,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Logout ?",
                    style: TextStyle(color: Colors.white),
                    // style: subtitle1White,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            //color: blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //color: blue,
                          child: const Center(
                              child: Text(
                            "No",
                            style: TextStyle(color: Colors.white),
                            // style: button.copyWith(color: blue),
                          )),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          signout = true;
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //color: blue,
                          child: const Center(
                              child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.white),
                            // style: button,
                          )),
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          ));
  return signout;
}
