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

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WeaponUse {
  WeaponUse();

  String name = "";
  Currency cost = Currency(ducats: 0);

  List<String>? _keywordFilter;
  UnmodifiableListView<String> get keywordFilter =>
      UnmodifiableListView(_keywordFilter ?? []);

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  factory WeaponUse.fromJson(Map<String, dynamic> json) =>
      _$WeaponUseFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ArmorUse {
  ArmorUse();

  String name = "";
  Currency cost = Currency.free();

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  List<String>? _keywordFilter;
  UnmodifiableListView<String> get keywordFilter =>
      UnmodifiableListView(_keywordFilter ?? []);

  factory ArmorUse.fromJson(Map<String, dynamic> json) =>
      _$ArmorUseFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EquipmentUse {
  EquipmentUse();

  String name = "";
  Currency cost = Currency.free();

  int? _limit;
  int get limit => _limit ?? double.maxFinite.toInt();

  List<String>? _keywordFilter;
  UnmodifiableListView<String> get keywordFilter =>
      UnmodifiableListView(_keywordFilter ?? []);

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

@JsonSerializable(explicitToJson: true)
class Weapon {
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

  factory Weapon.fromJson(Map<String, dynamic> json) => _$WeaponFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Armor {
  Armor();
  String name = "";
  int? value;
  List<String>? special = [];

  bool get isShield => name.contains("Shield");
  bool get isArmour => name.contains("Armour");
  factory Armor.fromJson(Map<String, dynamic> json) => _$ArmorFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Equipment {
  Equipment();

  String name = "";
  bool? consumable;

  bool get isConsumable => consumable ?? false;

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
