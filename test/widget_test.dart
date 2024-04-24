// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tc_thing/main.dart';
import 'package:tc_thing/model/model.dart';

import 'package:flutter/services.dart' show rootBundle;

typedef WL = List<WarriorModel>;

void main() {
  test('roster serialization', () {
    var r = Roster();
    var boss = Unit();
    boss.name = "boss";
    boss.movement = 6;
    boss.max = 1;
    boss.ranged = 1;
    boss.melee = 1;
    boss.armor = 0;
    boss.abilities = ["special"];
    boss.keywords = ["elite"];
    boss.cost = 60;
    var w = Weapon();
    w.name = "gun";
    w.cost = 10;
    r.units = [boss];
    r.weapons = [w];

    var str = jsonEncode(r.toJson());
    debugPrint(str);

    String other =
        '{"units": [{"name": "boss", "max": 1, "movement": 6, "ranged": 1, "melee": 1, "armor": 0, "abilities": ["special"], "keywords": ["elite"], "cost": 60}], "weapons": [{"name" : "pistol", "cost":10} ]}';
    var d = jsonDecode(other);
    Roster.fromJson(d);
  });

  testWidgets('load cult list', (WidgetTester tester) async {
    String data = await rootBundle.loadString('assets/lists/cult.json');
    var d = jsonDecode(data);
    var roster = Roster.fromJson(d);
    debugPrint(roster.units.length.toString());
  });
}
