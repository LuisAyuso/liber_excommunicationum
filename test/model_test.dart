import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tc_thing/model/model.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tc_thing/model/warband.dart';

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

  test('filters', () {
    Unit u = Unit();
    u.typeName = "warrior 1";
    u.keywords = ["AAAA", "BBBB"];

    final gun = Weapon(typeName: "Gun", range: 12);
    final sword = Weapon(typeName: "Sword");
    final grenade = Weapon(typeName: "Grenades", range: 0, hands: 0);
    final armour = Armour(typename: "Armour", type: ArmourType.bodyArmour);
    final shield = Armour(typename: "Trench Shield", type: ArmourType.shield);

    var armory = Armory();
    armory.add(gun);
    armory.add(sword);
    armory.add(grenade);
    armory.add(armour);
    armory.add(shield);

    WarriorModel wm = WarriorModel(uid: 1, type: u, bucket: 2);
    wm.addItem(WeaponUse(typeName: "Gun"), armory);
    wm.addItem(ArmourUse(typeName: "Armour"), armory);

    expect(FilterItem.none().isItemAllowed(gun, wm), false);
    expect(FilterItem(unitKeyword: "AAAA").isItemAllowed(gun, wm), true);
    expect(FilterItem(unitKeyword: "BBBB").isItemAllowed(gun, wm), true);
    expect(FilterItem(unitKeyword: "CCCC").isItemAllowed(gun, wm), false);
    expect(
        FilterItem(unitName: "something else").isItemAllowed(gun, wm), false);
    expect(FilterItem(unitName: "warrior 1").isItemAllowed(gun, wm), true);

    expect(FilterItem(containsItem: "Gun").isItemAllowed(gun, wm), true);
    expect(FilterItem(containsItem: "Armour").isItemAllowed(gun, wm), true);
    expect(FilterItem(containsItem: "something else").isItemAllowed(gun, wm),
        false);
    expect(FilterItem(itemKind: ItemKind.weapon).isItemAllowed(gun, wm), true);
    expect(FilterItem(itemKind: ItemKind.armour).isItemAllowed(gun, wm), false);
    expect(
        FilterItem(itemKind: ItemKind.equipment).isItemAllowed(gun, wm), false);
    expect(
        FilterItem(itemKind: ItemKind.weapon).isItemAllowed(armour, wm), false);
    expect(
        FilterItem(itemKind: ItemKind.armour).isItemAllowed(armour, wm), true);
    expect(FilterItem(itemKind: ItemKind.equipment).isItemAllowed(armour, wm),
        false);

    expect(
        FilterItem.allOf([
          FilterItem(containsItem: "Gun"),
          FilterItem(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);

    expect(
        FilterItem.anyOf([
          FilterItem(containsItem: "Gun"),
          FilterItem(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);
    expect(
        FilterItem.anyOf([
          FilterItem(containsItem: "Gun"),
          FilterItem(containsItem: "Something else"),
          FilterItem(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);
    expect(
        FilterItem.anyOf([
          FilterItem(containsItem: "Something else"),
          FilterItem(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);
    expect(
        FilterItem.anyOf([
          FilterItem(containsItem: "Something else"),
          FilterItem(containsItem: "Not there")
        ]).isItemAllowed(gun, wm),
        false);
    expect(
        FilterItem.not(
          FilterItem.anyOf([
            FilterItem(containsItem: "something else"),
            FilterItem(containsItem: "not there")
          ]),
        ).isItemAllowed(gun, wm),
        true);

    expect(FilterItem(rangedWeapon: true).isItemAllowed(gun, wm), true);
    expect(FilterItem(rangedWeapon: false).isItemAllowed(gun, wm), false);
    expect(FilterItem(meleeWeapon: true).isItemAllowed(sword, wm), true);
    expect(FilterItem(meleeWeapon: false).isItemAllowed(sword, wm), false);
    expect(FilterItem(rangedWeapon: true).isItemAllowed(armour, wm), false);
    expect(FilterItem(rangedWeapon: false).isItemAllowed(armour, wm), false);
    expect(FilterItem(meleeWeapon: false).isItemAllowed(armour, wm), false);
    expect(FilterItem(meleeWeapon: true).isItemAllowed(armour, wm), false);

    expect(FilterItem(isBodyArmour: true).isItemAllowed(gun), false);
    expect(FilterItem(isBodyArmour: true).isItemAllowed(sword), false);
    expect(FilterItem(isBodyArmour: true).isItemAllowed(armour), true);
    expect(FilterItem(isBodyArmour: true).isItemAllowed(shield), false);

    expect(FilterItem(isShield: true).isItemAllowed(gun), false);
    expect(FilterItem(isShield: true).isItemAllowed(sword), false);
    expect(FilterItem(isShield: true).isItemAllowed(armour), false);
    expect(FilterItem(isShield: true).isItemAllowed(shield), true);

    {
      const regression =
          '{ "anyOf": [ { "itemName": "Trench Shield" }, { "noneOf": [ { "itemKind": "equipment" }, { "itemKind": "armour" }, { "isGrenade": true } ] } ] }';
      final f = FilterItem.fromJson(jsonDecode(regression));
      expect(f.isItemAllowed(gun), true);
      expect(f.isItemAllowed(sword), true);
      expect(f.isItemAllowed(armour), false);
      expect(f.isItemAllowed(grenade), false);
      expect(f.isItemAllowed(shield), true);
    }
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

    expect(ItemReplacement(filter: FilterItem(itemName: "gun")).isAllowed(gun),
        true);
    expect(
        ItemReplacement(filter: FilterItem(itemName: "gun")).isAllowed(pistol),
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
