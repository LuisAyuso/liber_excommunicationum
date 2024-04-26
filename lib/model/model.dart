import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

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
  int cost = 0;
  int base = 25;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WeaponUse {
  WeaponUse();

  String name = "";
  int cost = 0;
  int? limit = 0;

  factory WeaponUse.fromJson(Map<String, dynamic> json) =>
      _$WeaponUseFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ArmorUse {
  ArmorUse();

  String name = "";
  int cost = 0;

  factory ArmorUse.fromJson(Map<String, dynamic> json) =>
      _$ArmorUseFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EquipmentUse {
  EquipmentUse();

  String name = "";
  int cost = 0;

  factory EquipmentUse.fromJson(Map<String, dynamic> json) =>
      _$EquipmentUseFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Roster {
  Roster();

  List<String> names = [];
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
  factory Armor.fromJson(Map<String, dynamic> json) => _$ArmorFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Equipment {
  Equipment();

  String name = "";
  List<String> special = [];

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
