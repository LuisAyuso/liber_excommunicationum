import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Filter {
  Filter({this.whitelist, this.blacklist, this.none});

  bool? none = false;
  List<String>? whitelist;
  List<String>? blacklist;

  factory Filter.whitelist(List<String> list) => Filter(whitelist: list);
  factory Filter.blacklist(List<String> list) => Filter(blacklist: list);
  factory Filter.none() => Filter(none: true);
  factory Filter.any() => Filter();

  bool isAllowed(String typeName) {
    if (none ?? false) {
      return false;
    }

    bool allowed = true;
    if (whitelist != null) {
      allowed =
          allowed && whitelist!.where((str) => str == typeName).isNotEmpty;
    }
    if (blacklist != null) {
      allowed = allowed && blacklist!.where((str) => str == typeName).isEmpty;
    }
    return allowed;
  }

  factory Filter.fromJson(Map<String, dynamic> json) => _$FilterFromJson(json);
  Map<String, dynamic> toJson() => _$FilterToJson(this);
}

@JsonSerializable()
class Currency {
  Currency({int? ducats, int? glory})
      : _ducats = ducats,
        _glory = glory;

  final int? _ducats;
  final int? _glory;

  bool get isGlory => _glory != null;
  bool get isDucats => _ducats != null;

  int get glory => _glory ?? 0;
  int get ducats => _ducats ?? 0;

  factory Currency.free() => Currency(ducats: 0);
  factory Currency.ducats(int v) => Currency(ducats: v);
  factory Currency.glory(int v) => Currency(glory: v);

  Currency operator +(Currency other) {
    return Currency(ducats: ducats + other.ducats, glory: glory + other.glory);
  }

  @override
  String toString() {
    return isDucats ? "$_ducats Ducats" : "$_glory Glory";
  }

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyToJson(this);
}

@JsonSerializable()
class ItemReplacement {
  ItemReplacement();

  List<String> anyOf = [];

  factory ItemReplacement.fromJson(Map<String, dynamic> json) =>
      _$ItemReplacementFromJson(json);
  Map<String, dynamic> toJson() => _$ItemReplacementToJson(this);
}

@JsonSerializable()
class DefaultItem {
  DefaultItem();

  String itemName = "";

  Currency? cost;
  Currency get getCost => cost ?? Currency.free();

  List<ItemReplacement>? replacements;

  bool? removable;
  bool get isRemovable => removable ?? (replacements ?? []).isNotEmpty;

  factory DefaultItem.fromJson(Map<String, dynamic> json) =>
      _$DefaultItemFromJson(json);
  Map<String, dynamic> toJson() => _$DefaultItemToJson(this);
}

@JsonSerializable()
class Unit {
  Unit();

  String typeName = "";
  int? max;
  int? min;
  int movement = 6;
  int ranged = 0;
  int melee = 0;
  int armour = 0;
  List<String>? abilities = [];
  List<String> keywords = [];
  List<DefaultItem>? defaultItems;
  Currency cost = Currency(ducats: 0);
  int base = 25;

  Filter? rangedWeaponFilter;
  Filter get getRangedWeaponFilter => rangedWeaponFilter ?? Filter();
  Filter? meleeWeaponFilter;
  Filter get getMeleeWeaponFilter => meleeWeaponFilter ?? Filter();
  Filter? armourFilter;
  Filter get getArmourFilter => armourFilter ?? Filter();
  Filter? equipmentFilter;
  Filter get getEquipmentFilter => equipmentFilter ?? Filter();

  factory Unit.fromJson(Map<String, dynamic> json) {
    for (var e in json.entries) {
      debugPrint("${e.key} : ${e.value}");
    }
    return _$UnitFromJson(json);
  }
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

abstract class ItemUse {
  String get getName;
  Filter get getUnitNameFilter;
  Filter get getKeywordFilter;
  bool get isRemovable;
  Currency get getCost;
  int get getLimit;
}

@JsonSerializable(explicitToJson: true)
class WeaponUse extends ItemUse {
  WeaponUse({String? typeName, bool? removable, Currency? cost})
      : typeName = typeName ?? "",
        removable = removable ?? true,
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = Currency(ducats: 0);
  bool? removable;

  Filter? unitNameFilter;
  Filter? keywordFilter;
  int? limit;

  @override
  String get getName => typeName;
  @override
  Currency get getCost => cost;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();
  @override
  bool get isRemovable => removable ?? true;
  @override
  int get getLimit => limit ?? double.maxFinite.toInt();

  factory WeaponUse.fromJson(Map<String, dynamic> json) =>
      _$WeaponUseFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ArmorUse extends ItemUse {
  ArmorUse({String? typeName, bool? removable, Currency? cost})
      : typeName = typeName ?? "",
        removable = removable ?? true,
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = Currency.free();
  bool? removable;
  int? limit;

  @override
  String get getName => typeName;
  Filter? unitNameFilter;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  Filter? keywordFilter;
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();
  @override
  bool get isRemovable => removable ?? true;
  @override
  int get getLimit => limit ?? double.maxFinite.toInt();
  @override
  Currency get getCost => cost;

  factory ArmorUse.fromJson(Map<String, dynamic> json) =>
      _$ArmorUseFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EquipmentUse extends ItemUse {
  EquipmentUse({String? typeName, bool? removable, Currency? cost})
      : typeName = typeName ?? "",
        removable = removable ?? true,
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = Currency.free();
  bool? removable;
  int? limit;
  Filter? unitNameFilter;
  Filter? keywordFilter;

  @override
  String get getName => typeName;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();
  @override
  bool get isRemovable => removable ?? true;
  @override
  Currency get getCost => cost;
  @override
  int get getLimit => limit ?? double.maxFinite.toInt();

  factory EquipmentUse.fromJson(Map<String, dynamic> json) =>
      _$EquipmentUseFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Roster {
  Roster();

  List<String> namesM = [];
  List<String> namesF = [];
  List<String> surnames = [];
  List<Unit> units = [];
  List<WeaponUse> weapons = [];
  List<ArmorUse> armour = [];
  List<EquipmentUse> equipment = [];

  List<Weapon>? uniqueWeapons = [];
  List<Armour>? uniqueArmour = [];
  List<Equipment>? uniqueEquipment = [];

  List<dynamic> get items =>
      weapons.map<dynamic>((e) => e).toList() +
      armour.map<dynamic>((e) => e).toList() +
      equipment.map<dynamic>((e) => e).toList();

  factory Roster.fromJson(Map<String, dynamic> json) => _$RosterFromJson(json);
  Map<String, dynamic> toJson() => _$RosterToJson(this);
}

abstract class Item {
  UnmodifiableListView<String> get getKeywords;
}

String bonus(int v) {
  final sign = v > 0 ? "+" : "";
  return "$sign$v";
}

@JsonSerializable(explicitToJson: true)
class Modifier {
  Modifier({this.hit, this.injury, this.extra});

  int? attacks;
  int? hit;
  int? injury;
  String? extra;

  @override
  String toString() {
    final suffix = extra == null ? "" : " $extra";
    if (attacks != null) return "$attacks Attacks$suffix";
    if (hit != null) return "${bonus(hit!)} to Hit$suffix";
    if (injury != null) return "${bonus(injury!)} to Injury$suffix";
    return extra ?? "";
  }

  factory Modifier.fromJson(Map<String, dynamic> json) =>
      _$ModifierFromJson(json);
  Map<String, dynamic> toJson() => _$ModifierToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Weapon extends Item {
  Weapon();
  String typeName = "";
  int hands = 1;
  int? range;
  bool? melee;
  List<String>? keywords;
  List<Modifier> modifiers = [];

  bool get canMelee => range == null || (melee ?? false);
  bool get canRanged => range != null;
  bool get isPistol => typeName.contains("Pistol");
  bool get isFirearm => canRanged && !typeName.contains("Pistol");
  bool get isMeleeWeapon => !canRanged && canMelee;
  bool get isRifle => typeName.contains("Rifle");
  String get getModifiersString => modifiers.fold<String>("", (v, m) {
        if (v == "") return m.toString();
        return "$v; ${m.toString()}";
      });

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  factory Weapon.fromJson(Map<String, dynamic> json) => _$WeaponFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Armour extends Item {
  Armour();
  String typeName = "";
  int? value;
  List<String>? special = [];
  List<String>? keywords = [];

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  bool get isShield => typeName.contains("Shield");
  bool get isArmour => typeName.contains("Armour");
  factory Armour.fromJson(Map<String, dynamic> json) => _$ArmourFromJson(json);
  Map<String, dynamic> toJson() => _$ArmourToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Equipment extends Item {
  Equipment();

  String typeName = "";
  bool? consumable;
  List<String>? keywords = [];

  bool get isConsumable => consumable ?? false;

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Armory {
  Armory();

  List<Weapon> weapons = [];
  List<Armour> armours = [];
  List<Equipment> equipments = [];

  factory Armory.fromJson(Map<String, dynamic> json) => _$ArmoryFromJson(json);
  Map<String, dynamic> toJson() => _$ArmoryToJson(this);

  Weapon findWeapon(String typeName) {
    return weapons.firstWhere((def) => def.typeName == typeName);
  }

  bool isWeapon(String typeName) {
    return weapons.where((def) => def.typeName == typeName).length == 1;
  }

  Armour findArmour(String typeName) {
    return armours.firstWhere((def) => def.typeName == typeName);
  }

  bool isArmour(String typeName) {
    return armours.where((def) => def.typeName == typeName).length == 1;
  }

  Equipment findEquipment(String typeName) {
    return equipments.firstWhere((def) => def.typeName == typeName);
  }

  bool isEquipment(String typeName) {
    return equipments.where((def) => def.typeName == typeName).length == 1;
  }
}
