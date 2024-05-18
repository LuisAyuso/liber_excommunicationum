import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tc_thing/model/model.dart';

class ItemStack {
  ItemStack({ItemUse? item}) : _stack = item != null ? [item] : [];
  List<ItemUse> _stack;

  ItemUse get value {
    assert(_stack.isNotEmpty, "this can not be empty, ever");
    return _stack.last;
  }

  bool get isEmpty => _stack.isEmpty;

  bool pop() {
    _stack.removeLast();
    return _stack.isEmpty;
  }

  void replace(ItemUse item) {
    _stack.add(item);
  }

  ItemStack copy() {
    ItemStack s = ItemStack();
    s._stack = List.of(_stack);
    return s;
  }
}

class WarriorModel {
  WarriorModel(
      {String? name,
      required this.uid,
      required this.type,
      required this.bucket,
      Armory? armory})
      : name = name ?? "Generated" {
    if (armory != null) populateBuiltIn(armory);
  }

  WarriorModel copyWith({required String name, required int newUid}) {
    var w = WarriorModel(name: name, uid: newUid, type: type, bucket: bucket);
    w._items = [];
    for (var it in _items) {
      w._items.add(it.copy());
    }
    return w;
  }

  String name = "Generated name?";
  final int uid;
  final Unit type;
  final int bucket;

  List<ItemStack> _items = [];
  Iterable<ItemUse> get items => _items.map((s) => s.value);
  Iterable<WeaponUse> get weapons =>
      _items.map((s) => s.value).whereType<WeaponUse>();

  Iterable<WeaponUse> weaponsOrUnarmed(Armory armory) {
    final collection = weapons.toList();
    if (collection.where((wu) => armory.findWeapon(wu).canMelee).isEmpty) {
      if (!type.getUnarmedPenalty) {
        return [];
      }

      return Iterable.generate(weapons.length + 1, (idx) {
        if (idx == 0) return WeaponUse.unarmed();
        return collection[idx - 1];
      });
    }
    return collection;
  }

  Iterable<ArmorUse> get armour =>
      _items.map((s) => s.value).whereType<ArmorUse>();
  Iterable<EquipmentUse> get equipment =>
      _items.map((s) => s.value).whereType<EquipmentUse>();

  Currency get totalCost => baseCost + equipmentCost;
  Currency get baseCost => type.cost;
  Currency get equipmentCost => _items
      .map((i) => i.value)
      .fold<Currency>(Currency.free(), (v, w) => w.getCost + v);

  void addItem(ItemUse item) {
    _items.add(ItemStack(item: item));
  }

  void removeItem(ItemUse item) {
    for (var it in _items) {
      if (it.value.getName == item.getName) {
        it.pop();
      }
    }
    _items.removeWhere((innerList) => innerList.isEmpty);
    assert(_items.where((s) => s.isEmpty).isEmpty);
  }

  void replace(ItemUse oldItem, ItemUse newItem) {
    for (var stack in _items) {
      if (stack.value.getName == oldItem.getName) stack.replace(newItem);
    }
  }

  void populateBuiltIn(Armory armory) {
    for (var item in type.defaultItems ?? []) {
      if (armory.isWeapon(item.itemName)) {
        addItem(WeaponUse(
            typeName: item.itemName,
            removable: item.isRemovable,
            cost: item.getCost));
      }
      if (armory.isArmour(item.itemName)) {
        addItem(ArmorUse(
            typeName: item.itemName,
            removable: item.isRemovable,
            cost: item.getCost));
      }
      if (armory.isEquipment(item.itemName)) {
        addItem(EquipmentUse(
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
      getWeapons(armory).where((w) => w.isPistol).length;
  int firearmsCount(Armory armory) =>
      getWeapons(armory).where((w) => w.isFirearm).length;
  int meleeCount(Armory armory) =>
      getWeapons(armory).where((w) => w.isMeleeWeapon).length;

  bool allowPistol(Armory armory) =>
      (firearmsCount(armory) == 0 && pistolsCount(armory) < 2) ||
      (firearmsCount(armory) == 1 && pistolsCount(armory) < 1);
  bool allowMelee(Armory armory) =>
      getArmours(armory).where((a) => a.isShield).isEmpty
          ? meleeCount(armory) <= 2
          : meleeCount(armory) <= 1;
  int freeHands(Armory armory) =>
      type.getHands -
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
    return UnmodifiableListView(roster.weapons.where((use) {
      // no repetitions
      if (weapons.where((w) => w.getName == use.getName).isNotEmpty) {
        return false;
      }

      final def = armory.findWeapon(use);

      final filter =
          FilterItem.allOf([use.getFilter, def.getFilter, type.getFilter]);
      if (!filter.isItemAllowed(def, this)) return false;

      if (def.isGrenade) return true;
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
        final def = armory.findArmour(armour);

        final filter =
            FilterItem.allOf([armour.getFilter, def.getFilter, type.getFilter]);
        if (!filter.isItemAllowed(def, this)) return false;

        if (def.isArmour && wearsBodyArmour(armory)) return false;
        if (def.isShield && wearsShield(armory)) return false;

        return true;
      }));

  UnmodifiableListView<EquipmentUse> availableEquipment(
      Roster roster, Armory armory) {
    return UnmodifiableListView(roster.equipment.where((equip) {
      final def = armory.findEquipment(equip);

      final filter =
          FilterItem.allOf([equip.getFilter, def.getFilter, type.getFilter]);
      if (!filter.isItemAllowed(def, this)) return false;

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
