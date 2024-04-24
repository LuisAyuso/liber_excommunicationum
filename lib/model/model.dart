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
class Weapon {
  Weapon();

  String name = "";
  int cost = 0;
  int? limit = 0;

  factory Weapon.fromJson(Map<String, dynamic> json) => _$WeaponFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Armor {
  Armor();

  String name = "";
  int cost = 0;

  factory Armor.fromJson(Map<String, dynamic> json) => _$ArmorFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Equipment {
  Equipment();

  String name = "";
  int cost = 0;

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Roster {
  Roster();

  List<String> names = [];
  List<String> surnames = [];
  List<Unit> units = [];
  List<Weapon> weapons = [];
  List<Armor> armor = [];
  List<Equipment> equipment = [];

  factory Roster.fromJson(Map<String, dynamic> json) => _$RosterFromJson(json);
  Map<String, dynamic> toJson() => _$RosterToJson(this);
}
