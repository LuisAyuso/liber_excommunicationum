import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tc_thing/model/model.dart';

class WarriorModel {
  WarriorModel(
      {String? name,
      required this.uid,
      required this.type,
      required this.bucket,
      Armory? armory})
      : name = name ?? "Generated" {
    if (armory != null) {
      populateBuiltIn(armory);
    }
  }

  String name = "Generated name?";
  final int uid;
  final Unit type;
  List<WeaponUse> weapons = [];
  List<ArmorUse> armour = [];
  List<EquipmentUse> equipment = [];
  final int bucket;

  WarriorModel copyWith({required String name, required int newUid}) {
    var w = WarriorModel(name: name, uid: newUid, type: type, bucket: bucket);
    w.weapons = List.of(weapons);
    w.armour = List.of(armour);
    w.equipment = List.of(equipment);
    return w;
  }

  Currency get totalCost => baseCost + equipmentCost;
  Currency get baseCost => type.cost;
  Currency get equipmentCost =>
      weapons.fold<Currency>(Currency.free(), (v, w) => w.cost + v) +
      armour.fold<Currency>(Currency.free(), (v, w) => w.cost + v) +
      equipment.fold<Currency>(Currency.free(), (v, w) => w.cost + v);

  void populateBuiltIn(Armory armory) {
    for (var item in type.defaultItems ?? []) {
      if (armory.isWeapon(item.itemName)) {
        weapons.add(WeaponUse(
            typeName: item.itemName,
            removable: item.isRemovable,
            cost: item.getCost));
      }
      if (armory.isArmour(item.itemName)) {
        armour.add(ArmorUse(
            typeName: item.itemName,
            removable: item.isRemovable,
            cost: item.getCost));
      }
      if (armory.isEquipment(item.itemName)) {
        equipment.add(EquipmentUse(
            typeName: item.itemName,
            removable: item.isRemovable,
            cost: item.getCost));
      }
    }
  }

  int computeArmorValue(Armory armory) {
    return type.armour +
        armour
            .map((a) =>
                armory.armours.firstWhere((e) => e.typeName == a.typeName))
            .map((a) => a.value ?? 0)
            .fold(0, (a, b) => a + b);
  }

  Iterable<Weapon> getWeapons(Armory armory) =>
      weapons.map((w) => armory.findWeapon(w));
  Iterable<Armour> getArmours(Armory armory) =>
      armour.map((w) => armory.findArmour(w));
  Iterable<Equipment> getEquipment(Armory armory) =>
      armour.map((w) => armory.findEquipment(w));

  int pistolsCount(Armory armory) =>
      getWeapons(armory).fold(0, (v, w) => v + (w.isPistol ? 1 : 0));
  int firearmsCount(Armory armory) =>
      getWeapons(armory).fold(0, (v, w) => v + (w.isFirearm ? 1 : 0));
  int meleeCount(Armory armory) =>
      getWeapons(armory).fold(0, (v, w) => v + (w.isMeleeWeapon ? 1 : 0));

  bool allowPistol(Armory armory) =>
      (firearmsCount(armory) == 0 && pistolsCount(armory) < 2) ||
      (firearmsCount(armory) == 1 && pistolsCount(armory) < 1);
  bool allowMelee(Armory armory) =>
      getArmours(armory).where((a) => a.isShield).isEmpty
          ? meleeCount(armory) <= 2
          : meleeCount(armory) <= 1;
  int freeHands(Armory armory) =>
      2 -
      getWeapons(armory)
          .where((w) => w.isMeleeWeapon)
          .fold(0, (v, w) => v + w.hands);

// - One firearm and one pistol OR
// - two pistols.
// In addition, they may carry:
// - One two-handed melee weapon OR
// - one single-handed melee weapon and a trench shield OR
// - two single-handed melee weapons.
  UnmodifiableListView<WeaponUse> availableWeapons(
      Roster roster, Armory armory) {
    return UnmodifiableListView(roster.weapons.where((weapon) {
      final def = armory.findWeapon(weapon);

      if (def.canMelee &&
          !type.getMeleeWeaponFilter.isAllowed(weapon.typeName)) {
        return false;
      }

      if (def.canRanged &&
          !type.getRangedWeaponFilter.isAllowed(weapon.typeName)) {
        return false;
      }

      if (!weapon.getUnitNameFilter.isAllowed(type.typeName)) {
        return false;
      }

      if (!type.keywords.fold(false,
          (v, keyword) => v || weapon.getKeywordFilter.isAllowed(keyword))) {
        return false;
      }

      if (def.isPistol && allowPistol(armory)) return true;
      if (def.isFirearm && firearmsCount(armory) < 1) return true;
      if (def.isMeleeWeapon && allowMelee(armory)) {
        return freeHands(armory) >= def.hands;
      }

      return false;
    }));
  }

  bool wearsBodyArmour(Armory armory) =>
      getArmours(armory).where((a) => a.isArmour).isNotEmpty;
  bool wearsShield(Armory armory) =>
      getArmours(armory).where((a) => a.isShield).isNotEmpty;

  UnmodifiableListView<ArmorUse> availableArmours(
          Roster roster, Armory armory) =>
      UnmodifiableListView(roster.armour.where((armour) {
        if (!type.getArmourFilter.isAllowed(armour.typeName)) {
          return false;
        }

        if (!armour.getUnitNameFilter.isAllowed(type.typeName)) {
          return false;
        }

        if (!type.keywords.fold(false,
            (v, keyword) => v || armour.getKeywordFilter.isAllowed(keyword))) {
          return false;
        }

        final def = armory.findArmour(armour);
        if (def.isArmour && wearsBodyArmour(armory)) return false;
        if (def.isShield && wearsShield(armory)) return false;

        return true;
      }));

  UnmodifiableListView<EquipmentUse> availableEquipment(
      Roster roster, Armory armory) {
    return UnmodifiableListView(roster.equipment.where((equip) {
      if (!type.getEquipmentFilter.isAllowed(equip.typeName)) {
        return false;
      }

      if (!equip.getUnitNameFilter.isAllowed(type.typeName)) {
        return false;
      }

      if (!type.keywords.fold(false,
          (v, keyword) => v || equip.getKeywordFilter.isAllowed(keyword))) {
        return false;
      }

      final def = armory.findEquipment(equip);
      if (!def.isConsumable &&
          equipment.where((e) => e.typeName == def.typeName).isNotEmpty) {
        return false;
      }

      return true;
    }));
  }
}

class WarbandModel extends ChangeNotifier {
  final List<WarriorModel> _items = [];
  int _id = 0;

  UnmodifiableListView<WarriorModel> get items => UnmodifiableListView(_items);
  int get length => _items.length;
  Currency get cost =>
      _items.fold<Currency>(Currency.free(), (v, w) => v + w.totalCost);

  void add(WarriorModel item) {
    _items.add(item);
    _items.sort((a, b) => a.bucket.compareTo(b.bucket));
    notifyListeners();
  }

  int nextUID() {
    return ++_id;
  }

  WarriorModel getUID(int uid) {
    return _items.firstWhere((w) => w.uid == uid);
  }

  void removeUID(int uid) {
    _items.removeWhere((w) => w.uid == uid);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void invalidate() {
    notifyListeners();
  }
}
