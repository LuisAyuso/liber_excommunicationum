// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warband.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemStack _$ItemStackFromJson(Map<String, dynamic> json) => ItemStack();

Map<String, dynamic> _$ItemStackToJson(ItemStack instance) =>
    <String, dynamic>{};

WarriorModel _$WarriorModelFromJson(Map<String, dynamic> json) => WarriorModel(
      name: json['name'] as String?,
      uid: json['uid'] as int,
      type: Unit.fromJson(json['type'] as Map<String, dynamic>),
      bucket: json['bucket'] as int,
      sex: $enumDecodeNullable(_$SexEnumMap, json['sex']),
    );

Map<String, dynamic> _$WarriorModelToJson(WarriorModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uid': instance.uid,
      'type': instance.type.toJson(),
      'bucket': instance.bucket,
      'sex': _$SexEnumMap[instance.sex],
    };

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.custom: 'custom',
};

WarbandModel _$WarbandModelFromJson(Map<String, dynamic> json) => WarbandModel()
  ..name = json['name'] as String
  ..items = (json['items'] as List<dynamic>)
      .map((e) => WarriorModel.fromJson(e as Map<String, dynamic>))
      .toList()
  ..id = json['id'] as int;

Map<String, dynamic> _$WarbandModelToJson(WarbandModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'id': instance.id,
    };
