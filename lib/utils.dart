import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tc_thing/model/model.dart';

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

const Color tcRed = Color.fromARGB(255, 159, 60, 42);
const Color secondary = Color.fromARGB(255, 159, 119, 42);
const Color terciary = Color.fromARGB(255, 159, 42, 82);

const TextStyle gothRedBig = TextStyle(
  fontFamily: "CloisterBlack",
  fontWeight: FontWeight.w600,
  fontSize: 48,
  color: tcRed,
);

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

const TextStyle gothBlack24bold = TextStyle(
  fontFamily: "CloisterBlack",
  fontWeight: FontWeight.w600,
  fontSize: 24,
);

const TextStyle gothBlack24 = TextStyle(
  fontFamily: "CloisterBlack",
  fontWeight: FontWeight.w400,
  fontSize: 24,
);

const TextStyle gothBlackBig = TextStyle(
  fontFamily: "CloisterBlack",
  fontWeight: FontWeight.w400,
  fontSize: 36,
);

String makeName(Roster roster, Sex sex, bool elite) {
  final prefixes = roster.elitePrefixes;
  final names = sex == Sex.male ? roster.namesM : roster.namesF;
  final surnames = roster.surnames;

  final random = Random();
  String prefix = "";
  if (elite && prefixes.isNotEmpty) {
    prefix = prefixes[random.nextInt(prefixes.length)];
    if (prefix[prefix.length - 1] != '-') prefix = "$prefix ";
  }

  final name = names[random.nextInt(names.length)];
  String surname = "";
  if (surnames.isNotEmpty) {
    surname = " ${surnames[random.nextInt(surnames.length)]}";
  }
  return "$prefix$name$surname";
}
