import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tc_thing/model/filters.dart';

import 'package:tc_thing/model/model.dart';

import 'package:flutter/services.dart' show rootBundle;

Future<Roster> testList(String listJson) async {
  String data = await rootBundle.loadString('assets/lists/armory.json');
  var armory = Armory.fromJson(jsonDecode(data));
  expect(armory.weapons, isNotEmpty);
  expect(armory.armours, isNotEmpty);

  data = await rootBundle.loadString(listJson);
  var roster = Roster.fromJson(jsonDecode(data));

  validateArmory(armory);

  expect(roster.weapons, isNotEmpty);
  expect(roster.units, isNotEmpty);
  expect(roster.armour, isNotEmpty);
  expect(roster.equipment, isNotEmpty);

  for (var w in roster.weapons) {
    expect(
        roster
            .availableWeapons(armory)
            .where((e) => e.name == w.getName && e.isValid),
        hasLength(1),
        reason: w.typeName);
  }
  for (var a in roster.armour) {
    expect(
        roster
            .availableArmours(armory)
            .where((e) => e.name == a.getName && e.isValid),
        hasLength(1),
        reason: a.typeName);
  }
  for (var equ in roster.equipment) {
    expect(
        roster
            .availableEquipment(armory)
            .where((e) => e.name == equ.getName && e.isValid),
        hasLength(1),
        reason: equ.typeName);
  }
  return roster;
}

void testVariant(Roster roster, String s) async {
  String data = await rootBundle.loadString(s);
  var rosterVariant = RosterVariant.fromJson(jsonDecode(data));
  rosterVariant.apply(roster);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('currency', () {
    var d = Currency.ducats(1);
    var _ = jsonEncode(d.toJson());

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

    {
      Weapon w = Weapon.unarmed();
      expect(w.getModifiersString(Modifier(), ModifierType.melee),
          "-1D to Hit; -1D to Injury");
      expect(w.getModifiersString(Modifier(hit: 0), ModifierType.melee),
          "-1D to Hit; -1D to Injury");
      expect(w.getModifiersString(Modifier(hit: 1), ModifierType.melee),
          "-1D to Injury");
      expect(w.getModifiersString(Modifier(injury: 1), ModifierType.melee),
          "-1D to Hit");
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
    var w = ItemUse();
    w.typeName = "gun";
    w.cost = const Currency(ducats: 10);
    r.units = [boss];
    r.weapons = [w];

    var _ = jsonEncode(r.toJson());
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
    //debugPrint(armory.weapons.map((w) => w.typeName).toList().toString());
    //debugPrint(armory.armours.map((w) => w.typeName).toList().toString());
    //debugPrint(armory.equipments.map((w) => w.typeName).toList().toString());
    expect(armory.weapons, isNotEmpty);
    expect(armory.armours, isNotEmpty);
    expect(armory.equipments, isNotEmpty);

    validateArmory(armory);
  });

  test('load heretic legion list', () async {
    final roster = await testList('assets/lists/heretic_legion.json');
    testVariant(roster.clone(), 'assets/lists/naval_raiding_party.json');
    testVariant(roster.clone(), 'assets/lists/trench_ghosts.json');
  });
  test('load trench pilgrims list', () async {
    final roster = await testList('assets/lists/trench_pilgrims.json');
    testVariant(roster.clone(),
        'assets/lists/procession_of_the_sacred_affliction.json');
    testVariant(
        roster.clone(), "assets/lists/cavalcade_of_the_tenth_plague.json");
  });
  test('load new antioch list', () async {
    final roster = await testList('assets/lists/new_antioch.json');
    testVariant(
      roster.clone(),
      "assets/lists/papal_states_intervention_force.json",
    );
    testVariant(
      roster.clone(),
      "assets/lists/eire_rangers.json",
    );
    testVariant(
      roster.clone(),
      "assets/lists/stoßtruppen_of_the_free_state_of_prussia.json",
    );
    testVariant(
      roster.clone(),
      "assets/lists/kingdom_of_alba_assault_detachment.json",
    );
  });

  test('load sultanate list', () async {
    final roster = await testList('assets/lists/sultanate.json');
    testVariant(roster.clone(), "assets/lists/the_cabal_of_assassins.json");
  });

  test('load black grail', () async {
    testList('assets/lists/black_grail.json');
  });
}

void validateArmory(Armory armory) {
  for (var w in armory.weapons) {
    expect(armory.weapons.where((elem) => elem.typeName == w.typeName),
        hasLength(1),
        reason: w.itemName);
  }
  for (var weapon in armory.weapons) {
    expect(armory.isArmour(weapon.typeName), false, reason: weapon.typeName);
    expect(armory.isWeapon(weapon.typeName), true, reason: weapon.typeName);
    expect(armory.isEquipment(weapon.typeName), false, reason: weapon.typeName);
    for (var mod in weapon.getModifiers) {
      expect(mod.cat(), predicate((v) => v != ModifierCategory.unknown));
    }
  }
  for (var a in armory.armours) {
    expect(armory.armours.where((elem) => elem.typeName == a.typeName),
        hasLength(1),
        reason: a.typeName);
  }
  for (var armour in armory.armours) {
    expect(armory.isArmour(armour.typeName), true, reason: armour.itemName);
    expect(armory.isWeapon(armour.typeName), false, reason: armour.itemName);
    expect(armory.isEquipment(armour.typeName), false, reason: armour.itemName);
  }
  for (var e in armory.equipments) {
    expect(armory.equipments.where((elem) => elem.typeName == e.typeName),
        hasLength(1),
        reason: e.typeName);
  }
  for (var equipment in armory.equipments) {
    expect(armory.isArmour(equipment.typeName), false,
        reason: equipment.itemName);
    expect(armory.isWeapon(equipment.typeName), false,
        reason: equipment.itemName);
    expect(armory.isEquipment(equipment.typeName), true,
        reason: equipment.itemName);
  }
}
