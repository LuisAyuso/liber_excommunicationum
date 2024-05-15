import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Filter {
  Filter({this.whitelist, this.blacklist, this.none});

  bool? none = false;
  List<String>? whitelist;
  List<String>? blacklist;

  factory Filter.whitelist(List<String> list) => Filter(whitelist: list);
  factory Filter.blacklist(List<String> list) => Filter(blacklist: list);
  factory Filter.none() => Filter(none: true);
  factory Filter.any() => Filter();

  bool isAllowed(String typeName) {
    if (none ?? false) {
      return false;
    }

    bool allowed = true;
    if (whitelist != null) {
      allowed =
          allowed && whitelist!.where((str) => str == typeName).isNotEmpty;
    }
    if (blacklist != null) {
      allowed = allowed && blacklist!.where((str) => str == typeName).isEmpty;
    }
    return allowed;
  }

  factory Filter.fromJson(Map<String, dynamic> json) => _$FilterFromJson(json);
  Map<String, dynamic> toJson() => _$FilterToJson(this);
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
    if (v.glory < 0 && v.ducats == 0) return other;
    return other;
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

enum ReplacementPolicy { any, anyExcept, anyFrom }

@JsonSerializable()
class ItemReplacement {
  ItemReplacement({this.policy = ReplacementPolicy.any, this.values});

  ReplacementPolicy policy = ReplacementPolicy.anyFrom;
  List<String>? values = [];

  bool isAllowed(String itemName) {
    switch (policy) {
      case ReplacementPolicy.any:
        return true;
      case ReplacementPolicy.anyExcept:
        return (values ?? []).where((v) => v == itemName).isEmpty;
      case ReplacementPolicy.anyFrom:
        return (values ?? []).where((v) => v == itemName).isNotEmpty;
    }
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
  int base = 25;

  Filter? rangedWeaponFilter;
  Filter get getRangedWeaponFilter => rangedWeaponFilter ?? Filter();
  Filter? meleeWeaponFilter;
  Filter get getMeleeWeaponFilter => meleeWeaponFilter ?? Filter();
  Filter? armourFilter;
  Filter get getArmourFilter => armourFilter ?? Filter();
  Filter? equipmentFilter;
  Filter get getEquipmentFilter => equipmentFilter ?? Filter();

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
  Filter get getUnitNameFilter;
  Filter get getKeywordFilter;
  bool get isRemovable;
  Currency get getCost;
  int get getLimit;
}

@JsonSerializable(explicitToJson: true)
class WeaponUse extends ItemUse {
  WeaponUse({String? typeName, bool? removable, Currency? cost})
      : typeName = typeName ?? "",
        removable = removable ?? true,
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = const Currency(ducats: 0);
  bool? removable;

  Filter? unitNameFilter;
  Filter? keywordFilter;
  int? limit;

  @override
  String get getName => typeName;
  @override
  Currency get getCost => cost;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();
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
  ArmorUse({String? typeName, bool? removable, Currency? cost})
      : typeName = typeName ?? "",
        removable = removable ?? true,
        cost = cost ?? Currency.free();

  String typeName = "";
  Currency cost = Currency.free();
  bool? removable;
  int? limit;

  @override
  String get getName => typeName;
  Filter? unitNameFilter;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  Filter? keywordFilter;
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();
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
  Filter? unitNameFilter;
  Filter? keywordFilter;

  @override
  String get getName => typeName;
  @override
  Filter get getUnitNameFilter => unitNameFilter ?? Filter();
  @override
  Filter get getKeywordFilter => keywordFilter ?? Filter();
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

  bool filter(ModifierType other) {
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
  Weapon();
  String typeName = "";
  int hands = 1;
  int? range;
  bool? melee;
  List<String>? keywords;
  List<Modifier>? modifiers = [];

  bool get canMelee => range == null || (melee ?? false);
  bool get canRanged => range != null;
  bool get isFirearm => canRanged && !typeName.contains("Pistol");
  bool get isMeleeWeapon => !canRanged && canMelee;
  bool get isPistol => typeName.contains("Pistol");
  bool get isRifle => typeName.contains("Rifle");
  bool get isGrenade => hands == 0 && canRanged;

  UnmodifiableListView<Modifier> get getModifiers =>
      UnmodifiableListView(modifiers ?? []);

  String getModifiersString(Modifier baseValue, ModifierType type) {
    String res = "";
    if (!baseValue.isEmpty &&
        (modifiers ?? []).where((mod) => mod.filter(type)).where((mod) {
          return baseValue.cat() == mod.cat();
        }).isEmpty) {
      res = baseValue.toString();
    }
    return (modifiers ?? []).where((m) => m.filter(type)).fold<String>(res,
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

@JsonSerializable(explicitToJson: true)
class Armour extends Item {
  Armour();
  String typeName = "";
  int? value;
  List<String>? special = [];
  List<String>? keywords = [];

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

  bool get isShield => typeName.contains("Shield");
  bool get isArmour => typeName.contains("Armour");
  factory Armour.fromJson(Map<String, dynamic> json) => _$ArmourFromJson(json);
  Map<String, dynamic> toJson() => _$ArmourToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Equipment extends Item {
  Equipment();

  String typeName = "";
  bool? consumable;
  List<String>? keywords = [];

  bool get isConsumable => consumable ?? false;

  @override
  UnmodifiableListView<String> get getKeywords =>
      UnmodifiableListView(keywords ?? []);

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
}
