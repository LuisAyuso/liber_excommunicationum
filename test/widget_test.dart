// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tc_thing/model/model.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tc_thing/warband_view.dart';

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
    var w = WeaponUse();
    w.name = "gun";
    w.cost = 10;
    r.units = [boss];
    r.weapons = [w];

    var str = jsonEncode(r.toJson());
    debugPrint(str);
  });

  testWidgets('load armory', (WidgetTester tester) async {
    String data = await rootBundle.loadString('assets/lists/armory.json');
    var armory = Armory.fromJson(jsonDecode(data));
    debugPrint(armory.weapons.map((w) => w.name).toList().toString());
    debugPrint(armory.armors.map((w) => w.name).toList().toString());
    debugPrint(armory.equipments.map((w) => w.name).toList().toString());
  });

  testWidgets('load cult list', (WidgetTester tester) async {
    String data = await rootBundle.loadString('assets/lists/armory.json');
    var armory = Armory.fromJson(jsonDecode(data));
    expect(armory.weapons, isNotEmpty);
    expect(armory.armors, isNotEmpty);
    //expect(armory.equipments, isNotEmpty);

    data = await rootBundle.loadString('assets/lists/cult.json');
    var roster = Roster.fromJson(jsonDecode(data));
    debugPrint(roster.units.length.toString());

    expect(roster.weapons, isNotEmpty);
    expect(roster.units, isNotEmpty);
    expect(roster.armor, isNotEmpty);
    expect(roster.equipment, isNotEmpty);

    for (var w in roster.weapons) {
      Weapon? found = armory.weapons
          .map<Weapon?>((w) => w)
          .firstWhere((weapDef) => weapDef!.name == w.name, orElse: () => null);
      expect(found, isNotNull, reason: w.name);
    }
    for (var a in roster.armor) {
      debugPrint(a.name);
      Armor? found = armory.armors
          .map<Armor?>((b) => b)
          .firstWhere((b) => b!.name == a.name, orElse: () => null);
      expect(found, isNotNull, reason: a.name);
    }
  });
}
