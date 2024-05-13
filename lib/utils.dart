import 'package:flutter/material.dart';

class MyContent extends StatelessWidget {
  const MyContent({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: const Color.fromARGB(255, 56, 56, 59)),
      Center(
        child: Container(
            constraints: const BoxConstraints(maxWidth: 960), child: child),
      ),
    ]);
  }
}

const Color tcRed = Color.fromARGB(255, 167, 51, 30);

const TextStyle gothRed24 = TextStyle(
  fontFamily: "CloisterBlack",
  fontWeight: FontWeight.w400,
  fontSize: 24,
  color: tcRed,
);

const TextStyle gothBlack20 = TextStyle(
  fontFamily: "CloisterBlack",
  fontWeight: FontWeight.w400,
  fontSize: 20,
);

const TextStyle gothBlackBig = TextStyle(
  fontFamily: "CloisterBlack",
  fontWeight: FontWeight.w400,
  fontSize: 36,
  color: tcRed,
);
