// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Filter _$FilterFromJson(Map<String, dynamic> json) => Filter(
      whitelist: (json['whitelist'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      blacklist: (json['blacklist'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      none: json['none'] as bool?,
    );

Map<String, dynamic> _$FilterToJson(Filter instance) => <String, dynamic>{
      'none': instance.none,
      'whitelist': instance.whitelist,
      'blacklist': instance.blacklist,
    };

Currency _$CurrencyFromJson(Map<String, dynamic> json) => Currency(
      ducats: json['ducats'] as int?,
      glory: json['glory'] as int?,
    );

Map<String, dynamic> _$CurrencyToJson(Currency instance) => <String, dynamic>{
      'glory': instance.glory,
      'ducats': instance.ducats,
    };

ItemReplacement _$ItemReplacementFromJson(Map<String, dynamic> json) =>
    ItemReplacement(
      policy: $enumDecodeNullable(_$ReplacementPolicyEnumMap, json['policy']) ??
          ReplacementPolicy.any,
      values:
          (json['values'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ItemReplacementToJson(ItemReplacement instance) =>
    <String, dynamic>{
      'policy': _$ReplacementPolicyEnumMap[instance.policy]!,
      'values': instance.values,
    };

const _$ReplacementPolicyEnumMap = {
  ReplacementPolicy.any: 'any',
  ReplacementPolicy.anyExcept: 'anyExcept',
  ReplacementPolicy.anyFrom: 'anyFrom',
};

DefaultItem _$DefaultItemFromJson(Map<String, dynamic> json) => DefaultItem(
      itemName: json['itemName'] as String? ?? "",
      cost: json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
      replacements: json['replacements'] == null
          ? null
          : ItemReplacement.fromJson(
              json['replacements'] as Map<String, dynamic>),
      removable: json['removable'] as bool?,
    );

Map<String, dynamic> _$DefaultItemToJson(DefaultItem instance) =>
    <String, dynamic>{
      'itemName': instance.itemName,
      'cost': instance.cost,
      'replacements': instance.replacements,
      'removable': instance.removable,
    };

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit()
  ..typeName = json['typeName'] as String
  ..max = json['max'] as int?
  ..min = json['min'] as int?
  ..movement = json['movement'] as int
  ..ranged = json['ranged'] as int
  ..melee = json['melee'] as int
  ..armour = json['armour'] as int
  ..abilities =
      (json['abilities'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..keywords =
      (json['keywords'] as List<dynamic>).map((e) => e as String).toList()
  ..defaultItems = (json['defaultItems'] as List<dynamic>?)
      ?.map((e) => DefaultItem.fromJson(e as Map<String, dynamic>))
      .toList()
  ..cost = Currency.fromJson(json['cost'] as Map<String, dynamic>)
  ..base = json['base'] as String
  ..hands = json['hands'] as int?
  ..rangedWeaponFilter = json['rangedWeaponFilter'] == null
      ? null
      : Filter.fromJson(json['rangedWeaponFilter'] as Map<String, dynamic>)
  ..meleeWeaponFilter = json['meleeWeaponFilter'] == null
      ? null
      : Filter.fromJson(json['meleeWeaponFilter'] as Map<String, dynamic>)
  ..armourFilter = json['armourFilter'] == null
      ? null
      : Filter.fromJson(json['armourFilter'] as Map<String, dynamic>)
  ..equipmentFilter = json['equipmentFilter'] == null
      ? null
      : Filter.fromJson(json['equipmentFilter'] as Map<String, dynamic>);

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'max': instance.max,
      'min': instance.min,
      'movement': instance.movement,
      'ranged': instance.ranged,
      'melee': instance.melee,
      'armour': instance.armour,
      'abilities': instance.abilities,
      'keywords': instance.keywords,
      'defaultItems': instance.defaultItems,
      'cost': instance.cost,
      'base': instance.base,
      'hands': instance.hands,
      'rangedWeaponFilter': instance.rangedWeaponFilter,
      'meleeWeaponFilter': instance.meleeWeaponFilter,
      'armourFilter': instance.armourFilter,
      'equipmentFilter': instance.equipmentFilter,
    };

WeaponUse _$WeaponUseFromJson(Map<String, dynamic> json) => WeaponUse(
      typeName: json['typeName'] as String?,
      removable: json['removable'] as bool?,
      cost: json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
    )
      ..unitNameFilter = json['unitNameFilter'] == null
          ? null
          : Filter.fromJson(json['unitNameFilter'] as Map<String, dynamic>)
      ..keywordFilter = json['keywordFilter'] == null
          ? null
          : Filter.fromJson(json['keywordFilter'] as Map<String, dynamic>)
      ..limit = json['limit'] as int?;

Map<String, dynamic> _$WeaponUseToJson(WeaponUse instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'cost': instance.cost.toJson(),
      'removable': instance.removable,
      'unitNameFilter': instance.unitNameFilter?.toJson(),
      'keywordFilter': instance.keywordFilter?.toJson(),
      'limit': instance.limit,
    };

ArmorUse _$ArmorUseFromJson(Map<String, dynamic> json) => ArmorUse(
      typeName: json['typeName'] as String?,
      removable: json['removable'] as bool?,
      cost: json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
    )
      ..limit = json['limit'] as int?
      ..unitNameFilter = json['unitNameFilter'] == null
          ? null
          : Filter.fromJson(json['unitNameFilter'] as Map<String, dynamic>)
      ..keywordFilter = json['keywordFilter'] == null
          ? null
          : Filter.fromJson(json['keywordFilter'] as Map<String, dynamic>);

Map<String, dynamic> _$ArmorUseToJson(ArmorUse instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'cost': instance.cost.toJson(),
      'removable': instance.removable,
      'limit': instance.limit,
      'unitNameFilter': instance.unitNameFilter?.toJson(),
      'keywordFilter': instance.keywordFilter?.toJson(),
    };

EquipmentUse _$EquipmentUseFromJson(Map<String, dynamic> json) => EquipmentUse(
      typeName: json['typeName'] as String?,
      removable: json['removable'] as bool?,
      cost: json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
    )
      ..limit = json['limit'] as int?
      ..unitNameFilter = json['unitNameFilter'] == null
          ? null
          : Filter.fromJson(json['unitNameFilter'] as Map<String, dynamic>)
      ..keywordFilter = json['keywordFilter'] == null
          ? null
          : Filter.fromJson(json['keywordFilter'] as Map<String, dynamic>);

Map<String, dynamic> _$EquipmentUseToJson(EquipmentUse instance) =>
    <String, dynamic>{
      'typeName': instance.typeName,
      'cost': instance.cost.toJson(),
      'removable': instance.removable,
      'limit': instance.limit,
      'unitNameFilter': instance.unitNameFilter?.toJson(),
      'keywordFilter': instance.keywordFilter?.toJson(),
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
  ..armour = (json['armour'] as List<dynamic>)
      .map((e) => ArmorUse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..equipment = (json['equipment'] as List<dynamic>)
      .map((e) => EquipmentUse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..uniqueWeapons = (json['uniqueWeapons'] as List<dynamic>?)
      ?.map((e) => Weapon.fromJson(e as Map<String, dynamic>))
      .toList()
  ..uniqueArmour = (json['uniqueArmour'] as List<dynamic>?)
      ?.map((e) => Armour.fromJson(e as Map<String, dynamic>))
      .toList()
  ..uniqueEquipment = (json['uniqueEquipment'] as List<dynamic>?)
      ?.map((e) => Equipment.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$RosterToJson(Roster instance) => <String, dynamic>{
      'namesM': instance.namesM,
      'namesF': instance.namesF,
      'surnames': instance.surnames,
      'units': instance.units.map((e) => e.toJson()).toList(),
      'weapons': instance.weapons.map((e) => e.toJson()).toList(),
      'armour': instance.armour.map((e) => e.toJson()).toList(),
      'equipment': instance.equipment.map((e) => e.toJson()).toList(),
      'uniqueWeapons': instance.uniqueWeapons?.map((e) => e.toJson()).toList(),
      'uniqueArmour': instance.uniqueArmour?.map((e) => e.toJson()).toList(),
      'uniqueEquipment':
          instance.uniqueEquipment?.map((e) => e.toJson()).toList(),
    };

Modifier _$ModifierFromJson(Map<String, dynamic> json) => Modifier(
      hit: json['hit'] as int?,
      injury: json['injury'] as int?,
      type: $enumDecodeNullable(_$ModifierTypeEnumMap, json['type']),
      attacks: json['attacks'] as int?,
      extra: json['extra'] as String?,
    )..bonusType = $enumDecodeNullable(_$BonusTypeEnumMap, json['bonusType']);

Map<String, dynamic> _$ModifierToJson(Modifier instance) => <String, dynamic>{
      'hit': instance.hit,
      'injury': instance.injury,
      'attacks': instance.attacks,
      'extra': instance.extra,
      'type': _$ModifierTypeEnumMap[instance.type],
      'bonusType': _$BonusTypeEnumMap[instance.bonusType],
    };

const _$ModifierTypeEnumMap = {
  ModifierType.melee: 'melee',
  ModifierType.ranged: 'ranged',
  ModifierType.any: 'any',
};

const _$BonusTypeEnumMap = {
  BonusType.dice: 'dice',
  BonusType.value: 'value',
};

Weapon _$WeaponFromJson(Map<String, dynamic> json) => Weapon()
  ..typeName = json['typeName'] as String
  ..hands = json['hands'] as int
  ..range = json['range'] as int?
  ..melee = json['melee'] as bool?
  ..keywords =
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..modifiers = (json['modifiers'] as List<dynamic>?)
      ?.map((e) => Modifier.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$WeaponToJson(Weapon instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'hands': instance.hands,
      'range': instance.range,
      'melee': instance.melee,
      'keywords': instance.keywords,
      'modifiers': instance.modifiers?.map((e) => e.toJson()).toList(),
    };

Armour _$ArmourFromJson(Map<String, dynamic> json) => Armour()
  ..typeName = json['typeName'] as String
  ..value = json['value'] as int?
  ..special =
      (json['special'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..keywords =
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$ArmourToJson(Armour instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'value': instance.value,
      'special': instance.special,
      'keywords': instance.keywords,
    };

Equipment _$EquipmentFromJson(Map<String, dynamic> json) => Equipment()
  ..typeName = json['typeName'] as String
  ..consumable = json['consumable'] as bool?
  ..keywords =
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$EquipmentToJson(Equipment instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'consumable': instance.consumable,
      'keywords': instance.keywords,
    };

Armory _$ArmoryFromJson(Map<String, dynamic> json) => Armory()
  ..weapons = (json['weapons'] as List<dynamic>)
      .map((e) => Weapon.fromJson(e as Map<String, dynamic>))
      .toList()
  ..armours = (json['armours'] as List<dynamic>)
      .map((e) => Armour.fromJson(e as Map<String, dynamic>))
      .toList()
  ..equipments = (json['equipments'] as List<dynamic>)
      .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ArmoryToJson(Armory instance) => <String, dynamic>{
      'weapons': instance.weapons.map((e) => e.toJson()).toList(),
      'armours': instance.armours.map((e) => e.toJson()).toList(),
      'equipments': instance.equipments.map((e) => e.toJson()).toList(),
    };
