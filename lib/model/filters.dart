import 'package:json_annotation/json_annotation.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

part 'filters.g.dart';

enum ItemKind { weapon, armour, equipment }

class BaseFilter<T> {
  BaseFilter({
    this.bypassValue,
    this.none,
    this.noneOf,
    this.anyOf,
    this.allOf,
    this.not,
  });
  bool? bypassValue;
  bool? none;
  List<T>? noneOf;
  List<T>? anyOf;
  List<T>? allOf;
  T? not;

  int _count<M>(M? x) {
    return x == null ? 0 : 1;
  }

  // returns if the filter was used, and it accepted the item
  (bool, bool) applyBaseFilter(bool Function(T) filter) {
    if (bypassValue != null) return (true, bypassValue!);

    if (none != null) return (true, false);

    if (noneOf != null) {
      if (noneOf!.map(filter).where((b) => b).isNotEmpty) {
        return (true, false);
      } else {
        return (true, true);
      }
    }

    if (anyOf != null) {
      if (anyOf!.map(filter).where((b) => b).isEmpty) {
        return (true, false);
      } else {
        return (true, true);
      }
    }

    if (allOf != null) {
      final v = allOf!.map(filter).toList();
      if (v.where((b) => b).length != allOf!.length) {
        return (true, false);
      } else {
        return (true, true);
      }
    }

    if (not != null) {
      return (true, !filter(not as T));
    }

    return (false, true);
  }
}

enum UnitType { elite, trooper }

@JsonSerializable()
class UnitFilter extends BaseFilter<UnitFilter> {
  UnitFilter({
    super.bypassValue,
    super.none,
    super.noneOf,
    super.anyOf,
    super.allOf,
    super.not,
    this.max,
    this.containsUnit,
    this.type,
    this.sameCountAs,
  });
  int? max;
  String? containsUnit;
  String? typeName;
  UnitType? type;
  String? sameCountAs;

  bool isUnitAllowed(Unit unit, Iterable<WarriorModel> warband) {
    assert(_count(bypassValue) +
            _count(none) +
            _count(noneOf) +
            _count(anyOf) +
            _count(allOf) +
            _count(not) +
            _count(max) +
            _count(typeName) +
            _count(containsUnit) +
            _count(type) +
            _count(sameCountAs) ==
        1);

    // base bool operations
    final (applied, allowed) =
        applyBaseFilter((f) => f.isUnitAllowed(unit, warband));
    if (applied) return allowed;

    if (type != null) {
      switch (type!) {
        case UnitType.trooper:
          return !unit.keywords.contains("ELITE");
        case UnitType.elite:
          return unit.keywords.contains("ELITE");
      }
    }

    if (typeName != null) {
      return unit.typeName == typeName;
    }

    if (containsUnit != null) {
      return warband.where((w) => w.type.typeName == containsUnit).isNotEmpty;
    }

    final unitCount =
        warband.where((w) => w.type.typeName == unit.typeName).length;

    if (max != null) {
      return unitCount < max!;
    }

    if (sameCountAs != null) {
      final otherUnitCount =
          warband.where((w) => w.type.typeName == sameCountAs!).length;
      return unitCount < otherUnitCount;
    }

    return true;
  }

  @override
  String toString() {
    if (none ?? false) return "none";
    if (bypassValue != null) return "$bypassValue";

    if (max != null) return "max: $max";
    if (containsUnit != null) return "containsUnit: $containsUnit";

    if (typeName != null) return "typename ${typeName!}";
    if (type != null) return "type ${type!}";
    if (sameCountAs != null) return "sameCountAs $sameCountAs!}";

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

  factory UnitFilter.trueValue() => UnitFilter(bypassValue: true);
  factory UnitFilter.falseValue() => UnitFilter(bypassValue: false);
  factory UnitFilter.allOf(Iterable<UnitFilter> all) {
    if (all.isEmpty) return UnitFilter.trueValue();
    if (all.length == 1) return all.first;
    return UnitFilter(allOf: all.toList());
  }
  factory UnitFilter.noneOf(Iterable<UnitFilter> none) {
    if (none.isEmpty) return UnitFilter.trueValue();
    return UnitFilter(noneOf: none.toList());
  }
  factory UnitFilter.anyOf(Iterable<UnitFilter> any) {
    if (any.isEmpty) return UnitFilter.trueValue();
    if (any.length == 1) return any.first;
    return UnitFilter(anyOf: any.toList());
  }
  factory UnitFilter.none() => UnitFilter(none: true);
  factory UnitFilter.not(UnitFilter filter) => UnitFilter(not: filter);

  factory UnitFilter.max(int max) => UnitFilter(max: max);
  factory UnitFilter.elites() => UnitFilter(type: UnitType.elite);
  factory UnitFilter.troops() => UnitFilter(type: UnitType.trooper);

  factory UnitFilter.fromJson(Map<String, dynamic> json) =>
      _$UnitFilterFromJson(json);
  Map<String, dynamic> toJson() => _$UnitFilterToJson(this);
}

@JsonSerializable()
class ItemFilter extends BaseFilter<ItemFilter> {
  ItemFilter({
    super.bypassValue,
    super.none,
    super.noneOf,
    super.anyOf,
    super.allOf,
    super.not,
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

  factory ItemFilter.trueValue() => ItemFilter(bypassValue: true);
  factory ItemFilter.falseValue() => ItemFilter(bypassValue: false);
  factory ItemFilter.allOf(Iterable<ItemFilter> all) =>
      ItemFilter(allOf: all.toList());
  factory ItemFilter.noneOf(Iterable<ItemFilter> none) =>
      ItemFilter(noneOf: none.toList());
  factory ItemFilter.anyOf(Iterable<ItemFilter> any) =>
      ItemFilter(anyOf: any.toList());
  factory ItemFilter.none() => ItemFilter(none: true);
  factory ItemFilter.not(ItemFilter filter) => ItemFilter(not: filter);
  factory ItemFilter.grenade() => ItemFilter(isGrenade: true);

  String? unitKeyword;
  String? unitName;
  String? containsItem;
  int? maxRepetitions;

  ItemKind? itemKind;
  String? itemName;
  String? itemKeyword;

  bool? rangedWeapon;
  bool? meleeWeapon;
  bool? isGrenade;
  bool? isBodyArmour;
  bool? isShield;

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
            _count(maxRepetitions) +
            _count(itemKind) +
            _count(itemName) +
            _count(itemKeyword) +
            _count(rangedWeapon) +
            _count(meleeWeapon) +
            _count(isGrenade) +
            _count(isBodyArmour) +
            _count(isShield) ==
        1);

    // base bool operations
    var (applied, allowed) =
        applyBaseFilter((f) => f.isItemAllowed(item, warrior));
    if (applied) return allowed;

    // item based ops
    if (itemKind != null) {
      return item.kind == itemKind;
    }
    if (itemName != null) {
      return itemName == item.itemName;
    }
    if (itemKeyword != null) {
      return item.getKeywords.where((kw) => kw == itemKeyword).isNotEmpty;
    }

    if (rangedWeapon != null) {
      if (item is! Weapon) return false;
      return rangedWeapon == item.canRanged;
    }
    if (meleeWeapon != null) {
      if (item is! Weapon) return false;
      // exclusive melee
      return item.canRanged != meleeWeapon! && meleeWeapon == item.canMelee;
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
    if (maxRepetitions != null &&
        warrior != null &&
        warrior.items.where((it) => it.getName == item.itemName).length >
            maxRepetitions!) {
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

    if (rangedWeapon != null) return "rangedWeapon ${rangedWeapon!}";
    if (meleeWeapon != null) return "meleeWeapon ${meleeWeapon!}";
    if (isGrenade != null) return "grenade ${isGrenade!}";

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

  factory ItemFilter.fromJson(Map<String, dynamic> json) =>
      _$ItemFilterFromJson(json);
  Map<String, dynamic> toJson() => _$ItemFilterToJson(this);
}
