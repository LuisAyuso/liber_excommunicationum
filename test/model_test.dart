import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tc_thing/model/filters.dart';

import 'package:tc_thing/model/model.dart';

import 'package:flutter/services.dart' show rootBundle;

void testList(String listJson) async {
  String data = await rootBundle.loadString('assets/lists/armory.json');
  var armory = Armory.fromJson(jsonDecode(data));
  expect(armory.weapons, isNotEmpty);
  expect(armory.armours, isNotEmpty);

  data = await rootBundle.loadString(listJson);
  var roster = Roster.fromJson(jsonDecode(data));

  armory.extendWithUnique(roster);
  validateArmory(armory);

  expect(roster.weapons, isNotEmpty);
  expect(roster.units, isNotEmpty);
  expect(roster.armour, isNotEmpty);
  expect(roster.equipment, isNotEmpty);

  for (var w in roster.weapons) {
    debugPrint(w.getName);
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

  test('Modifiers', () {
    {
      Weapon w = Weapon();
      w.modifiers = [];
      expect(
        w.getModifiersString(Modifier(hit: 0), ModifierType.any),
        "",
      );
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.any),
          "+1D to Hit");
    }
    {
      Weapon w = Weapon();
      w.modifiers = [Modifier(hit: 1)];
      expect(w.getModifiersString(Modifier(hit: 0), ModifierType.any),
          "+1D to Hit");
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.any),
          "+2D to Hit");
    }

    {
      Weapon w = Weapon();
      w.modifiers = [Modifier(hit: 1, type: ModifierType.ranged)];
      expect(w.getModifiersString(Modifier(hit: 0), ModifierType.melee), "");
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.melee),
          "+1D to Hit");
      expect(w.getModifiersString(Modifier(hit: 0), ModifierType.ranged),
          "+1D to Hit");
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.ranged),
          "+2D to Hit");
      expect(w.getModifiersString(Modifier(hit: 0), ModifierType.any),
          "+1D to Hit");
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.any),
          "+2D to Hit");
    }

    {
      Weapon w = Weapon();
      w.modifiers = [
        Modifier(injury: -1),
        Modifier(attacks: 2, type: ModifierType.ranged),
      ];
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.any),
          "+1D to Hit; -1D to Injury; 2 Attacks");
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.ranged),
          "+1D to Hit; -1D to Injury; 2 Attacks");
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.melee),
          "+1D to Hit; -1D to Injury");
    }
  });
  test('weapons', () {
    final gun = Weapon(typeName: "pistol", range: 12, melee: true);
    expect(gun.canRanged, true);
    expect(gun.canMelee, true);
    final gun2 = Weapon(typeName: "gun", range: 12);
    expect(gun2.canRanged, true);
    expect(gun2.canMelee, false);
    final gun3 = Weapon(typeName: "gun");
    expect(gun3.canRanged, false);
    expect(gun3.canMelee, true);
  });

  test('roster serialization', () {
    var r = Roster();
    var boss = Unit();
    boss.typeName = "boss";
    boss.movement = '6"';
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
    final gun = Weapon(typeName: "gun");
    final pistol = Weapon(typeName: "pistol", melee: true);

    expect(ItemReplacement(filter: ItemFilter(itemName: "gun")).isAllowed(gun),
        true);
    expect(
        ItemReplacement(filter: ItemFilter(itemName: "gun")).isAllowed(pistol),
        false);
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

    validateArmory(armory);
  });

  test('load heretic legion list', () async {
    testList('assets/lists/heretic_legion.json');
  });
  test('load trench pilgrims list', () async {
    testList('assets/lists/trench_pilgrims.json');
  });
  test('load new antioch list', () async {
    testList('assets/lists/new_antioch.json');
  });

  test('load sultanate list', () async {
    testList('assets/lists/sultanate.json');
  });

  test('load black grail', () async {
    testList('assets/lists/black_grail.json');
  });
}

void validateArmory(Armory armory) {
  for (var w in armory.weapons) {
    expect(armory.weapons.where((elem) => elem.typeName == w.typeName),
        hasLength(1));
  }
  for (var weapon in armory.weapons) {
    debugPrint(weapon.typeName);
    expect(armory.isArmour(weapon.typeName), false);
    expect(armory.isWeapon(weapon.typeName), true);
    expect(armory.isEquipment(weapon.typeName), false);
    for (var mod in weapon.getModifiers) {
      expect(mod.cat(), predicate((v) => v != ModifierCategory.unknown));
    }
  }
  for (var a in armory.armours) {
    expect(armory.armours.where((elem) => elem.typeName == a.typeName),
        hasLength(1));
  }
  for (var armour in armory.armours) {
    expect(armory.isArmour(armour.typeName), true);
    expect(armory.isWeapon(armour.typeName), false);
    expect(armory.isEquipment(armour.typeName), false);
  }
  for (var e in armory.equipments) {
    expect(armory.equipments.where((elem) => elem.typeName == e.typeName),
        hasLength(1));
  }
  for (var equipment in armory.equipments) {
    expect(armory.isArmour(equipment.typeName), false);
    expect(armory.isWeapon(equipment.typeName), false);
    expect(armory.isEquipment(equipment.typeName), true);
  }
}
