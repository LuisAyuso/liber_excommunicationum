import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

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

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyToJson(this);
}

@JsonSerializable()
class Unit {
  Unit();

  String name = "";
  int max = 1;
  int movement = 6;
  int ranged = 0;
  int melee = 0;
  int armor = 0;
  List<String> abilities = [];
  List<String> keywords = [];
  Currency cost = Currency(ducats: 0);
  int base = 25;
  List<String>? builtInItems = [];

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

abstract class ItemUse {
  UnmodifiableListView<String> get getUnitNameFilter;
  UnmodifiableListView<String> get getKeywordFilter;
  bool get isBuiltIn;
  Currency get getCost;
}

@JsonSerializable(explicitToJson: true)
class WeaponUse extends ItemUse {
  WeaponUse({String? name, bool? builtIn})
      : name = name ?? "",
        builtIn = builtIn ?? false;

  String name = "";
  Currency cost = Currency(ducats: 0);
  bool? builtIn;

  List<String>? unitNameFilter;
  @override
  UnmodifiableListView<String> get getUnitNameFilter =>
      UnmodifiableListView(unitNameFilter ?? []);

  List<String>? keywordFilter;
  @override
  UnmodifiableListView<String> get getKeywordFilter =>
      UnmodifiableListView(keywordFilter ?? []);

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
  Currency cost = Currency.free();
  bool? builtIn;

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  List<String>? unitNameFilter;
  @override
  UnmodifiableListView<String> get getUnitNameFilter =>
      UnmodifiableListView(unitNameFilter ?? []);

  List<String>? keywordFilter;
  @override
  UnmodifiableListView<String> get getKeywordFilter =>
      UnmodifiableListView(keywordFilter ?? []);

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
  Currency cost = Currency.free();
  bool? builtIn;

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  List<String>? unitNameFilter;
  @override
  UnmodifiableListView<String> get getUnitNameFilter =>
      UnmodifiableListView(unitNameFilter ?? []);

  List<String>? keywordFilter;
  @override
  UnmodifiableListView<String> get getKeywordFilter =>
      UnmodifiableListView(keywordFilter ?? []);

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
class Armor extends Item {
  Armor();
  String name = "";
  int? value;
  List<String>? special = [];
  List<String>? keywords = [];

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  bool get isShield => name.contains("Shield");
  bool get isArmour => name.contains("Armour");
  factory Armor.fromJson(Map<String, dynamic> json) => _$ArmorFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorToJson(this);
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
  List<Armor> armors = [];
  List<Equipment> equipments = [];

  factory Armory.fromJson(Map<String, dynamic> json) => _$ArmoryFromJson(json);
  Map<String, dynamic> toJson() => _$ArmoryToJson(this);
}
