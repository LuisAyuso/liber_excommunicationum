import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tc_thing/model/filters.dart';

import 'package:tc_thing/model/model.dart';

import 'package:tc_thing/model/warband.dart';

void main() {
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
    wm.addItem(ItemUse(typeName: "Gun"), armory);
    wm.addItem(ItemUse(typeName: "Armour"), armory);

    expect(ItemFilter.none().isItemAllowed(gun, wm), false);
    expect(ItemFilter(unitKeyword: "AAAA").isItemAllowed(gun, wm), true);
    expect(ItemFilter(unitKeyword: "BBBB").isItemAllowed(gun, wm), true);
    expect(ItemFilter(unitKeyword: "CCCC").isItemAllowed(gun, wm), false);
    expect(
        ItemFilter(unitName: "something else").isItemAllowed(gun, wm), false);
    expect(ItemFilter(unitName: "warrior 1").isItemAllowed(gun, wm), true);

    expect(ItemFilter(containsItem: "Gun").isItemAllowed(gun, wm), true);
    expect(ItemFilter(containsItem: "Armour").isItemAllowed(gun, wm), true);
    expect(ItemFilter(containsItem: "something else").isItemAllowed(gun, wm),
        false);
    expect(ItemFilter(itemKind: ItemKind.weapon).isItemAllowed(gun, wm), true);
    expect(ItemFilter(itemKind: ItemKind.armour).isItemAllowed(gun, wm), false);
    expect(
        ItemFilter(itemKind: ItemKind.equipment).isItemAllowed(gun, wm), false);
    expect(
        ItemFilter(itemKind: ItemKind.weapon).isItemAllowed(armour, wm), false);
    expect(
        ItemFilter(itemKind: ItemKind.armour).isItemAllowed(armour, wm), true);
    expect(ItemFilter(itemKind: ItemKind.equipment).isItemAllowed(armour, wm),
        false);

    expect(
        ItemFilter.allOf([
          ItemFilter(containsItem: "Gun"),
          ItemFilter(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);

    expect(
        ItemFilter.anyOf([
          ItemFilter(containsItem: "Gun"),
          ItemFilter(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);
    expect(
        ItemFilter.anyOf([
          ItemFilter(containsItem: "Gun"),
          ItemFilter(containsItem: "Something else"),
          ItemFilter(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);
    expect(
        ItemFilter.anyOf([
          ItemFilter(containsItem: "Something else"),
          ItemFilter(containsItem: "Armour")
        ]).isItemAllowed(gun, wm),
        true);
    expect(
        ItemFilter.anyOf([
          ItemFilter(containsItem: "Something else"),
          ItemFilter(containsItem: "Not there")
        ]).isItemAllowed(gun, wm),
        false);
    expect(
        ItemFilter.not(
          ItemFilter.anyOf([
            ItemFilter(containsItem: "something else"),
            ItemFilter(containsItem: "not there")
          ]),
        ).isItemAllowed(gun, wm),
        true);

    expect(ItemFilter(rangedWeapon: true).isItemAllowed(gun, wm), true);
    expect(ItemFilter(rangedWeapon: false).isItemAllowed(gun, wm), false);
    expect(ItemFilter(meleeWeapon: true).isItemAllowed(sword, wm), true);
    expect(ItemFilter(meleeWeapon: false).isItemAllowed(sword, wm), false);
    expect(ItemFilter(rangedWeapon: true).isItemAllowed(armour, wm), false);
    expect(ItemFilter(rangedWeapon: false).isItemAllowed(armour, wm), false);
    expect(ItemFilter(meleeWeapon: false).isItemAllowed(armour, wm), false);
    expect(ItemFilter(meleeWeapon: true).isItemAllowed(armour, wm), false);

    expect(ItemFilter(isBodyArmour: true).isItemAllowed(gun), false);
    expect(ItemFilter(isBodyArmour: true).isItemAllowed(sword), false);
    expect(ItemFilter(isBodyArmour: true).isItemAllowed(armour), true);
    expect(ItemFilter(isBodyArmour: true).isItemAllowed(shield), false);

    expect(ItemFilter(isShield: true).isItemAllowed(gun), false);
    expect(ItemFilter(isShield: true).isItemAllowed(sword), false);
    expect(ItemFilter(isShield: true).isItemAllowed(armour), false);
    expect(ItemFilter(isShield: true).isItemAllowed(shield), true);

    {
      const regression =
          '{ "anyOf": [ { "itemName": "Trench Shield" }, { "noneOf": [ { "itemKind": "equipment" }, { "itemKind": "armour" }, { "isGrenade": true } ] } ] }';
      final f = ItemFilter.fromJson(jsonDecode(regression));
      expect(f.isItemAllowed(gun), true);
      expect(f.isItemAllowed(sword), true);
      expect(f.isItemAllowed(armour), false);
      expect(f.isItemAllowed(grenade), false);
      expect(f.isItemAllowed(shield), true);
    }
  });

  test('filters', () {
    Unit u1 = Unit(typeName: "one");
    Unit u2 = Unit(typeName: "two");
    Unit u3 = Unit(typeName: "none");

    final w1 = WarriorModel(uid: 1, type: u1, bucket: 0);
    final w2 = WarriorModel(uid: 2, type: u2, bucket: 0);
    final w22 = WarriorModel(uid: 3, type: u2, bucket: 0);

    var wb = <WarriorModel>[w1, w2, w22];

    expect(UnitFilter.max(0).isUnitAllowed(u1, wb), false);
    expect(UnitFilter.max(0).isUnitAllowed(u2, wb), false);
    expect(UnitFilter.max(0).isUnitAllowed(u3, wb), false);

    expect(UnitFilter.max(1).isUnitAllowed(u1, wb), false);
    expect(UnitFilter.max(1).isUnitAllowed(u2, wb), false);
    expect(UnitFilter.max(1).isUnitAllowed(u3, wb), true);

    expect(UnitFilter.max(2).isUnitAllowed(u1, wb), true);
    expect(UnitFilter.max(2).isUnitAllowed(u2, wb), false);
    expect(UnitFilter.max(2).isUnitAllowed(u3, wb), true);

    expect(UnitFilter(sameCountAs: "one").isUnitAllowed(u1, wb), false);
    // introducing one more breaks condition
    expect(UnitFilter(sameCountAs: "two").isUnitAllowed(u1, wb), true);
    expect(UnitFilter(sameCountAs: "none").isUnitAllowed(u1, wb), false);

    expect(UnitFilter(sameCountAs: "one").isUnitAllowed(u3, wb), true);
    expect(UnitFilter(sameCountAs: "two").isUnitAllowed(u3, wb), true);
    expect(UnitFilter(sameCountAs: "none").isUnitAllowed(u3, wb), false);
  });
}
