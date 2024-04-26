// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit()
  ..name = json['name'] as String
  ..max = json['max'] as int
  ..movement = json['movement'] as int
  ..ranged = json['ranged'] as int
  ..melee = json['melee'] as int
  ..armor = json['armor'] as int
  ..abilities =
      (json['abilities'] as List<dynamic>).map((e) => e as String).toList()
  ..keywords =
      (json['keywords'] as List<dynamic>).map((e) => e as String).toList()
  ..cost = json['cost'] as int
  ..base = json['base'] as int;

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'name': instance.name,
      'max': instance.max,
      'movement': instance.movement,
      'ranged': instance.ranged,
      'melee': instance.melee,
      'armor': instance.armor,
      'abilities': instance.abilities,
      'keywords': instance.keywords,
      'cost': instance.cost,
      'base': instance.base,
    };

WeaponUse _$WeaponUseFromJson(Map<String, dynamic> json) => WeaponUse()
  ..name = json['name'] as String
  ..cost = json['cost'] as int;

Map<String, dynamic> _$WeaponUseToJson(WeaponUse instance) => <String, dynamic>{
      'name': instance.name,
      'cost': instance.cost,
    };

ArmorUse _$ArmorUseFromJson(Map<String, dynamic> json) => ArmorUse()
  ..name = json['name'] as String
  ..cost = json['cost'] as int;

Map<String, dynamic> _$ArmorUseToJson(ArmorUse instance) => <String, dynamic>{
      'name': instance.name,
      'cost': instance.cost,
    };

EquipmentUse _$EquipmentUseFromJson(Map<String, dynamic> json) => EquipmentUse()
  ..name = json['name'] as String
  ..cost = json['cost'] as int;

Map<String, dynamic> _$EquipmentUseToJson(EquipmentUse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'cost': instance.cost,
    };

Roster _$RosterFromJson(Map<String, dynamic> json) => Roster()
  ..namesM = (json['namesM'] as List<dynamic>).map((e) => e as String).toList()
  ..namesF = (json['namesF'] as List<dynamic>).map((e) => e as String).toList()
  ..surnames =
      (json['surnames'] as List<dynamic>).map((e) => e as String).toList()
  ..units = (json['units'] as List<dynamic>)
      .map((e) => Unit.fromJson(e as Map<String, dynamic>))
      .toList()
  ..weapons = (json['weapons'] as List<dynamic>)
      .map((e) => WeaponUse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..armor = (json['armor'] as List<dynamic>)
      .map((e) => ArmorUse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..equipment = (json['equipment'] as List<dynamic>)
      .map((e) => EquipmentUse.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$RosterToJson(Roster instance) => <String, dynamic>{
      'namesM': instance.namesM,
      'namesF': instance.namesF,
      'surnames': instance.surnames,
      'units': instance.units.map((e) => e.toJson()).toList(),
      'weapons': instance.weapons.map((e) => e.toJson()).toList(),
      'armor': instance.armor.map((e) => e.toJson()).toList(),
      'equipment': instance.equipment.map((e) => e.toJson()).toList(),
    };

Weapon _$WeaponFromJson(Map<String, dynamic> json) => Weapon()
  ..name = json['name'] as String
  ..hands = json['hands'] as int
  ..range = json['range'] as int?
  ..ranged = json['ranged'] as int?
  ..melee = json['melee'] as int?
  ..injury = json['injury'] as int?
  ..keywords =
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$WeaponToJson(Weapon instance) => <String, dynamic>{
      'name': instance.name,
      'hands': instance.hands,
      'range': instance.range,
      'ranged': instance.ranged,
      'melee': instance.melee,
      'injury': instance.injury,
      'keywords': instance.keywords,
    };

Armor _$ArmorFromJson(Map<String, dynamic> json) => Armor()
  ..name = json['name'] as String
  ..value = json['value'] as int?
  ..special =
      (json['special'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$ArmorToJson(Armor instance) => <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'special': instance.special,
    };

Equipment _$EquipmentFromJson(Map<String, dynamic> json) => Equipment()
  ..name = json['name'] as String
  ..consumable = json['consumable'] as bool?;

Map<String, dynamic> _$EquipmentToJson(Equipment instance) => <String, dynamic>{
      'name': instance.name,
      'consumable': instance.consumable,
    };

Armory _$ArmoryFromJson(Map<String, dynamic> json) => Armory()
  ..weapons = (json['weapons'] as List<dynamic>)
      .map((e) => Weapon.fromJson(e as Map<String, dynamic>))
      .toList()
  ..armors = (json['armors'] as List<dynamic>)
      .map((e) => Armor.fromJson(e as Map<String, dynamic>))
      .toList()
  ..equipments = (json['equipments'] as List<dynamic>)
      .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ArmoryToJson(Armory instance) => <String, dynamic>{
      'weapons': instance.weapons.map((e) => e.toJson()).toList(),
      'armors': instance.armors.map((e) => e.toJson()).toList(),
      'equipments': instance.equipments.map((e) => e.toJson()).toList(),
    };
