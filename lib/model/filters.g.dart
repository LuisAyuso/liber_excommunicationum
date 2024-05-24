// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitFilter _$UnitFilterFromJson(Map<String, dynamic> json) => UnitFilter(
      bypassValue: json['bypassValue'] as bool?,
      none: json['none'] as bool?,
      noneOf: (json['noneOf'] as List<dynamic>?)
          ?.map((e) => UnitFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      anyOf: (json['anyOf'] as List<dynamic>?)
          ?.map((e) => UnitFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      allOf: (json['allOf'] as List<dynamic>?)
          ?.map((e) => UnitFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      not: json['not'] == null
          ? null
          : UnitFilter.fromJson(json['not'] as Map<String, dynamic>),
      max: json['max'] as int?,
      containsUnit: json['containsUnit'] as String?,
      type: $enumDecodeNullable(_$UnitTypeEnumMap, json['type']),
      sameCountAs: json['sameCountAs'] as String?,
    );

Map<String, dynamic> _$UnitFilterToJson(UnitFilter instance) =>
    <String, dynamic>{
      'bypassValue': instance.bypassValue,
      'none': instance.none,
      'noneOf': instance.noneOf,
      'anyOf': instance.anyOf,
      'allOf': instance.allOf,
      'not': instance.not,
      'max': instance.max,
      'containsUnit': instance.containsUnit,
      'type': _$UnitTypeEnumMap[instance.type],
      'sameCountAs': instance.sameCountAs,
    };

const _$UnitTypeEnumMap = {
  UnitType.elite: 'elite',
  UnitType.trooper: 'trooper',
};

ItemFilter _$ItemFilterFromJson(Map<String, dynamic> json) => ItemFilter(
      bypassValue: json['bypassValue'] as bool?,
      none: json['none'] as bool?,
      noneOf: (json['noneOf'] as List<dynamic>?)
          ?.map((e) => ItemFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      anyOf: (json['anyOf'] as List<dynamic>?)
          ?.map((e) => ItemFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      allOf: (json['allOf'] as List<dynamic>?)
          ?.map((e) => ItemFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      not: json['not'] == null
          ? null
          : ItemFilter.fromJson(json['not'] as Map<String, dynamic>),
      unitKeyword: json['unitKeyword'] as String?,
      unitName: json['unitName'] as String?,
      containsItem: json['containsItem'] as String?,
      itemKind: $enumDecodeNullable(_$ItemKindEnumMap, json['itemKind']),
      itemName: json['itemName'] as String?,
      rangedWeapon: json['rangedWeapon'] as bool?,
      meleeWeapon: json['meleeWeapon'] as bool?,
      isGrenade: json['isGrenade'] as bool?,
      isBodyArmour: json['isBodyArmour'] as bool?,
      isShield: json['isShield'] as bool?,
    )
      ..maxRepetitions = json['maxRepetitions'] as int?
      ..itemKeyword = json['itemKeyword'] as String?;

Map<String, dynamic> _$ItemFilterToJson(ItemFilter instance) =>
    <String, dynamic>{
      'bypassValue': instance.bypassValue,
      'none': instance.none,
      'noneOf': instance.noneOf,
      'anyOf': instance.anyOf,
      'allOf': instance.allOf,
      'not': instance.not,
      'unitKeyword': instance.unitKeyword,
      'unitName': instance.unitName,
      'containsItem': instance.containsItem,
      'maxRepetitions': instance.maxRepetitions,
      'itemKind': _$ItemKindEnumMap[instance.itemKind],
      'itemName': instance.itemName,
      'itemKeyword': instance.itemKeyword,
      'rangedWeapon': instance.rangedWeapon,
      'meleeWeapon': instance.meleeWeapon,
      'isGrenade': instance.isGrenade,
      'isBodyArmour': instance.isBodyArmour,
      'isShield': instance.isShield,
    };

const _$ItemKindEnumMap = {
  ItemKind.weapon: 'weapon',
  ItemKind.armour: 'armour',
  ItemKind.equipment: 'equipment',
};
