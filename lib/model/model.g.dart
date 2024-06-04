// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      filter: json['filter'] == null
          ? null
          : ItemFilter.fromJson(json['filter'] as Map<String, dynamic>),
    )..offsetCost = json['offsetCost'] == null
        ? null
        : Currency.fromJson(json['offsetCost'] as Map<String, dynamic>);

Map<String, dynamic> _$ItemReplacementToJson(ItemReplacement instance) =>
    <String, dynamic>{
      'filter': instance.filter,
      'offsetCost': instance.offsetCost,
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

KeywordUpgrade _$KeywordUpgradeFromJson(Map<String, dynamic> json) =>
    KeywordUpgrade(
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      cost: json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
      max: json['max'] as int?,
    );

Map<String, dynamic> _$KeywordUpgradeToJson(KeywordUpgrade instance) =>
    <String, dynamic>{
      'cost': instance.cost?.toJson(),
      'keywords': instance.keywords,
      'max': instance.max,
    };

AbilityUpgrade _$AbilityUpgradeFromJson(Map<String, dynamic> json) =>
    AbilityUpgrade(
      ability: json['ability'] as String? ?? "",
      cost: json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
      max: json['max'] as int?,
    );

Map<String, dynamic> _$AbilityUpgradeToJson(AbilityUpgrade instance) =>
    <String, dynamic>{
      'cost': instance.cost?.toJson(),
      'ability': instance.ability,
      'max': instance.max,
    };

UnitUpgrade _$UnitUpgradeFromJson(Map<String, dynamic> json) => UnitUpgrade(
      keyword: json['keyword'] == null
          ? null
          : KeywordUpgrade.fromJson(json['keyword'] as Map<String, dynamic>),
      unit: json['unit'] as String?,
    )..ability = json['ability'] == null
        ? null
        : AbilityUpgrade.fromJson(json['ability'] as Map<String, dynamic>);

Map<String, dynamic> _$UnitUpgradeToJson(UnitUpgrade instance) =>
    <String, dynamic>{
      'keyword': instance.keyword?.toJson(),
      'ability': instance.ability?.toJson(),
      'unit': instance.unit,
    };

UnitVariant _$UnitVariantFromJson(Map<String, dynamic> json) => UnitVariant()
  ..typeName = json['typeName'] as String?
  ..filter = json['filter'] == null
      ? null
      : UnitFilter.fromJson(json['filter'] as Map<String, dynamic>)
  ..max = json['max'] as int?
  ..min = json['min'] as int?
  ..ranged = json['ranged'] as int?
  ..melee = json['melee'] as int?
  ..upgrades = (json['upgrades'] as List<dynamic>?)
      ?.map((e) => UnitUpgrade.fromJson(e as Map<String, dynamic>))
      .toList()
  ..keywords =
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..defaultItems = (json['defaultItems'] as List<dynamic>?)
      ?.map((e) => DefaultItem.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$UnitVariantToJson(UnitVariant instance) =>
    <String, dynamic>{
      'typeName': instance.typeName,
      'filter': instance.filter?.toJson(),
      'max': instance.max,
      'min': instance.min,
      'ranged': instance.ranged,
      'melee': instance.melee,
      'upgrades': instance.upgrades?.map((e) => e.toJson()).toList(),
      'keywords': instance.keywords,
      'defaultItems': instance.defaultItems?.map((e) => e.toJson()).toList(),
    };

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      typeName: json['typeName'] as String? ?? "",
      cost: json['cost'] == null
          ? const Currency(ducats: 0)
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
    )
      ..max = json['max'] as int?
      ..min = json['min'] as int?
      ..movement = json['movement'] as String
      ..ranged = json['ranged'] as int
      ..melee = json['melee'] as int
      ..armour = json['armour'] as int
      ..abilities = (json['abilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..keywords =
          (json['keywords'] as List<dynamic>).map((e) => e as String).toList()
      ..defaultItems = (json['defaultItems'] as List<dynamic>?)
          ?.map((e) => DefaultItem.fromJson(e as Map<String, dynamic>))
          .toList()
      ..base = json['base'] as String
      ..hands = json['hands'] as int?
      ..unarmedPenalty = json['unarmedPenalty'] as bool?
      ..defaultSex = $enumDecodeNullable(_$SexEnumMap, json['defaultSex'])
      ..upgrades = (json['upgrades'] as List<dynamic>?)
          ?.map((e) => UnitUpgrade.fromJson(e as Map<String, dynamic>))
          .toList()
      ..unitFilter = json['unitFilter'] == null
          ? null
          : UnitFilter.fromJson(json['unitFilter'] as Map<String, dynamic>)
      ..itemFilter = json['itemFilter'] == null
          ? null
          : ItemFilter.fromJson(json['itemFilter'] as Map<String, dynamic>)
      ..backpack = json['backpack'] as bool?;

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
      'defaultItems': instance.defaultItems?.map((e) => e.toJson()).toList(),
      'cost': instance.cost.toJson(),
      'base': instance.base,
      'hands': instance.hands,
      'unarmedPenalty': instance.unarmedPenalty,
      'defaultSex': _$SexEnumMap[instance.defaultSex],
      'upgrades': instance.upgrades?.map((e) => e.toJson()).toList(),
      'unitFilter': instance.unitFilter?.toJson(),
      'itemFilter': instance.itemFilter?.toJson(),
      'backpack': instance.backpack,
    };

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.custom: 'custom',
};

ItemVariant _$ItemVariantFromJson(Map<String, dynamic> json) => ItemVariant(
      typeName: json['typeName'] as String? ?? "",
    )
      ..cost = json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>)
      ..filter = json['filter'] == null
          ? null
          : ItemFilter.fromJson(json['filter'] as Map<String, dynamic>)
      ..limit = json['limit'] as int?;

Map<String, dynamic> _$ItemVariantToJson(ItemVariant instance) =>
    <String, dynamic>{
      'typeName': instance.typeName,
      'cost': instance.cost,
      'filter': instance.filter,
      'limit': instance.limit,
    };

ItemUse _$ItemUseFromJson(Map<String, dynamic> json) => ItemUse(
      typeName: json['typeName'] as String?,
      cost: json['cost'] == null
          ? null
          : Currency.fromJson(json['cost'] as Map<String, dynamic>),
      removable: json['removable'] as bool?,
      limit: json['limit'] as int?,
      filter: json['filter'] == null
          ? null
          : ItemFilter.fromJson(json['filter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ItemUseToJson(ItemUse instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'cost': instance.cost.toJson(),
      'removable': instance.removable,
      'limit': instance.limit,
      'filter': instance.filter?.toJson(),
    };

RosterVariant _$RosterVariantFromJson(Map<String, dynamic> json) =>
    RosterVariant(
      name: json['name'] as String? ?? "",
    )
      ..unitVariants = (json['unitVariants'] as List<dynamic>?)
          ?.map((e) => UnitVariant.fromJson(e as Map<String, dynamic>))
          .toList()
      ..itemVariants = (json['itemVariants'] as List<dynamic>?)
          ?.map((e) => ItemVariant.fromJson(e as Map<String, dynamic>))
          .toList()
      ..weapons = (json['weapons'] as List<dynamic>?)
          ?.map((e) => ItemUse.fromJson(e as Map<String, dynamic>))
          .toList()
      ..armour = (json['armour'] as List<dynamic>?)
          ?.map((e) => ItemUse.fromJson(e as Map<String, dynamic>))
          .toList()
      ..equipment = (json['equipment'] as List<dynamic>?)
          ?.map((e) => ItemUse.fromJson(e as Map<String, dynamic>))
          .toList()
      ..uniqueWeapons = (json['uniqueWeapons'] as List<dynamic>?)
          ?.map((e) => Weapon.fromJson(e as Map<String, dynamic>))
          .toList()
      ..uniqueArmour = (json['uniqueArmour'] as List<dynamic>?)
          ?.map((e) => Armour.fromJson(e as Map<String, dynamic>))
          .toList()
      ..uniqueEquipment = (json['uniqueEquipment'] as List<dynamic>?)
          ?.map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList()
      ..uniqueUnits = (json['uniqueUnits'] as List<dynamic>?)
          ?.map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$RosterVariantToJson(RosterVariant instance) =>
    <String, dynamic>{
      'name': instance.name,
      'unitVariants': instance.unitVariants?.map((e) => e.toJson()).toList(),
      'itemVariants': instance.itemVariants?.map((e) => e.toJson()).toList(),
      'weapons': instance.weapons?.map((e) => e.toJson()).toList(),
      'armour': instance.armour?.map((e) => e.toJson()).toList(),
      'equipment': instance.equipment?.map((e) => e.toJson()).toList(),
      'uniqueWeapons': instance.uniqueWeapons?.map((e) => e.toJson()).toList(),
      'uniqueArmour': instance.uniqueArmour?.map((e) => e.toJson()).toList(),
      'uniqueEquipment':
          instance.uniqueEquipment?.map((e) => e.toJson()).toList(),
      'uniqueUnits': instance.uniqueUnits?.map((e) => e.toJson()).toList(),
    };

Roster _$RosterFromJson(Map<String, dynamic> json) => Roster()
  ..version = json['version'] as String
  ..name = json['name'] as String
  ..elites = json['elites'] as String
  ..troop = json['troop'] as String
  ..units = (json['units'] as List<dynamic>)
      .map((e) => Unit.fromJson(e as Map<String, dynamic>))
      .toList()
  ..weapons = (json['weapons'] as List<dynamic>)
      .map((e) => ItemUse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..armour = (json['armour'] as List<dynamic>)
      .map((e) => ItemUse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..equipment = (json['equipment'] as List<dynamic>)
      .map((e) => ItemUse.fromJson(e as Map<String, dynamic>))
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
      'version': instance.version,
      'name': instance.name,
      'elites': instance.elites,
      'troop': instance.troop,
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

Weapon _$WeaponFromJson(Map<String, dynamic> json) => Weapon(
      typeName: json['typeName'] as String?,
      hands: json['hands'] as int?,
      range: json['range'] as int?,
      melee: json['melee'] as bool?,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      modifiers: (json['modifiers'] as List<dynamic>?)
          ?.map((e) => Modifier.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..filter = json['filter'] == null
        ? null
        : ItemFilter.fromJson(json['filter'] as Map<String, dynamic>);

Map<String, dynamic> _$WeaponToJson(Weapon instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'hands': instance.hands,
      'range': instance.range,
      'melee': instance.melee,
      'keywords': instance.keywords,
      'modifiers': instance.modifiers?.map((e) => e.toJson()).toList(),
      'filter': instance.filter?.toJson(),
    };

Armour _$ArmourFromJson(Map<String, dynamic> json) => Armour(
      value: json['value'] as int?,
      special:
          (json['special'] as List<dynamic>?)?.map((e) => e as String).toList(),
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      type: $enumDecodeNullable(_$ArmourTypeEnumMap, json['type']),
    )
      ..typeName = json['typeName'] as String
      ..filter = json['filter'] == null
          ? null
          : ItemFilter.fromJson(json['filter'] as Map<String, dynamic>);

Map<String, dynamic> _$ArmourToJson(Armour instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'value': instance.value,
      'type': _$ArmourTypeEnumMap[instance.type]!,
      'special': instance.special,
      'keywords': instance.keywords,
      'filter': instance.filter?.toJson(),
    };

const _$ArmourTypeEnumMap = {
  ArmourType.bodyArmour: 'bodyArmour',
  ArmourType.shield: 'shield',
  ArmourType.other: 'other',
};

Equipment _$EquipmentFromJson(Map<String, dynamic> json) => Equipment()
  ..typeName = json['typeName'] as String
  ..consumable = json['consumable'] as bool?
  ..keywords =
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..filter = json['filter'] == null
      ? null
      : ItemFilter.fromJson(json['filter'] as Map<String, dynamic>);

Map<String, dynamic> _$EquipmentToJson(Equipment instance) => <String, dynamic>{
      'typeName': instance.typeName,
      'consumable': instance.consumable,
      'keywords': instance.keywords,
      'filter': instance.filter?.toJson(),
    };

Armory _$ArmoryFromJson(Map<String, dynamic> json) => Armory()
  ..version = json['version'] as String
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
      'version': instance.version,
      'weapons': instance.weapons.map((e) => e.toJson()).toList(),
      'armours': instance.armours.map((e) => e.toJson()).toList(),
      'equipments': instance.equipments.map((e) => e.toJson()).toList(),
    };
