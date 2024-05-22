import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'warband.g.dart';

class ItemSerializeWrapper {
  ItemSerializeWrapper({required this.item}) : _kind = item.kind;
  ItemKind _kind;
  ItemUse item;

  factory ItemSerializeWrapper.fromJson(Map<String, dynamic> json) {
    ItemUse item = switch (json['_kind'] as String) {
      "ItemKind.weapon" => WeaponUse.fromJson(json["item"]),
      "ItemKind.armour" => ArmourUse.fromJson(json["item"]),
      "ItemKind.equipment" => EquipmentUse.fromJson(json["item"]),
      _ => throw Exception("Not a serialization wrapper")
    };
    return ItemSerializeWrapper(item: item);
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      '_kind': _kind.toString(),
      'item': item.toJson(),
    };
  }
}

@JsonSerializable(explicitToJson: true)
class ItemStack {
  ItemStack({ItemUse? item})
      : privateStack = item != null ? [ItemSerializeWrapper(item: item)] : [];
  List<ItemSerializeWrapper> privateStack = [];

  ItemUse get value {
    assert(privateStack.isNotEmpty, "this can not be empty, ever");
    return privateStack.last.item;
  }

  bool get isEmpty => privateStack.isEmpty;

  bool pop() {
    privateStack.removeLast();
    return privateStack.isEmpty;
  }

  void replace(ItemUse item) {
    privateStack.add(ItemSerializeWrapper(item: item));
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

@JsonSerializable(explicitToJson: true)
class WarriorModel {
  WarriorModel(
      {String? name,
      required this.uid,
      required this.type,
      required this.bucket,
      Sex? sex,
      Armory? armory})
      : name = name ?? "Generated" {
    sex = sex ?? type.sex;
    if (armory != null) populateBuiltIn(armory);
  }

  WarriorModel copyWith({required String name, required int newUid}) {
    var w = WarriorModel(name: name, uid: newUid, type: type, bucket: bucket);
    w.privateItems = [];
    for (var it in privateItems) {
      w.privateItems.add(it.copy());
    }
    return w;
  }

  String name = "Generated name?";
  int uid;
  Unit type;
  int bucket;

  Sex? sex;
  Sex get getSex => sex ?? Sex.custom;

  List<ItemStack> privateItems = [];
  Iterable<ItemUse> get items => privateItems.map((s) => s.value);
  Iterable<WeaponUse> get weapons =>
      privateItems.map((s) => s.value).whereType<WeaponUse>();

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

  Iterable<ArmourUse> get armour =>
      privateItems.map((s) => s.value).whereType<ArmourUse>();
  Iterable<EquipmentUse> get equipment =>
      privateItems.map((s) => s.value).whereType<EquipmentUse>();

  Currency get totalCost => baseCost + equipmentCost;
  Currency get baseCost => type.cost;
  Currency get equipmentCost => privateItems
      .map((i) => i.value)
      .fold<Currency>(Currency.free(), (v, w) => w.getCost + v);

  void addItem(ItemUse item, Armory armoury) {
    privateItems.add(ItemStack(item: item));
    // TODO: come out with one example when adding one element can invalidate the rest
    //removeInvalid(armoury);
  }

  void removeItem(ItemUse item, Armory armoury) {
    for (var it in privateItems) {
      if (it.value.getName == item.getName) {
        it.pop();
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
      final filter =
          FilterItem.allOf([item.getFilter, def.getFilter, type.getFilter]);
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

  void populateBuiltIn(Armory armory) {
    for (var item in type.defaultItems ?? []) {
      if (armory.isWeapon(item.itemName)) {
        addItem(
            WeaponUse(
                typeName: item.itemName,
                removable: item.isRemovable,
                cost: item.getCost),
            armory);
      }
      if (armory.isArmour(item.itemName)) {
        addItem(
            ArmourUse(
                typeName: item.itemName,
                removable: item.isRemovable,
                cost: item.getCost),
            armory);
      }
      if (armory.isEquipment(item.itemName)) {
        addItem(
            EquipmentUse(
                typeName: item.itemName,
                removable: item.isRemovable,
                cost: item.getCost),
            armory);
      }
    }
  }

  int computeArmorValue(Armory armory) {
    return type.armour +
        armour
            .map((a) => armory.findArmour(a).value ?? 0)
            .fold(0, (a, b) => a + b);
  }

  bool get isStrong => type.keywords.contains("STRONG");

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
  int freeHands(Armory armory) {
    final strong = isStrong;
    return type.getHands -
        getWeapons(armory)
            .where((w) => w.isMeleeWeapon)
            .fold(0, (v, w) => v + (strong ? 1 : w.hands));
  }

// - One firearm and one pistol OR
// - two pistols.
// In addition, they may carry:
// - One two-handed melee weapon OR
// - one single-handed melee weapon and a trench shield OR
// - two single-handed melee weapons.
  UnmodifiableListView<WeaponUse> availableWeapons(
      Roster roster, Armory armory) {
    return UnmodifiableListView(roster.weapons.where((use) {
      final def = armory.findWeapon(use);

      // no repetitions of greandes
      if (def.isGrenade &&
          weapons.where((w) => w.getName == use.getName).isNotEmpty) {
        return false;
      }

      final filter =
          FilterItem.allOf([use.getFilter, def.getFilter, type.getFilter]);
      if (!filter.isItemAllowed(def, this)) return false;

      // Bypass of normal algorithm for the Amalgam, as many weapons as hands
      if (!type.hasBackpack) {
        final handsInUse = getWeapons(armory).fold(0, (v, w) => v + w.hands) +
            getArmours(armory).where((a) => a.isShield).length +
            def.hands;
        return (handsInUse <= type.getHands);
      }

      if (def.isGrenade) return true;
      if (def.isPistol && allowPistol(armory)) return true;
      if (def.isFirearm && firearmsCount(armory) < 1) {
        return true;
      }

      if (def.isMeleeWeapon && allowMelee(armory)) {
        return freeHands(armory) >= def.hands;
      }

      return false;
    }));
  }

  bool wearsBodyArmour(Armory armory) =>
      getArmours(armory).where((a) => a.isBodyArmour).isNotEmpty;
  bool wearsShield(Armory armory) =>
      getArmours(armory).where((a) => a.isShield).isNotEmpty;

  UnmodifiableListView<ArmourUse> availableArmours(
          Roster roster, Armory armory) =>
      UnmodifiableListView(roster.armour.where((use) {
        final def = armory.findArmour(use);

        // no repetitions
        if (!def.isConsumable &&
            armour.where((w) => w.getName == use.getName).isNotEmpty) {
          return false;
        }

        final filter =
            FilterItem.allOf([use.getFilter, def.getFilter, type.getFilter]);
        if (!filter.isItemAllowed(def, this)) return false;

        // Bypass of normal algorithm for the Amalgam, as many weapons as hands
        if (!type.hasBackpack && def.isShield) {
          final handsInUse = getWeapons(armory).fold(0, (v, w) => v + w.hands) +
              getArmours(armory).where((a) => a.isShield).length;
          return ((handsInUse + 1) <= type.getHands);
        }

        if (def.isBodyArmour && wearsBodyArmour(armory)) return false;
        if (def.isShield && wearsShield(armory)) return false;

        return true;
      }));

  UnmodifiableListView<EquipmentUse> availableEquipment(
      Roster roster, Armory armory) {
    return UnmodifiableListView(roster.equipment.where((equip) {
      final def = armory.findEquipment(equip);
      if (!def.isConsumable &&
          equipment.where((e) => e.typeName == def.typeName).isNotEmpty) {
        return false;
      }
      final filter =
          FilterItem.allOf([equip.getFilter, def.getFilter, type.getFilter]);
      if (!filter.isItemAllowed(def, this)) return false;
      return true;
    }));
  }

  factory WarriorModel.fromJson(Map<String, dynamic> json) =>
      _$WarriorModelFromJson(json);
  Map<String, dynamic> toJson() => _$WarriorModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WarbandModel extends ChangeNotifier {
  WarbandModel();

  String name = "";
  List<WarriorModel> items = [];
  int id = 0;

  int get length => items.length;
  Currency get cost =>
      items.fold<Currency>(Currency.free(), (v, w) => v + w.totalCost);

  int nextUID() {
    return ++id;
  }

  void add(WarriorModel item) {
    items.add(item);
    items.sort((a, b) => a.bucket.compareTo(b.bucket));
    notifyListeners();
  }

  WarriorModel getUID(int uid) {
    return items.firstWhere((w) => w.uid == uid);
  }

  void removeUID(int uid) {
    items.removeWhere((w) => w.uid == uid);
    notifyListeners();
  }

  void clear() {
    items.clear();
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
        wm.add(WarriorModel(
            name: makeName(roster, unit.sex, unit.isElite),
            uid: wm.nextUID(),
            type: unit,
            bucket: bucket,
            armory: armory));
      }
      bucket++;
    }
    return wm;
  }

  factory WarbandModel.fromJson(Map<String, dynamic> json) =>
      _$WarbandModelFromJson(json);
  Map<String, dynamic> toJson() => _$WarbandModelToJson(this);
}
