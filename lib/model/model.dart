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

  bool isAllowed(String name) {
    if (none ?? false) {
      return false;
    }

    bool allowed = true;
    if (whitelist != null) {
      allowed = allowed && whitelist!.where((str) => str == name).isNotEmpty;
    }
    if (blacklist != null) {
      allowed = allowed && blacklist!.where((str) => str == name).isEmpty;
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
class Unit {
  Unit();

  String name = "";
  int? max;
  int? min;
  int movement = 6;
  int ranged = 0;
  int melee = 0;
  int armor = 0;
  List<String> abilities = [];
  List<String> keywords = [];
  Currency cost = Currency(ducats: 0);
  int base = 25;
  List<String>? builtInItems = [];
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
  bool get isBuiltIn;
  Currency get getCost;
}

@JsonSerializable(explicitToJson: true)
class WeaponUse extends ItemUse {
  WeaponUse({String? name, bool? builtIn})
      : name = name ?? "",
        builtIn = builtIn ?? false;

  String name = "";
  @override
  String get getName => name;
  Currency cost = Currency(ducats: 0);
  bool? builtIn;

  Filter? unitNameFilter;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  Filter? keywordFilter;
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();

  @override
  bool get isBuiltIn => builtIn ?? false;

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  @override
  Currency get getCost {
    return cost;
  }

  factory WeaponUse.fromJson(Map<String, dynamic> json) =>
      _$WeaponUseFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ArmorUse extends ItemUse {
  ArmorUse({String? name, bool? builtIn})
      : name = name ?? "",
        builtIn = builtIn ?? false;

  String name = "";
  @override
  String get getName => name;
  Currency cost = Currency.free();
  bool? builtIn;

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  Filter? unitNameFilter;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  Filter? keywordFilter;
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();

  @override
  bool get isBuiltIn => builtIn ?? false;

  @override
  Currency get getCost {
    return cost;
  }

  factory ArmorUse.fromJson(Map<String, dynamic> json) =>
      _$ArmorUseFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EquipmentUse extends ItemUse {
  EquipmentUse({String? name, bool? builtIn})
      : name = name ?? "",
        builtIn = builtIn ?? false;

  String name = "";
  @override
  String get getName => name;
  Currency cost = Currency.free();
  bool? builtIn;

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  Filter? unitNameFilter;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  Filter? keywordFilter;
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();

  @override
  bool get isBuiltIn => builtIn ?? false;

  @override
  Currency get getCost {
    return cost;
  }

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
  List<ArmorUse> armor = [];
  List<EquipmentUse> equipment = [];

  List<dynamic> get items =>
      weapons.map<dynamic>((e) => e).toList() +
      armor.map<dynamic>((e) => e).toList() +
      equipment.map<dynamic>((e) => e).toList();

  factory Roster.fromJson(Map<String, dynamic> json) => _$RosterFromJson(json);
  Map<String, dynamic> toJson() => _$RosterToJson(this);
}

abstract class Item {
  UnmodifiableListView<String> get getKeywords;
}

@JsonSerializable(explicitToJson: true)
class Weapon extends Item {
  Weapon();
  String name = "";
  int hands = 1;
  int? range;
  int? ranged;
  int? melee;
  int? injury;
  List<String>? keywords;

  bool get canMelee => melee != null;
  bool get canRanged => ranged != null;
  bool get isPistol => name.contains("Pistol");
  bool get isFirearm => canRanged && !name.contains("Pistol");
  bool get isMeleeWeapon => !canRanged && canMelee;
  bool get isRifle => name.contains("Rifle");

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  factory Weapon.fromJson(Map<String, dynamic> json) => _$WeaponFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Armour extends Item {
  Armour();
  String name = "";
  int? value;
  List<String>? special = [];
  List<String>? keywords = [];

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  bool get isShield => name.contains("Shield");
  bool get isArmour => name.contains("Armour");
  factory Armour.fromJson(Map<String, dynamic> json) => _$ArmourFromJson(json);
  Map<String, dynamic> toJson() => _$ArmourToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Equipment extends Item {
  Equipment();

  String name = "";
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

  Weapon findWeapon(String name) {
    return weapons.firstWhere((def) => def.name == name);
  }

  Armour findArmour(String name) {
    return armours.firstWhere((def) => def.name == name);
  }

  Equipment findEquipment(String name) {
    return equipments.firstWhere((def) => def.name == name);
  }
}
