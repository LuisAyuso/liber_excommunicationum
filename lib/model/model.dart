import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tc_thing/model/warband.dart';

part 'model.g.dart';

enum ItemKind { weapon, armour, equipment }

@JsonSerializable()
class FilterItem {
  FilterItem({
    this.bypassValue,
    this.none,
    this.allOf,
    this.noneOf,
    this.anyOf,
    this.not,
    this.unitKeyword,
    this.unitName,
    this.containsItem,
    this.itemKind,
    this.itemName,
    this.rangedWeapon,
    this.meleeWeapon,
    this.isGrenade,
    this.isBodyArmour,
    this.isShield,
  });

  factory FilterItem.trueValue() => FilterItem(bypassValue: true);
  factory FilterItem.falseValue() => FilterItem(bypassValue: false);
  factory FilterItem.allOf(Iterable<FilterItem> all) =>
      FilterItem(allOf: all.toList());
  factory FilterItem.noneOf(Iterable<FilterItem> none) =>
      FilterItem(noneOf: none.toList());
  factory FilterItem.anyOf(Iterable<FilterItem> any) =>
      FilterItem(anyOf: any.toList());
  factory FilterItem.none() => FilterItem(none: true);
  factory FilterItem.not(FilterItem filter) => FilterItem(not: filter);
  factory FilterItem.grenade() => FilterItem(isGrenade: true);

  bool? bypassValue;
  bool? none;
  List<FilterItem>? noneOf;
  List<FilterItem>? anyOf;
  List<FilterItem>? allOf;
  FilterItem? not;

  String? unitKeyword;
  String? unitName;
  String? containsItem;

  ItemKind? itemKind;
  String? itemName;
  bool? rangedWeapon;
  bool? meleeWeapon;
  bool? isGrenade;
  bool? isBodyArmour;
  bool? isShield;

  int _count<T>(T? x) {
    return x == null ? 0 : 1;
  }

  bool isItemAllowed(Item item, [WarriorModel? warrior]) {
    assert(_count(bypassValue) +
            _count(none) +
            _count(noneOf) +
            _count(anyOf) +
            _count(allOf) +
            _count(not) +
            _count(unitKeyword) +
            _count(unitName) +
            _count(containsItem) +
            _count(itemKind) +
            _count(itemName) +
            _count(rangedWeapon) +
            _count(meleeWeapon) +
            _count(isGrenade) +
            _count(isBodyArmour) +
            _count(isShield) ==
        1);

    // primitive ops
    if (bypassValue != null) return bypassValue!;

    if (none ?? false) {
      return false;
    }

    // boolean ops
    if (noneOf
            ?.map((f) => f.isItemAllowed(item, warrior))
            .where((b) => b)
            .isNotEmpty ??
        false) {
      return false;
    }
    if (anyOf
            ?.map((f) => f.isItemAllowed(item, warrior))
            .where((b) => b)
            .isEmpty ??
        false) {
      return false;
    }

    final allTest = allOf ?? [];
    if (allTest
            .map((f) => f.isItemAllowed(item, warrior))
            .where((b) => b)
            .length !=
        allTest.length) {
      return false;
    }
    if (not?.isItemAllowed(item, warrior) ?? false) {
      return false;
    }

    // item based ops

    if (itemKind != null) {
      return item.kind == itemKind;
    }
    if (itemName != null) {
      return itemName == item.itemName;
    }

    if (rangedWeapon != null) {
      if (item is! Weapon) return false;
      return rangedWeapon == item.canRanged;
    }
    if (meleeWeapon != null) {
      if (item is! Weapon) return false;
      if (item.canRanged) return false;
      return meleeWeapon == item.canMelee;
    }
    if (isGrenade != null) {
      if (item is! Weapon) return false;
      return item.isGrenade;
    }

    if (isBodyArmour != null) {
      if (item is! Armour) return false;
      return isBodyArmour!
          ? item.type == ArmourType.bodyArmour
          : item.type != ArmourType.bodyArmour;
    }
    if (isShield != null) {
      if (item is! Armour) return false;
      return isShield!
          ? item.type == ArmourType.shield
          : item.type != ArmourType.shield;
    }

    // warrior based ops

    if (unitKeyword != null &&
        warrior != null &&
        warrior.type.keywords.where((kw) => kw == unitKeyword).isEmpty) {
      return false;
    }
    if (unitName != null &&
        warrior != null &&
        warrior.type.typeName != unitName) {
      return false;
    }
    if (containsItem != null &&
        warrior != null &&
        warrior.items.where((it) => it.getName == containsItem).isEmpty) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    if (none ?? false) return "none";
    if (bypassValue != null) return "$bypassValue";

    if (itemKind != null) return "itemKind: $itemKind";
    if (itemName != null) return "itemName: $itemName";

    if (rangedWeapon != null) return "rangedWeapon";
    if (meleeWeapon != null) return "meleeWeapon";
    if (isGrenade != null) return "grenade";

    if (unitKeyword != null) return "unitKeyword: $unitKeyword";
    if (unitName != null) return "unitName: $unitName";
    if (containsItem != null) return "containsItem: $containsItem";

    if (noneOf != null) {
      return "noneOf[${noneOf!.map((e) => e.toString()).join(",")}]";
    }
    if (anyOf != null) {
      return "anyOf[${anyOf!.map((e) => e.toString()).join(",")}]";
    }
    if (allOf != null) {
      return "allOf[${allOf!.map((e) => e.toString()).join(",")}]";
    }
    if (not != null) {
      return "![$not]";
    }

    return "INVALID FILTER!!";
  }

  factory FilterItem.fromJson(Map<String, dynamic> json) =>
      _$FilterItemFromJson(json);
  Map<String, dynamic> toJson() => _$FilterItemToJson(this);
}

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
  ItemReplacement({FilterItem? filter}) : filter = filter ?? FilterItem();

  FilterItem filter;

  // FIXME: this is a hack to get the right value for mech-armour, fix properly
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

@JsonSerializable()
class Unit {
  Unit();

  String typeName = "";
  int? max;
  int? min;
  int movement = 6;
  int ranged = 0;
  int melee = 0;
  int armour = 0;
  List<String>? abilities = [];
  List<String> keywords = [];
  List<DefaultItem>? defaultItems;
  Currency cost = const Currency(ducats: 0);
  String base = "25";
  int? hands;
  bool? unarmedPenalty;

  /// if the unit has not backpack, it needs to allocate all equipment to the hands
  bool? backpack;

  int get getHands => hands ?? 2;
  bool get hasBackpack => backpack ?? true;
  bool get getUnarmedPenalty => unarmedPenalty ?? true;

  FilterItem? filter;
  FilterItem get getFilter => filter ?? FilterItem.trueValue();

  factory Unit.fromJson(Map<String, dynamic> json) {
    for (var e in json.entries) {
      debugPrint("${e.key} : ${e.value}");
    }
    return _$UnitFromJson(json);
  }
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

abstract class ItemUse {
  String get getName;
  FilterItem get getFilter;
  bool get isRemovable;
  Currency get getCost;
  int get getLimit;
}

@JsonSerializable(explicitToJson: true)
class WeaponUse extends ItemUse {
  WeaponUse(
      {String? typeName,
      Currency? cost,
      this.removable,
      this.filter,
      this.limit})
      : typeName = typeName ?? "",
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = const Currency(ducats: 0);
  bool? removable;
  FilterItem? filter;
  int? limit;

  @override
  String get getName => typeName;
  @override
  Currency get getCost => cost;
  @override
  FilterItem get getFilter => filter ?? FilterItem.trueValue();
  @override
  bool get isRemovable => removable ?? true;
  @override
  int get getLimit => limit ?? double.maxFinite.toInt();

  factory WeaponUse.fromJson(Map<String, dynamic> json) =>
      _$WeaponUseFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponUseToJson(this);

  factory WeaponUse.unarmed() =>
      WeaponUse(typeName: "Unarmed", cost: Currency.free(), removable: false);
}

@JsonSerializable(explicitToJson: true)
class ArmorUse extends ItemUse {
  ArmorUse(
      {String? typeName,
      Currency? cost,
      this.removable,
      this.limit,
      this.filter})
      : typeName = typeName ?? "",
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = Currency.free();
  bool? removable;
  int? limit;
  FilterItem? filter;

  @override
  String get getName => typeName;
  @override
  FilterItem get getFilter => filter ?? FilterItem.trueValue();
  @override
  bool get isRemovable => removable ?? true;
  @override
  int get getLimit => limit ?? double.maxFinite.toInt();
  @override
  Currency get getCost => cost;

  factory ArmorUse.fromJson(Map<String, dynamic> json) =>
      _$ArmorUseFromJson(json);
  Map<String, dynamic> toJson() => _$ArmorUseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EquipmentUse extends ItemUse {
  EquipmentUse({String? typeName, bool? removable, Currency? cost})
      : typeName = typeName ?? "",
        removable = removable ?? true,
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = Currency.free();
  bool? removable;
  int? limit;
  FilterItem? filter;

  @override
  String get getName => typeName;
  @override
  FilterItem get getFilter => filter ?? FilterItem.trueValue();
  @override
  bool get isRemovable => removable ?? true;
  @override
  Currency get getCost => cost;
  @override
  int get getLimit => limit ?? double.maxFinite.toInt();

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
  List<ArmorUse> armour = [];
  List<EquipmentUse> equipment = [];

  List<Weapon>? uniqueWeapons = [];
  List<Armour>? uniqueArmour = [];
  List<Equipment>? uniqueEquipment = [];

  List<dynamic> get items =>
      weapons.map<dynamic>((e) => e).toList() +
      armour.map<dynamic>((e) => e).toList() +
      equipment.map<dynamic>((e) => e).toList();

  factory Roster.fromJson(Map<String, dynamic> json) => _$RosterFromJson(json);
  Map<String, dynamic> toJson() => _$RosterToJson(this);
}

abstract class Item {
  UnmodifiableListView<String> get getKeywords;
  ItemKind get kind;
  FilterItem get getFilter;
  String get itemName;
}

enum BonusType { dice, value }

String bonus(int v, {BonusType type = BonusType.dice}) {
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
      {String? typename,
      int? hands,
      this.range,
      this.melee,
      this.keywords,
      this.modifiers})
      : typeName = typename ?? "",
        hands = hands ?? 1;

  String typeName = "";
  int hands = 1;
  int? range;
  bool? melee;
  List<String>? keywords;
  List<Modifier>? modifiers = [];
  FilterItem? filter;

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
  FilterItem get getFilter => filter ?? FilterItem.trueValue();
  @override
  String get itemName => typeName;

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
      if (acc == "") {
        return mod;
      }
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
    w.modifiers = [Modifier(hit: -1, injury: -1)];
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
  FilterItem? filter;

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);
  @override
  ItemKind get kind => ItemKind.armour;
  @override
  FilterItem get getFilter => filter ?? FilterItem.trueValue();
  @override
  String get itemName => typeName;

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
  FilterItem? filter;

  bool get isConsumable => consumable ?? false;

  @override
  ItemKind get kind => ItemKind.equipment;
  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);
  @override
  FilterItem get getFilter => filter ?? FilterItem.trueValue();
  @override
  String get itemName => typeName;

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Armory {
  Armory();

  List<Weapon> weapons = [];
  List<Armour> armours = [];
  List<Equipment> equipments = [];

  factory Armory.fromJson(Map<String, dynamic> json) => _$ArmoryFromJson(json);
  Map<String, dynamic> toJson() => _$ArmoryToJson(this);

  Weapon findWeapon(dynamic w) {
    if (w is WeaponUse) return findWeapon(w.typeName);
    if (w == "Unarmed") return Weapon.unarmed();
    return weapons.firstWhere((def) => def.typeName == w);
  }

  bool isWeapon(String typeName) {
    return weapons.where((def) => def.typeName == typeName).length == 1;
  }

  Armour findArmour(dynamic a) {
    if (a is ArmorUse) return findArmour(a.typeName);
    return armours.firstWhere((def) => def.typeName == a);
  }

  bool isArmour(String typeName) {
    return armours.where((def) => def.typeName == typeName).length == 1;
  }

  Equipment findEquipment(dynamic e) {
    if (e is EquipmentUse) return findEquipment(e.typeName);
    return equipments.firstWhere((def) => def.typeName == e);
  }

  bool isEquipment(String typeName) {
    return equipments.where((def) => def.typeName == typeName).length == 1;
  }

  void extendWithUnique(Roster roster) {
    weapons.addAll(roster.uniqueWeapons ?? []);
    armours.addAll(roster.uniqueArmour ?? []);
    equipments.addAll(roster.uniqueEquipment ?? []);
  }

  Item findItem(ItemUse item) {
    if (item is WeaponUse) return findWeapon(item);
    if (item is ArmorUse) return findArmour(item);
    return findEquipment(item as EquipmentUse);
  }
}
