import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tc_thing/model/model.dart';

import 'package:flutter/services.dart' show rootBundle;

void testList(String listJson) async {
  String data = await rootBundle.loadString('assets/lists/armory.json');
  var armory = Armory.fromJson(jsonDecode(data));
  expect(armory.weapons, isNotEmpty);
  expect(armory.armours, isNotEmpty);

  data = await rootBundle.loadString(listJson);
  var roster = Roster.fromJson(jsonDecode(data));

  expect(roster.weapons, isNotEmpty);
  expect(roster.units, isNotEmpty);
  expect(roster.armour, isNotEmpty);
  expect(roster.equipment, isNotEmpty);

  for (var w in roster.weapons) {
    Weapon? found = armory.weapons
        .map<Weapon?>((w) => w)
        .firstWhere((def) => def!.typeName == w.typeName, orElse: () => null);
    expect(found, isNotNull, reason: w.typeName);
  }
  for (var a in roster.armour) {
    debugPrint(a.typeName);
    Armour? found = armory.armours
        .map<Armour?>((b) => b)
        .firstWhere((b) => b!.typeName == a.typeName, orElse: () => null);
    expect(found, isNotNull, reason: a.typeName);
  }
  for (var a in roster.equipment) {
    debugPrint(a.typeName);
    Equipment? found = armory.equipments
        .map<Equipment?>((b) => b)
        .firstWhere((b) => b!.typeName == a.typeName, orElse: () => null);
    expect(found, isNotNull, reason: a.typeName);
  }
}

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
    boss.typeName = "boss";
    boss.movement = 6;
    boss.max = 1;
    boss.ranged = 1;
    boss.melee = 1;
    boss.armour = 0;
    boss.abilities = ["special"];
    boss.keywords = ["elite"];
    boss.cost = const Currency(ducats: 60);
    var w = WeaponUse();
    w.typeName = "gun";
    w.cost = const Currency(ducats: 10);
    r.units = [boss];
    r.weapons = [w];

    var str = jsonEncode(r.toJson());
    debugPrint(str);
  });

  test('Replacements', () {
    var item = ItemReplacement(
      policy: ReplacementPolicy.anyFrom,
      values: ["one", "two", "three"],
    );

    expect(item.isAllowed("one"), true);
    expect(item.isAllowed("two"), true);
    expect(item.isAllowed("three"), true);
    expect(item.isAllowed("nop"), false);

    var item2 = ItemReplacement(
      policy: ReplacementPolicy.anyExcept,
      values: ["one", "two", "three"],
    );

    expect(item2.isAllowed("one"), false);
    expect(item2.isAllowed("two"), false);
    expect(item2.isAllowed("three"), false);
    expect(item2.isAllowed("nop"), true);
  });

  test('load armory', () async {
    String data = await rootBundle.loadString('assets/lists/armory.json');
    var armory = Armory.fromJson(jsonDecode(data));
    debugPrint(armory.weapons.map((w) => w.typeName).toList().toString());
    debugPrint(armory.armours.map((w) => w.typeName).toList().toString());
    debugPrint(armory.equipments.map((w) => w.typeName).toList().toString());
    expect(armory.weapons, isNotEmpty);
    expect(armory.armours, isNotEmpty);
    expect(armory.equipments, isNotEmpty);

    for (var weapon in armory.weapons) {
      expect(armory.isArmour(weapon.typeName), false);
      expect(armory.isWeapon(weapon.typeName), true);
      expect(armory.isEquipment(weapon.typeName), false);
    }
    for (var armour in armory.armours) {
      expect(armory.isArmour(armour.typeName), true);
      expect(armory.isWeapon(armour.typeName), false);
      expect(armory.isEquipment(armour.typeName), false);
    }
    for (var equipment in armory.equipments) {
      expect(armory.isArmour(equipment.typeName), false);
      expect(armory.isWeapon(equipment.typeName), false);
      expect(armory.isEquipment(equipment.typeName), true);
    }
  });

  test('load cult list', () async {
    testList('assets/lists/cult.json');
  });
  test('load trench pilgrims list', () async {
    testList('assets/lists/trench_pilgrims.json');
  });
  test('load new antioch list', () async {
    testList('assets/lists/new_antioch.json');
  });
}
