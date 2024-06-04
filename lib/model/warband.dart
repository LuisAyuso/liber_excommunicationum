import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tc_thing/model/filters.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/utils/name_generator.dart';
import 'package:json_annotation/json_annotation.dart';

part 'warband.g.dart';

@JsonSerializable(explicitToJson: true)
class ItemStack {
  ItemStack({ItemUse? item}) : privateStack = [item].nonNulls.toList();
  List<ItemUse> privateStack = [];

  ItemUse get value {
    assert(privateStack.isNotEmpty, "this can not be empty, ever");
    return privateStack.last;
  }

  bool get isEmpty => privateStack.isEmpty;

  bool pop() {
    privateStack.removeLast();
    return privateStack.isEmpty;
  }

  void replace(ItemUse item) {
    privateStack.add(item);
  }

  ItemStack copy() {
    ItemStack s = ItemStack();
    s.privateStack = List.of(privateStack);
    return s;
  }

  factory ItemStack.fromJson(Map<String, dynamic> json) =>
      _$ItemStackFromJson(json);
  Map<String, dynamic> toJson() => _$ItemStackToJson(this);
}

class UseAndDef<T> {
  UseAndDef(this.use, T? def) : _def = def;
  final ItemUse use;
  final T? _def;
  T get def => _def!;
  bool get isValid => _def != null;
  String get name => use.getName;
}

@JsonSerializable(explicitToJson: true)
class WarriorModel {
  WarriorModel(
      {String? name,
      required this.uid,
      required this.type,
      required this.bucket,
      Sex? sex})
      : name = name ?? "Generated" {
    sex = sex ?? type.sex;
  }

  String name = "Generated name?";
  int uid;
  Unit type;
  int bucket;

  Sex? sex;
  Sex get getSex => sex ?? Sex.custom;
  List<ItemStack> privateItems = [];
  List<UnitUpgrade> appliedUpgrades = [];

  Iterable<ItemUse> get items => privateItems.map((s) => s.value);
  Currency get upgradesCost => appliedUpgrades
      .map((u) => u.cost)
      .nonNulls
      .fold(Currency.free(), (a, b) => a + b);
  Iterable<String> get kewordUpgrades => appliedUpgrades
      .map((up) => up.keyword?.keywords ?? <String>[])
      .expand((l) => l);

  Iterable<UseAndDef<Weapon>> weaponsOrUnarmed(Armory armory) {
    final res = currentWeapon(armory).where((w) => w.def.canMelee);
    if (res.isNotEmpty || !type.suffersUnarmedPenalty) return res;

    return [
      UseAndDef(
          ItemUse(typeName: "Unarmed", removable: false), Weapon.unarmed())
    ];
  }

  Iterable<UseAndDef<Weapon>> currentWeapon(Armory armory) {
    return privateItems
        .map((use) => UseAndDef(use.value, armory.findWeapon(use.value)))
        .where((x) => x.isValid);
  }

  Iterable<UseAndDef<Armour>> currentArmour(Armory armory) {
    return privateItems
        .map((use) => UseAndDef(use.value, armory.findArmour(use.value)))
        .where((x) => x.isValid);
  }

  Iterable<UseAndDef<Equipment>> currentEquipment(Armory armory) {
    return privateItems
        .map((use) => UseAndDef(use.value, armory.findEquipment(use.value)))
        .where((x) => x.isValid);
  }

  Currency get totalCost => baseCost + equipmentCost + upgradesCost;
  Currency get baseCost => type.cost;
  Currency get equipmentCost => privateItems
      .map((i) => i.value)
      .fold<Currency>(Currency.free(), (v, w) => w.getCost + v);

  UnmodifiableListView<String> get effectiveKeywords => UnmodifiableListView([
        ...kewordUpgrades,
        ...type.keywords,
        ...items.map((i) => i.addedKeywords).expand((i) => i)
      ]);

  WarriorModel clone() {
    var w = WarriorModel(name: name, uid: uid, type: type, bucket: bucket);
    w.privateItems = [];
    for (var it in privateItems) {
      w.privateItems.add(it.copy());
    }
    return w;
  }

  WarriorModel cloneWith({required String name, required int newUid}) {
    var w = WarriorModel(name: name, uid: newUid, type: type, bucket: bucket);

    w.privateItems = [];
    for (var it in privateItems) {
      w.privateItems.add(it.copy());
    }
    w.appliedUpgrades = List.from(appliedUpgrades);
    return w;
  }

  void addItem(ItemUse item) {
    privateItems.add(ItemStack(item: item));
  }

  void removeItem(ItemUse item, Armory armoury) {
    for (var it in privateItems) {
      if (it.value.getName == item.getName) {
        it.pop();
        break;
      }
    }
    privateItems.removeWhere((innerList) => innerList.isEmpty);
    assert(privateItems.where((s) => s.isEmpty).isEmpty);
    removeInvalid(armoury);
  }

  void removeInvalid(Armory armoury) {
    List<ItemUse> toRemove = [];
    for (var s in privateItems) {
      final item = s.value;
      final def = armoury.findItem(item);
      if (def == null) continue;
      final filter = ItemFilter.allOf(
          [item.getFilter, def.getFilter, type.effectiveItemFilter]);
      if (!filter.isItemAllowed(def, this)) {
        toRemove.add(item);
      }
    }

    for (var item in toRemove) {
      removeItem(item, armoury);
    }
  }

  void replace(ItemUse oldItem, ItemUse newItem, Armory armory) {
    for (var stack in privateItems) {
      if (stack.value.getName == oldItem.getName) stack.replace(newItem);
    }
    removeInvalid(armory);
  }

  void populateBuiltIn(Roster roster, Armory armory) {
    for (var item in type.defaultItems ?? []) {
      addItem(
        ItemUse(
            typeName: item.itemName,
            removable: item.isRemovable,
            cost: item.getCost),
      );
    }
  }

  int computeArmorValue(Armory armory) {
    return type.armour +
        currentArmour(armory)
            .map((a) => a.def.value ?? 0)
            .fold(0, (a, b) => a + b);
  }

  bool get isStrong => type.keywords.contains("STRONG");

  int pistolsCount(Armory armory) =>
      currentWeapon(armory).where((w) => w.def.isPistol).length;
  int firearmsCount(Armory armory) =>
      currentWeapon(armory).where((w) => w.def.isFirearm).length;
  int meleeCount(Armory armory) =>
      currentWeapon(armory).where((w) => w.def.isMeleeWeapon).length;

  bool allowPistol(Armory armory) =>
      (firearmsCount(armory) == 0 && pistolsCount(armory) < 2) ||
      (firearmsCount(armory) == 1 && pistolsCount(armory) < 1);
  bool allowMelee(Armory armory) =>
      currentArmour(armory).where((a) => a.def.isShield).isEmpty
          ? meleeCount(armory) <= 2
          : meleeCount(armory) <= 1;
  int handsInUse(Armory armory) => currentWeapon(armory)
      .where((w) => w.def.isMeleeWeapon)
      .fold(0, (v, w) => v + (isStrong ? 1 : w.def.hands));
  int freeHands(Armory armory) => type.getHands - handsInUse(armory);

// - One firearm and one pistol OR
// - two pistols.
// In addition, they may carry:
// - One two-handed melee weapon OR
// - one single-handed melee weapon and a trench shield OR
// - two single-handed melee weapons.
  Iterable<UseAndDef<Weapon>> availableWeapons(
      Iterable<UseAndDef<Weapon>> weapons, Armory armory) {
    return weapons.where((weapon) {
      // no repetitions of greandes
      if (weapon.def.isGrenade &&
          items.where((i) => i.getName == weapon.use.getName).isNotEmpty) {
        return false;
      }

      final filter = ItemFilter.allOf([
        weapon.use.getFilter,
        weapon.def.getFilter,
        type.effectiveItemFilter
      ]);
      if (!filter.isItemAllowed(weapon.def, this)) return false;

      // Bypass of normal algorithm for the Amalgam, as many weapons as hands
      if (!type.hasBackpack) {
        return (handsInUse(armory) <= type.getHands);
      }

      if (weapon.def.isGrenade) return true;
      if (weapon.def.isPistol && allowPistol(armory)) return true;
      if (weapon.def.isFirearm && firearmsCount(armory) < 1) {
        return true;
      }

      if (weapon.def.isMeleeWeapon && allowMelee(armory)) {
        return freeHands(armory) >= weapon.def.hands;
      }

      return false;
    });
  }

  bool wearsBodyArmour(Armory armory) =>
      currentArmour(armory).where((a) => a.def.isBodyArmour).isNotEmpty;
  bool wearsShield(Armory armory) =>
      currentArmour(armory).where((a) => a.def.isShield).isNotEmpty;

  Iterable<UseAndDef<Armour>> availableArmours(
          Iterable<UseAndDef<Armour>> armours, Armory armory) =>
      armours.where((armour) {
        // no repetitions
        if (!armour.def.isConsumable &&
            items.where((i) => i.getName == armour.use.getName).isNotEmpty) {
          return false;
        }

        final filter = ItemFilter.allOf([
          armour.use.getFilter,
          armour.def.getFilter,
          type.effectiveItemFilter,
        ]);
        if (!filter.isItemAllowed(armour.def, this)) return false;

        // Bypass of normal algorithm for the Amalgam, as many weapons as hands
        if (!type.hasBackpack && armour.def.isShield) {
          final handsInUse =
              currentWeapon(armory).fold(0, (v, w) => v + w.def.hands) +
                  currentArmour(armory).where((a) => a.def.isShield).length;
          return ((handsInUse + 1) <= type.getHands);
        }

        if (armour.def.isBodyArmour && wearsBodyArmour(armory)) return false;
        if (armour.def.isShield && wearsShield(armory)) return false;

        return true;
      });

  Iterable<UseAndDef<Equipment>> availableEquipment(
      Iterable<UseAndDef<Equipment>> equipment, Armory armory) {
    return equipment.where((equ) {
      if (!armory.isEquipment(equ.use)) return false;

      if (!equ.def.isConsumable &&
          items.where((i) => i.getName == equ.use.getName).isNotEmpty) {
        return false;
      }
      final filter = ItemFilter.allOf([
        equ.use.filter,
        equ.def.getFilter,
        type.effectiveItemFilter
      ].nonNulls);
      if (!filter.isItemAllowed(equ.def, this)) return false;
      return true;
    });
  }

  @override
  String toString() {
    return "$name [${type.typeName}]";
  }

  factory WarriorModel.fromJson(Map<String, dynamic> json) =>
      _$WarriorModelFromJson(json);
  Map<String, dynamic> toJson() => _$WarriorModelToJson(this);
  Modifier getModifiers(ModifierType modType) {
    return Modifier(
        type: modType,
        hit: switch (modType) {
          ModifierType.melee => type.melee,
          ModifierType.ranged => type.ranged,
          ModifierType.any => 0,
        });
  }

  bool apply(UnitUpgrade u, Roster roster) {
    if (u.keyword != null || u.ability != null) {
      appliedUpgrades.add(u);
      return true;
    }
    // is a type upgrade?
    if (u.unit != null) {
      type = roster.units.firstWhere((unit) => unit.typeName == u.unit!);
      return true;
    }

    return false;
  }
}

@JsonSerializable(explicitToJson: true)
class WarbandModel extends ChangeNotifier {
  WarbandModel();

  String name = "";
  List<WarriorModel> warriors = [];
  int id = 0;

  int get length => warriors.length;
  Currency get cost =>
      warriors.fold<Currency>(Currency.free(), (v, w) => v + w.totalCost);

  int nextUID() {
    return ++id;
  }

  void add(WarriorModel item) {
    warriors.add(item);
    warriors.sort((a, b) => a.bucket.compareTo(b.bucket));
    notifyListeners();
  }

  WarriorModel getUID(int uid) {
    return warriors.firstWhere((w) => w.uid == uid);
  }

  void removeUID(int uid) {
    warriors.removeWhere((w) => w.uid == uid);
    notifyListeners();
  }

  void clear() {
    warriors.clear();
    notifyListeners();
  }

  void invalidate() {
    notifyListeners();
  }

  factory WarbandModel.prefill(Roster roster, Armory armory) {
    var wm = WarbandModel();
    int bucket = 0;
    for (var unit in roster.units) {
      for (var i = 0; i < (unit.min ?? 0); i++) {
        final newWarrior = WarriorModel(
          name: generateName(unit.sex, unit.keywords),
          uid: wm.nextUID(),
          type: unit,
          bucket: bucket,
        );
        newWarrior.populateBuiltIn(roster, armory);
        wm.add(newWarrior);
      }
      bucket++;
    }
    return wm;
  }

  factory WarbandModel.fromJson(Map<String, dynamic> json) =>
      _$WarbandModelFromJson(json);
  Map<String, dynamic> toJson() => _$WarbandModelToJson(this);
}
