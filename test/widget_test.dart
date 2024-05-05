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
  TestWidgetsFlutterBinding.ensureInitialized();

  test('currency', () {
    var d = Currency.ducats(1);
    var str = jsonEncode(d.toJson());
    debugPrint(str);

    var s1 = '{"ducats": 43}';
    var d1 = Currency.fromJson(jsonDecode(s1));
    expect(d1.isDucats, true);
    expect(d1.isGlory, false);
    expect(d1.ducats, 43);
    expect(d1.glory, 0);

    var s2 = '{"glory": 23}';
    var d2 = Currency.fromJson(jsonDecode(s2));
    expect(d2.isDucats, false);
    expect(d2.isGlory, true);
    expect(d2.ducats, 0);
    expect(d2.glory, 23);
  });

  test('filters', () {
    var f1 = Filter.blacklist(["a", "b", "c"]);
    expect(f1.isAllowed("a"), false);
    expect(f1.isAllowed("b"), false);
    expect(f1.isAllowed("c"), false);
    expect(f1.isAllowed("aaa"), true);
    expect(f1.isAllowed("d"), true);

    var f2 = Filter.whitelist(["a", "b", "c"]);
    expect(f2.isAllowed("a"), true);
    expect(f2.isAllowed("b"), true);
    expect(f2.isAllowed("c"), true);
    expect(f2.isAllowed("aaa"), false);
    expect(f2.isAllowed("d"), false);

    var f3 = Filter.none();
    expect(f3.isAllowed("a"), false);
    expect(f3.isAllowed("b"), false);
    expect(f3.isAllowed("c"), false);
    expect(f3.isAllowed("aaa"), false);
    expect(f3.isAllowed("d"), false);
  });

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
    boss.cost = Currency(ducats: 60);
    var w = WeaponUse();
    w.name = "gun";
    w.cost = Currency(ducats: 10);
    r.units = [boss];
    r.weapons = [w];

    var str = jsonEncode(r.toJson());
    debugPrint(str);
  });

  test('load armory', () async {
    String data = await rootBundle.loadString('assets/lists/armory.json');
    var armory = Armory.fromJson(jsonDecode(data));
    debugPrint(armory.weapons.map((w) => w.name).toList().toString());
    debugPrint(armory.armours.map((w) => w.name).toList().toString());
    debugPrint(armory.equipments.map((w) => w.name).toList().toString());
    expect(armory.weapons, isNotEmpty);
    expect(armory.armours, isNotEmpty);
  });

  test('load cult list', () async {
    String data = await rootBundle.loadString('assets/lists/armory.json');
    var armory = Armory.fromJson(jsonDecode(data));
    expect(armory.weapons, isNotEmpty);
    expect(armory.armours, isNotEmpty);

    data = await rootBundle.loadString('assets/lists/cult.json');
    var roster = Roster.fromJson(jsonDecode(data));
    //debugPrint(roster.units.length.toString());

    expect(roster.weapons, isNotEmpty);
    expect(roster.units, isNotEmpty);
    expect(roster.armor, isNotEmpty);
    expect(roster.equipment, isNotEmpty);

    for (var w in roster.weapons) {
      Weapon? found = armory.weapons
          .map<Weapon?>((w) => w)
          .firstWhere((def) => def!.name == w.name, orElse: () => null);
      expect(found, isNotNull, reason: w.name);
    }
    for (var a in roster.armor) {
      debugPrint(a.name);
      Armor? found = armory.armours
          .map<Armor?>((b) => b)
          .firstWhere((b) => b!.name == a.name, orElse: () => null);
      expect(found, isNotNull, reason: a.name);
    }
    for (var a in roster.equipment) {
      debugPrint(a.name);
      Equipment? found = armory.equipments
          .map<Equipment?>((b) => b)
          .firstWhere((b) => b!.name == a.name, orElse: () => null);
      expect(found, isNotNull, reason: a.name);
    }
  });
}
