import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tc_thing/model/filters.dart';
import 'package:tc_thing/model/warband.dart';
import 'package:tc_thing/utils/utils.dart';

part 'model.g.dart';

@JsonSerializable()
class Currency {
  const Currency({int? ducats, int? glory})
      : _ducats = ducats,
        _glory = glory;

  final int? _ducats;
  final int? _glory;

  bool get isGlory => _glory != null;
  bool get isDucats => _ducats != null;
  int get glory => _glory ?? 0;
  int get ducats => _ducats ?? 0;

  factory Currency.free() => const Currency(ducats: 0);
  factory Currency.ducats(int v) => Currency(ducats: v);
  factory Currency.glory(int v) => Currency(glory: v);

  // the rule says, replacement weapons pay for the difference
  // unless cost is less, in that case the difference is lost
  Currency offset(Currency other) {
    if (isDucats != other.isDucats) return other;
    final v = other - this;
    if (v.ducats < 0 && v.glory == 0) return this;
    if (v.glory < 0 && v.ducats == 0) return this;
    return v;
  }

  Currency operator -(Currency other) {
    return Currency(ducats: ducats - other.ducats, glory: glory - other.glory);
  }

  Currency operator +(Currency other) {
    return Currency(ducats: ducats + other.ducats, glory: glory + other.glory);
  }

  @override
  String toString() {
    return isDucats ? "$_ducats Ducats" : "$_glory Glory";
  }

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyToJson(this);
}

@JsonSerializable()
class ItemReplacement {
  ItemReplacement({ItemFilter? filter}) : filter = filter ?? ItemFilter();

  ItemFilter filter;
  Currency? offsetCost;

  bool isAllowed(Item item) {
    return filter.isItemAllowed(item);
  }

  factory ItemReplacement.fromJson(Map<String, dynamic> json) =>
      _$ItemReplacementFromJson(json);
  Map<String, dynamic> toJson() => _$ItemReplacementToJson(this);
}

@JsonSerializable()
class DefaultItem {
  DefaultItem({
    this.itemName = "",
    this.cost,
    this.replacements,
    this.removable,
  });

  String itemName;
  Currency? cost;
  ItemReplacement? replacements;
  bool? removable;

  Currency get getCost => cost ?? Currency.free();
  bool get isRemovable => removable ?? true;

  factory DefaultItem.fromJson(Map<String, dynamic> json) =>
      _$DefaultItemFromJson(json);
  Map<String, dynamic> toJson() => _$DefaultItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class KeywordUpgrade {
  KeywordUpgrade({this.keyword = "", this.cost, this.max});

  Currency? cost;
  String keyword;
  int? max;

  @override
  String toString() {
    final res = "Add $keyword";
    if (cost != null) return "$res for $cost";
    return res;
  }

  factory KeywordUpgrade.fromJson(Map<String, dynamic> json) =>
      _$KeywordUpgradeFromJson(json);
  Map<String, dynamic> toJson() => _$KeywordUpgradeToJson(this);

  bool isAllowed(WarriorModel me, List<WarriorModel> warriors) {
    if (me.effectiveKeywords.contains(keyword)) return false;
    final uses = warriors
        .map((w) => w.appliedUpgrades
            .map((up) => up.keyword)
            .nonNulls
            .map((kup) => kup.keyword))
        .where((ups) => ups.contains(keyword))
        .length;
    return uses < (max ?? double.infinity);
  }
}

@JsonSerializable(explicitToJson: true)
class AbilityUpgrade {
  AbilityUpgrade({this.ability = "", this.cost, this.max});

  Currency? cost;
  String ability;
  int? max;

  @override
  String toString() {
    final res = "Add $ability";
    if (cost != null) return "$res for $cost";
    return res;
  }

  factory AbilityUpgrade.fromJson(Map<String, dynamic> json) =>
      _$AbilityUpgradeFromJson(json);
  Map<String, dynamic> toJson() => _$AbilityUpgradeToJson(this);

  bool isAllowed(WarriorModel me, List<WarriorModel> warriors) {
    return true;
  }
}

@JsonSerializable(explicitToJson: true)
class UnitUpgrade {
  UnitUpgrade({this.keyword, this.unit});

  KeywordUpgrade? keyword;
  AbilityUpgrade? ability;
  String? unit;

  Currency get cost =>
      (keyword?.cost ?? Currency.free()) + (ability?.cost ?? Currency.free());

  @override
  String toString() {
    if (keyword != null) return keyword.toString();
    if (ability != null) return ability.toString();
    if (unit != null) return unit.toString();
    return "ill-formed upgrade";
  }

  bool isAllowed(WarriorModel me, List<WarriorModel> warriors, Roster roster) {
    if (keyword != null) return keyword!.isAllowed(me, warriors);
    if (ability != null) return ability!.isAllowed(me, warriors);
    assert(unit != null);
    final def = roster.units.firstWhere((u) => u.typeName == unit!);
    final withoutMe = List<WarriorModel>.from(warriors);
    withoutMe.remove(me);
    return def.effectiveUnitFilter.isUnitAllowed(def, withoutMe);
  }

  factory UnitUpgrade.fromJson(Map<String, dynamic> json) =>
      _$UnitUpgradeFromJson(json);
  Map<String, dynamic> toJson() => _$UnitUpgradeToJson(this);
}

enum Sex { male, female, custom }

@JsonSerializable(explicitToJson: true)
class UnitVariant {
  UnitVariant();

  String? typeName;
  UnitFilter? filter = UnitFilter.trueValue();

  int? max;
  int? min;
  List<UnitUpgrade>? upgrades;
  List<String>? keywords;
  List<DefaultItem>? defaultItems;

  Unit apply(Unit old) {
    if (old.typeName != (typeName ?? "--")) return old;
    if (!(filter?.isUnitAllowed(old, []) ?? true)) return old;
    var u = old.clone();
    u.max = max ?? u.max;
    u.min = min ?? u.min;
    u.upgrades = [
      ...u.upgrades ?? [],
      ...upgrades ?? [],
    ];
    u.keywords = [
      ...u.keywords,
      ...keywords ?? [],
    ];
    u.defaultItems = defaultItems ?? u.defaultItems;
    return u;
  }

  factory UnitVariant.fromJson(Map<String, dynamic> json) =>
      _$UnitVariantFromJson(json);
  Map<String, dynamic> toJson() => _$UnitVariantToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Unit {
  Unit({this.typeName = "", this.cost = const Currency(ducats: 0)});

  String typeName;
  int? max;
  int? min;
  String movement = "";
  int ranged = 0;
  int melee = 0;
  int armour = 0;
  List<String>? abilities = [];
  List<String> keywords = [];
  List<DefaultItem>? defaultItems;
  Currency cost;
  String base = "25";
  int? hands;
  bool? unarmedPenalty;
  Sex? defaultSex;
  List<UnitUpgrade>? upgrades;
  UnitFilter? unitFilter;
  ItemFilter? itemFilter;

  /// if the unit has not backpack, it needs to allocate all equipment to the hands
  bool? backpack;

  Unit clone() {
    var u = Unit();
    u.typeName = typeName;
    u.max = max;
    u.min = min;
    u.movement = movement;
    u.ranged = ranged;
    u.melee = melee;
    u.armour = armour;
    if (abilities != null) u.abilities = List.from(abilities!);
    u.keywords = List.from(keywords);
    if (defaultItems != null) u.defaultItems = List.from(defaultItems!);
    u.cost = cost;
    u.base = base;
    u.hands = hands;
    u.unarmedPenalty = unarmedPenalty;
    u.defaultSex = defaultSex;
    if (upgrades != null) u.upgrades = List.from(upgrades!);
    u.unitFilter = unitFilter;
    u.itemFilter = itemFilter;
    u.backpack = backpack;
    return u;
  }

  int get getHands => hands ?? 2;
  bool get hasBackpack => backpack ?? true;
  bool get suffersUnarmedPenalty => unarmedPenalty ?? true;
  bool get isElite => keywords.contains("ELITE");
  Sex get sex => defaultSex ?? Sex.male;
  Currency get completeCost =>
      cost +
      (defaultItems?.fold<Currency>(
              Currency.free(), (v, item) => v + item.getCost) ??
          Currency.free());

  UnitFilter get effectiveUnitFilter {
    return UnitFilter.allOf(
      [max != null ? UnitFilter.max(max!) : null, unitFilter].nonNulls,
    );
  }

  ItemFilter get effectiveItemFilter => itemFilter ?? ItemFilter.trueValue();

  @override
  String toString() {
    return typeName;
  }

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

@JsonSerializable()
class ItemVariant {
  ItemVariant({this.typeName = ""});

  String typeName;
  Currency? cost;
  ItemFilter? filter;
  int? limit;

  ItemUse apply(ItemUse old) {
    if (old.getName != typeName) return old;

    var i = old.clone();
    i.cost = cost ?? i.cost;
    i.filter = filter ?? i.filter;
    i.limit = limit ?? i.limit;

    return i;
  }

  factory ItemVariant.fromJson(Map<String, dynamic> json) =>
      _$ItemVariantFromJson(json);
  Map<String, dynamic> toJson() => _$ItemVariantToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ItemUse {
  ItemUse({
    String? typeName,
    Currency? cost,
    this.removable,
    this.limit,
    this.filter,
  })  : typeName = typeName ?? "",
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = Currency.free();
  bool? removable;
  int? limit;
  ItemFilter? filter;

  String get getName => typeName;
  ItemFilter get getFilter => filter ?? ItemFilter.trueValue();
  bool get isRemovable => removable ?? true;
  int get getLimit => limit ?? double.maxFinite.toInt();
  Currency get getCost => cost;
  UnmodifiableListView<String> get addedKeywords => UnmodifiableListView([]);

  factory ItemUse.fromJson(Map<String, dynamic> json) =>
      _$ItemUseFromJson(json);
  Map<String, dynamic> toJson() => _$ItemUseToJson(this);

  ItemUse clone() {
    return ItemUse(
        typeName: typeName,
        cost: cost,
        removable: removable,
        limit: limit,
        filter: filter);
  }
}

@JsonSerializable(explicitToJson: true)
class RosterVariant {
  RosterVariant({this.name = ""});

  String name;
  List<UnitVariant>? unitVariants;
  List<ItemVariant>? itemVariants;

  List<ItemUse>? weapons;
  List<ItemUse>? armour;
  List<ItemUse>? equipment;

  List<Weapon>? uniqueWeapons;
  List<Armour>? uniqueArmour;
  List<Equipment>? uniqueEquipment;

  List<Unit>? uniqueUnits;

  factory RosterVariant.fromJson(Map<String, dynamic> json) =>
      _$RosterVariantFromJson(json);
  Map<String, dynamic> toJson() => _$RosterVariantToJson(this);

  Roster apply(Roster oldRoster) {
    var newRoster = oldRoster.clone();
    newRoster.name = name;

    for (UnitVariant variant in unitVariants ?? []) {
      newRoster.units = newRoster.units.map((u) => variant.apply(u)).toList();
    }
    newRoster.units.removeWhere((u) => (u.max ?? 1) <= 0);

    for (ItemVariant variant in itemVariants ?? []) {
      newRoster.weapons =
          newRoster.weapons.map((item) => variant.apply(item)).toList();
      newRoster.armour =
          newRoster.armour.map((item) => variant.apply(item)).toList();
      newRoster.equipment =
          newRoster.equipment.map((item) => variant.apply(item)).toList();
    }

    newRoster.weapons = [...newRoster.weapons, ...?weapons];
    newRoster.armour = [...newRoster.armour, ...?armour];
    newRoster.equipment = [...newRoster.equipment, ...?equipment];

    newRoster.uniqueWeapons = [...?newRoster.uniqueWeapons, ...?uniqueWeapons];
    newRoster.uniqueArmour = [...?newRoster.uniqueArmour, ...?uniqueArmour];
    newRoster.uniqueEquipment = [
      ...?newRoster.uniqueEquipment,
      ...?uniqueEquipment
    ];

    newRoster.units = [...newRoster.units, ...?uniqueUnits];

    return newRoster;
  }
}

@JsonSerializable(explicitToJson: true)
class Roster {
  Roster();

  String version = "Unversioned";
  String name = "";
  String elites = "";
  String troop = "";

  List<Unit> units = [];
  List<ItemUse> weapons = [];
  List<ItemUse> armour = [];
  List<ItemUse> equipment = [];

  List<Weapon>? uniqueWeapons = [];
  List<Armour>? uniqueArmour = [];
  List<Equipment>? uniqueEquipment = [];

  List<ItemUse> get items => [...weapons, ...armour, ...equipment];

  Roster clone() {
    var v = Roster();
    v.name = name;
    v.elites = elites;
    v.troop = troop;
    v.units = List.from(units.map((u) => u.clone()));
    v.weapons = List.from(weapons);
    v.armour = List.from(armour);
    v.equipment = List.from(equipment);
    if (uniqueWeapons != null) {
      v.uniqueWeapons = List.from(uniqueWeapons!);
    }
    if (uniqueArmour != null) {
      v.uniqueArmour = List.from(uniqueArmour!);
    }
    if (uniqueEquipment != null) {
      v.uniqueEquipment = List.from(uniqueEquipment!);
    }
    return v;
  }

  Iterable<UseAndDef<Weapon>> availableWeapons(Armory armory) {
    final defs = [...armory.weapons, ...?uniqueWeapons];
    return weapons
        .map((use) =>
            UseAndDef(use, findIn(defs, (i) => i.itemName == use.typeName)))
        .where((u) => u.isValid);
  }

  Iterable<UseAndDef<Armour>> availableArmours(Armory armory) {
    final defs = [...armory.armours, ...?uniqueArmour];
    return armour
        .map((use) =>
            UseAndDef(use, findIn(defs, (i) => i.itemName == use.typeName)))
        .where((u) => u.isValid);
  }

  Iterable<UseAndDef<Equipment>> availableEquipment(Armory armory) {
    final defs = [...armory.equipments, ...?uniqueEquipment];
    return equipment
        .map((use) =>
            UseAndDef(use, findIn(defs, (i) => i.itemName == use.typeName)))
        .where((u) => u.isValid);
  }

  Iterable<UseAndDef<Item>> allAvailableItems(Armory armory) {
    final defs = [
      ...armory.weapons,
      ...?uniqueWeapons,
      ...armory.armours,
      ...?uniqueArmour,
      ...armory.equipments,
      ...?uniqueEquipment,
    ];
    return items
        .map((use) =>
            UseAndDef(use, findIn(defs, (i) => i.itemName == use.typeName)))
        .where((u) => u.isValid);
  }

  factory Roster.fromJson(Map<String, dynamic> json) => _$RosterFromJson(json);
  Map<String, dynamic> toJson() => _$RosterToJson(this);
}

abstract class Item {
  UnmodifiableListView<String> get getKeywords;
  ItemKind get kind;
  ItemFilter get getFilter;
  String get itemName;
  bool get isConsumable;
}

enum BonusType { dice, value }

String bonus(int v, {BonusType type = BonusType.dice}) {
  if (v == 0) return "";

  String suffix = "";
  switch (type) {
    case BonusType.dice:
      suffix = "D";
      break;
    case BonusType.value:
      break;
  }

  final sign = v > 0 ? "+" : "";
  return "$sign$v$suffix";
}

enum ModifierType { melee, ranged, any }

enum ModifierCategory { hit, injury, hitInjury, attacks, unknown, extraOnly }

@JsonSerializable(explicitToJson: true)
class Modifier {
  Modifier({this.hit, this.injury, this.type, this.attacks, this.extra});

  int? hit;
  int? injury;
  int? attacks;
  String? extra;
  ModifierType? type;
  BonusType? bonusType;

  bool get isEmpty =>
      hit != null && injury != null && attacks != null && extra != null;

  Modifier clone() => Modifier(
      hit: hit, injury: injury, attacks: attacks, type: type, extra: extra);

  bool get isHitModifier => (hit ?? 0) != 0;

  @override
  String toString() {
    final bt = bonusType ?? BonusType.dice;
    final suffix = extra == null ? "" : " $extra";
    if (attacks != null && attacks != 0) {
      return "$attacks Attacks$suffix";
    }
    if (hit != null && hit != 0) {
      return "${bonus(hit!, type: bt)} to Hit$suffix";
    }
    if (injury != null && injury != 0) {
      return "${bonus(injury!, type: bt)} to Injury$suffix";
    }
    return extra ?? "";
  }

  factory Modifier.fromJson(Map<String, dynamic> json) =>
      _$ModifierFromJson(json);
  Map<String, dynamic> toJson() => _$ModifierToJson(this);

  Modifier offset(Modifier base) {
    Modifier m = clone();
    if (m.hit != null && base.hit != null) {
      m.hit = m.hit! + base.hit!;
    }
    if (m.injury != null && base.injury != null) {
      m.injury = m.injury! + base.injury!;
    }
    if (m.attacks != null && base.attacks != null) {
      m.attacks = m.attacks! + base.attacks!;
    }
    return m;
  }

  bool separate(ModifierType other) {
    switch (other) {
      case ModifierType.melee:
      case ModifierType.ranged:
        {
          final x = type ?? ModifierType.any;
          return x == ModifierType.any || x == other;
        }
      case ModifierType.any:
        return true;
    }
  }

  ModifierCategory cat() {
    if (hit != null && injury == null && attacks == null) {
      return ModifierCategory.hit;
    }
    if (hit == null && injury != null && attacks == null) {
      return ModifierCategory.injury;
    }
    if (hit == null && injury == null && attacks != null) {
      return ModifierCategory.attacks;
    }
    if (extra != null) {
      return ModifierCategory.extraOnly;
    }
    return ModifierCategory.unknown;
  }
}

@JsonSerializable(explicitToJson: true)
class Weapon extends Item {
  Weapon(
      {String? typeName,
      int? hands,
      this.range,
      this.melee,
      this.keywords,
      this.modifiers})
      : typeName = typeName ?? "",
        hands = hands ?? 1;

  String typeName = "";
  int hands = 1;
  int? range;
  bool? melee;
  List<String>? keywords;
  List<Modifier>? modifiers = [];
  ItemFilter? filter;

  bool get canMelee => range == null || (melee ?? false);
  bool get canRanged => range != null;
  bool get isFirearm => canRanged && !isPistol && !isGrenade;
  bool get isMeleeWeapon => !canRanged && canMelee;
  bool get isPistol => hands == 1 && range != null;
  bool get isRifle => typeName.contains("Rifle");
  bool get isGrenade => hands == 0 && canRanged;

  @override
  ItemKind get kind => ItemKind.weapon;
  @override
  ItemFilter get getFilter => filter ?? ItemFilter.trueValue();
  @override
  String get itemName => typeName;
  @override
  bool get isConsumable => keywords?.contains("CONSUMABLE") ?? false;
  @override
  String toString() {
    return typeName;
  }

  UnmodifiableListView<Modifier> get getModifiers =>
      UnmodifiableListView(modifiers ?? []);

  String getModifiersString(Modifier baseValue, ModifierType type) {
    String res = "";
    if (!baseValue.isEmpty &&
        (modifiers ?? []).where((mod) => mod.separate(type)).where((mod) {
          return baseValue.cat() == mod.cat();
        }).isEmpty) {
      res = baseValue.toString();
    }
    return (modifiers ?? []).where((m) => m.separate(type)).fold<String>(res,
        (acc, modifier) {
      final mod = modifier.offset(baseValue).toString();
      if (acc.isEmpty) return mod;
      if (mod.isEmpty) return acc;
      return "$acc; $mod";
    });
  }

  String get getTypeString {
    if (canMelee && canRanged) return "Ranged/Melee";
    if (canMelee) return "Melee";
    return "Ranged";
  }

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  factory Weapon.fromJson(Map<String, dynamic> json) => _$WeaponFromJson(json);

  Map<String, dynamic> toJson() => _$WeaponToJson(this);

  factory Weapon.unarmed() {
    Weapon w = Weapon();
    w.typeName = "Unarmed";
    w.hands = 2;
    w.melee = true;
    w.modifiers = [Modifier(hit: -1), Modifier(injury: -1)];
    return w;
  }
}

enum ArmourType { bodyArmour, shield, other }

@JsonSerializable(explicitToJson: true)
class Armour extends Item {
  Armour(
      {String? typename,
      this.value,
      this.special,
      this.keywords,
      ArmourType? type})
      : typeName = typename ?? "",
        type = type ?? ArmourType.other;
  String typeName = "";
  int? value;
  ArmourType type;
  List<String>? special = [];
  List<String>? keywords = [];
  ItemFilter? filter;

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);
  @override
  ItemKind get kind => ItemKind.armour;
  @override
  ItemFilter get getFilter => filter ?? ItemFilter.trueValue();
  @override
  String get itemName => typeName;
  @override
  bool get isConsumable => keywords?.contains("CONSUMABLE") ?? false;
  @override
  String toString() {
    return typeName;
  }

  bool get isShield => type == ArmourType.shield;
  bool get isBodyArmour => type == ArmourType.bodyArmour;
  factory Armour.fromJson(Map<String, dynamic> json) => _$ArmourFromJson(json);
  Map<String, dynamic> toJson() => _$ArmourToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Equipment extends Item {
  Equipment();

  String typeName = "";
  bool? consumable;
  List<String>? keywords = [];
  ItemFilter? filter;

  @override
  ItemKind get kind => ItemKind.equipment;
  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);
  @override
  ItemFilter get getFilter => filter ?? ItemFilter.trueValue();
  @override
  String get itemName => typeName;
  @override
  bool get isConsumable =>
      (consumable ?? false) || (keywords?.contains("CONSUMABLE") ?? false);
  @override
  String toString() {
    return typeName;
  }

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Armory {
  Armory();

  String version = "Unversioned";
  List<Weapon> weapons = [];
  List<Armour> armours = [];
  List<Equipment> equipments = [];

  factory Armory.fromJson(Map<String, dynamic> json) => _$ArmoryFromJson(json);
  Map<String, dynamic> toJson() => _$ArmoryToJson(this);

  Weapon? findWeapon(dynamic use) {
    if (use is ItemUse) return findWeapon(use.typeName);
    assert(use is String);
    return weapons
        .where((other) => other.typeName == use as String)
        .firstOrNull;
  }

  bool isWeapon(dynamic use) {
    if (use is ItemUse) return isWeapon(use.typeName);
    return weapons.where((def) => def.typeName == use).length == 1;
  }

  Armour? findArmour(dynamic use) {
    if (use is ItemUse) return findArmour(use.typeName);
    assert(use is String);
    return armours
        .where((other) => other.typeName == use as String)
        .firstOrNull;
  }

  bool isArmour(dynamic use) {
    if (use is ItemUse) return isArmour(use.typeName);
    return armours.where((def) => def.typeName == use).length == 1;
  }

  Equipment? findEquipment(dynamic use) {
    if (use is ItemUse) return findEquipment(use.typeName);
    assert(use is String);
    return equipments
        .where((other) => other.typeName == use as String)
        .firstOrNull;
  }

  bool isEquipment(dynamic use) {
    if (use is ItemUse) return isArmour(use.typeName);
    return equipments.where((def) => def.typeName == use).length == 1;
  }

  void add(Item item) {
    if (item is Weapon) weapons.add(item);
    if (item is Armour) armours.add(item);
    if (item is Equipment) equipments.add(item);
  }

  Item? findItem(ItemUse use) {
    if (isWeapon(use)) return findWeapon(use);
    if (isArmour(use)) return findArmour(use);
    if (isEquipment(use)) return findEquipment(use);
    debugPrint("not found! ${use.typeName}");
    return null;
  }
}
