// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warband.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemStack _$ItemStackFromJson(Map<String, dynamic> json) => ItemStack()
  ..privateStack = (json['privateStack'] as List<dynamic>)
      .map((e) => ItemUse.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ItemStackToJson(ItemStack instance) => <String, dynamic>{
      'privateStack': instance.privateStack.map((e) => e.toJson()).toList(),
    };

WarriorModel _$WarriorModelFromJson(Map<String, dynamic> json) => WarriorModel(
      name: json['name'] as String?,
      uid: json['uid'] as int,
      type: Unit.fromJson(json['type'] as Map<String, dynamic>),
      bucket: json['bucket'] as int,
      sex: $enumDecodeNullable(_$SexEnumMap, json['sex']),
    )
      ..privateItems = (json['privateItems'] as List<dynamic>)
          .map((e) => ItemStack.fromJson(e as Map<String, dynamic>))
          .toList()
      ..appliedUpgrades = (json['appliedUpgrades'] as List<dynamic>)
          .map((e) => UnitUpgrade.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$WarriorModelToJson(WarriorModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uid': instance.uid,
      'type': instance.type.toJson(),
      'bucket': instance.bucket,
      'sex': _$SexEnumMap[instance.sex],
      'privateItems': instance.privateItems.map((e) => e.toJson()).toList(),
      'appliedUpgrades':
          instance.appliedUpgrades.map((e) => e.toJson()).toList(),
    };

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.custom: 'custom',
};

WarbandModel _$WarbandModelFromJson(Map<String, dynamic> json) => WarbandModel()
  ..name = json['name'] as String
  ..warriors = (json['warriors'] as List<dynamic>)
      .map((e) => WarriorModel.fromJson(e as Map<String, dynamic>))
      .toList()
  ..id = json['id'] as int;

Map<String, dynamic> _$WarbandModelToJson(WarbandModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'warriors': instance.warriors.map((e) => e.toJson()).toList(),
      'id': instance.id,
    };
