import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/utils.dart';

import 'unit_selector.dart';

class WarriorModel {
  WarriorModel(
      {String? name,
      required this.uid,
      required this.type,
      required this.bucket,
      Armory? armory})
      : name = name ?? "Generated" {
    if (armory != null) {
      populateBuiltInWeapons(armory);
      populateBuiltInArmour(armory);
      populateBuiltInEquipment(armory);
    }
  }

  String name = "Generated name?";
  final int uid;
  final Unit type;
  List<WeaponUse> weapons = [];
  List<ArmorUse> armor = [];
  List<EquipmentUse> equipment = [];
  final int bucket;

  WarriorModel copyWith({required String name, required int newUid}) {
    var w = WarriorModel(name: name, uid: newUid, type: type, bucket: bucket);
    w.weapons = List.of(weapons);
    w.armor = List.of(armor);
    w.equipment = List.of(equipment);
    return w;
  }

  Currency get totalCost => baseCost + equipmentCost;
  Currency get baseCost => type.cost;
  Currency get equipmentCost =>
      weapons.fold<Currency>(Currency.free(), (v, w) => w.cost + v) +
      armor.fold<Currency>(Currency.free(), (v, w) => w.cost + v) +
      equipment.fold<Currency>(Currency.free(), (v, w) => w.cost + v);

  void populateBuiltInWeapons(Armory armory) {
    for (var item in type.builtInItems ?? []) {
      final candidates = armory.weapons.where((w) => w.name == item);
      if (candidates.length > 1) {
        Exception("failed to find weapon named $item, more than one match");
      }
      if (candidates.length == 1) {
        weapons.add(WeaponUse(name: item, builtIn: true));
      }
    }
  }

  void populateBuiltInArmour(Armory armory) {
    for (var item in type.builtInItems ?? []) {
      final candidates = armory.armours.where((a) => a.name == item);
      if (candidates.length > 1) {
        throw Exception(
            "failed to find weapon named $item, more than one match");
      }
      if (candidates.length == 1) {
        armor.add(ArmorUse(name: item, builtIn: true));
      }
    }
  }

  void populateBuiltInEquipment(Armory armory) {
    for (var item in type.builtInItems ?? []) {
      final candidates = armory.equipments.where((e) => e.name == item);
      if (candidates.length > 1) {
        throw Exception(
            "failed to find weapon named $item, more than one match");
      }
      if (candidates.length == 1) {
        equipment.add(EquipmentUse(name: item, builtIn: true));
      }
    }
  }

  int getArmorValue(Armory armory) {
    return type.armor +
        armor
            .map((a) => armory.armours.firstWhere((e) => e.name == a.name))
            .map((a) => a.value ?? 0)
            .fold(0, (a, b) => a + b);
  }
}

class WarbandModel extends ChangeNotifier {
  final List<WarriorModel> _items = [];
  int _id = 0;

  UnmodifiableListView<WarriorModel> get items => UnmodifiableListView(_items);
  int get length => _items.length;
  Currency get cost =>
      _items.fold<Currency>(Currency.free(), (v, w) => v + w.totalCost);

  void add(WarriorModel item) {
    _items.add(item);
    _items.sort((a, b) => a.bucket.compareTo(b.bucket));
    notifyListeners();
  }

  int nextUID() {
    return ++_id;
  }

  WarriorModel getUID(int uid) {
    return _items.firstWhere((w) => w.uid == uid);
  }

  void removeUID(int uid) {
    _items.removeWhere((w) => w.uid == uid);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void invalidate() {
    notifyListeners();
  }
}

class WarbandView extends StatefulWidget {
  const WarbandView(
      {super.key,
      required this.title,
      required this.roster,
      required this.armory});
  final String title;
  final Roster roster;
  final Armory armory;

  @override
  State<WarbandView> createState() => _WarbandViewState();
}

class _WarbandViewState extends State<WarbandView> {
  bool _editMode = true;
  set edit(bool v) {
    setState(() => _editMode = v);
  }

  @override
  Widget build(BuildContext context) {
    return MyContent(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Row(children: [
            CostWidget(cost: context.watch<WarbandModel>().cost),
            Text(widget.title),
            const Spacer(),
            Switch(value: _editMode, onChanged: (v) => edit = v)
          ]),
        ),
        body: ListView.separated(
            itemBuilder: (context, idx) {
              var warrior = context.read<WarbandModel>().items[idx];
              return warriorLine(context, warrior);
            },
            separatorBuilder: (context, idx) => const Divider(),
            itemCount: context.watch<WarbandModel>().length),
        floatingActionButton: _editMode
            ? FloatingActionButton(
                onPressed: () => openUnitSelection(context),
                tooltip: 'Add Unit',
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void openUnitSelection(BuildContext context) {
    var value = context.read<WarbandModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
            value: value,
            builder: (context, child) =>
                UnitSelector(roster: widget.roster, armory: widget.armory)),
      ),
    );
  }

  Widget warriorLine(BuildContext context, WarriorModel warrior) {
    final weapons = warrior.weapons.map((w) => getWeaponDef(w));
    final armours = warrior.armor.map((a) => getArmorDef(a));
    final pistols = weapons.fold(0, (v, w) => v + (w.isPistol ? 1 : 0));
    final firearms = weapons.fold(0, (v, w) => v + ((w.isFirearm) ? 1 : 0));
    final melee = weapons.fold(0, (v, w) => v + (w.isMeleeWeapon ? 1 : 0));

    final allowPistol =
        (firearms == 0 && pistols < 2) || (firearms == 1 && pistols < 1);
    final allowMelee =
        armours.where((a) => a.isShield).isEmpty ? melee <= 2 : melee <= 1;
    final freeHands = 2 -
        weapons.where((w) => w.isMeleeWeapon).fold(0, (v, w) => v + w.hands);

// - One firearm and one pistol OR
// - two pistols.
// In addition, they may carry:
// - One two-handed melee weapon OR
// - one single-handed melee weapon and a trench shield OR
// - two single-handed melee weapons.

    final availableWeapons = widget.roster.weapons.where((weapon) {
      final def = getWeaponDef(weapon);

      if (def.canMelee &&
          !warrior.type.getMeleeWeaponFilter.isAllowed(weapon.name)) {
        return false;
      }

      if (def.canRanged &&
          !warrior.type.getRangedWeaponFilter.isAllowed(weapon.name)) {
        return false;
      }

      if (!weapon.getUnitNameFilter.isAllowed(warrior.type.name)) {
        return false;
      }

      if (!warrior.type.keywords.fold(false,
          (v, keyword) => v || weapon.getKeywordFilter.isAllowed(keyword))) {
        return false;
      }

      if (def.isPistol && allowPistol) return true;
      if (def.isFirearm && firearms < 1) return true;
      if (def.isMeleeWeapon && allowMelee) {
        return freeHands >= def.hands;
      }

      return false;
    });

    final bodyArmour = armours.where((a) => a.isArmour).isNotEmpty;
    final shield = armours.where((a) => a.isShield).isNotEmpty;

    final availablearmours = widget.roster.armor.where((armour) {
      if (!warrior.type.getArmourFilter.isAllowed(armour.name)) {
        return false;
      }

      if (!armour.getUnitNameFilter.isAllowed(warrior.type.name)) {
        return false;
      }

      if (!warrior.type.keywords.fold(false,
          (v, keyword) => v || armour.getKeywordFilter.isAllowed(keyword))) {
        return false;
      }

      final def = getArmorDef(armour);
      if (def.isArmour && bodyArmour) return false;
      if (def.isShield && shield) return false;

      return true;
    });

    final availableEquipment = widget.roster.equipment.where((equip) {
      if (!warrior.type.getEquipmentFilter.isAllowed(equip.name)) {
        return false;
      }

      if (!equip.getUnitNameFilter.isAllowed(warrior.type.name)) {
        return false;
      }

      if (!warrior.type.keywords.fold(false,
          (v, keyword) => v || equip.getKeywordFilter.isAllowed(keyword))) {
        return false;
      }

      final def = getEquipmentDef(equip);
      if (!def.isConsumable &&
          warrior.equipment.where((e) => e.name == def.name).isNotEmpty) {
        return false;
      }

      return true;
    });

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(children: [
        CostWidget(
          cost: warrior.totalCost,
        ),
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warrior.name,
                style: const TextStyle(
                    fontFamily: "CloisterBlack",
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                    color: Color.fromARGB(255, 167, 51, 30)),
              ),
              Text(
                warrior.type.name,
              )
            ],
          ),
        ),
        const VerticalDivider(),
        Row(
          children: [
            statBox("Mov:", '${warrior.type.movement}"'),
            statBox("Armor:", warrior.getArmorValue(widget.armory)),
          ],
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(
            children: warrior.weapons
                .map<Widget>(
                  (w) => Chip(
                    label: Text(w.name),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                )
                .toList(),
          ),
          Row(
            children: warrior.armor
                    .map<Widget>(
                      (a) => Chip(
                        label: Text(a.name),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    )
                    .toList() +
                warrior.equipment
                    .map<Widget>(
                      (e) => Chip(
                        label: Text(e.name),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    )
                    .toList(),
          ),
        ]),
      ]),
      children: [
        Column(
          children: warrior.weapons
                  .map<Widget>((w) => weaponLine(context, w, warrior))
                  .toList() +
              warrior.armor
                  .map<Widget>((a) => armorLine(context, a, warrior))
                  .toList() +
              warrior.equipment
                  .map<Widget>((e) => equipmentLine(context, e, warrior))
                  .toList(),
        ),
        _editMode
            ? Row(
                children: [
                  DropdownMenu(
                    dropdownMenuEntries: availableWeapons
                        .map<DropdownMenuEntry<String>>((WeaponUse w) =>
                            DropdownMenuEntry(value: w.name, label: w.name))
                        .toList(),
                    onSelected: (weapon) {
                      final w = widget.roster.weapons
                          .firstWhere((w) => w.name == weapon);
                      context
                          .read<WarbandModel>()
                          .getUID(warrior.uid)
                          .weapons
                          .add(w);
                      context.read<WarbandModel>().invalidate();
                    },
                  ),
                  DropdownMenu(
                    dropdownMenuEntries: availablearmours
                        .map<DropdownMenuEntry<String>>((ArmorUse w) =>
                            DropdownMenuEntry(value: w.name, label: w.name))
                        .toList(),
                    onSelected: (armour) {
                      final a = widget.roster.armor
                          .firstWhere((w) => w.name == armour);
                      context
                          .read<WarbandModel>()
                          .getUID(warrior.uid)
                          .armor
                          .add(a);
                      context.read<WarbandModel>().invalidate();
                    },
                  ),
                  DropdownMenu(
                    dropdownMenuEntries: availableEquipment
                        .map<DropdownMenuEntry<String>>((EquipmentUse w) =>
                            DropdownMenuEntry(value: w.name, label: w.name))
                        .toList(),
                    onSelected: (e) {
                      final equip = widget.roster.equipment
                          .firstWhere((w) => w.name == e);
                      context
                          .read<WarbandModel>()
                          .getUID(warrior.uid)
                          .equipment
                          .add(equip);
                      context.read<WarbandModel>().invalidate();
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      var wbm = context.read<WarbandModel>();
                      wbm.add(warrior.copyWith(
                          name: makeName(
                              widget.roster.namesM, widget.roster.surnames),
                          newUid: wbm.nextUID()));
                    },
                    icon: const Icon(Icons.copy),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<WarbandModel>().removeUID(warrior.uid);
                    },
                    icon: const Icon(Icons.delete),
                  )
                ],
              )
            : const SizedBox()
      ],
    );
  }

  Widget weaponLine(BuildContext context, WeaponUse w, WarriorModel warrior) {
    final def = getWeaponDef(w);
    var ranged = "Ranged ${(def.ranged ?? 0) + warrior.type.ranged}";
    var melee = "Melee ${(def.melee ?? 0) + warrior.type.melee}";
    var injury = def.injury == null ? "" : " Injury ${def.injury ?? 0}";
    return Row(
      children: [
        const SizedBox(
          width: 40,
        ),
        SizedBox(
          width: 240,
          child: Text(w.name),
        ),
        const Divider(),
        Builder(builder: (context) {
          if (def.canRanged && def.canMelee) {
            return Text("$ranged $melee$injury");
          }
          if (def.canRanged) return Text("$ranged$injury");
          if (def.canMelee) return Text("$melee$injury");
          return const Text("Unknown");
        }),
        const Spacer(),
        _editMode && !w.isBuiltIn
            ? IconButton(
                onPressed: () {
                  warrior.weapons.removeWhere((d) => w.name == d.name);
                  context.read<WarbandModel>().invalidate();
                },
                icon: const Icon(Icons.delete))
            : const SizedBox()
      ],
    );
  }

  Widget armorLine(BuildContext context, ArmorUse a, WarriorModel warrior) {
    final def = getArmorDef(a);
    return Row(
      children: [
        const SizedBox(
          width: 40,
        ),
        SizedBox(
          width: 240,
          child: Text(a.name),
        ),
        const Divider(),
        Row(
          children: [Text("${def.value ?? 0}")],
        ),
        const Spacer(),
        _editMode && !a.isBuiltIn
            ? IconButton(
                onPressed: () {
                  warrior.armor.removeWhere((d) => a.name == d.name);
                  context.read<WarbandModel>().invalidate();
                },
                icon: const Icon(Icons.delete))
            : const SizedBox()
      ],
    );
  }

  Widget equipmentLine(
      BuildContext context, EquipmentUse e, WarriorModel warrior) {
    return Row(
      children: [
        const SizedBox(
          width: 40,
        ),
        SizedBox(
          width: 240,
          child: Text(e.name),
        ),
        const Spacer(),
        _editMode && !e.isBuiltIn
            ? IconButton(
                onPressed: () {
                  warrior.equipment.removeWhere((d) => e.name == d.name);
                  context.read<WarbandModel>().invalidate();
                },
                icon: const Icon(Icons.delete))
            : const SizedBox()
      ],
    );
  }

  Weapon getWeaponDef(WeaponUse w) =>
      widget.armory.weapons.firstWhere((def) => def.name == w.name);

  Armor getArmorDef(ArmorUse w) =>
      widget.armory.armours.firstWhere((def) => def.name == w.name);

  Equipment getEquipmentDef(EquipmentUse w) =>
      widget.armory.equipments.firstWhere((def) => def.name == w.name);
}

class CostWidget extends StatelessWidget {
  const CostWidget(
      {super.key, required Currency cost, double? width, double? height})
      : _cost = cost,
        _width = width ?? 60,
        _height = height ?? 60;

  final double _width;
  final double _height;
  final Currency _cost;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(children: [
        _cost.glory > 0
            ? Positioned(bottom: 0, right: 0, child: gloryValue())
            : const SizedBox(),
        _cost.ducats > 0
            ? Center(
                child: Text(
                  "${_cost.ducats}",
                  style: const TextStyle(
                    fontFamily: "CloisterBlack",
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    color: Color.fromARGB(255, 32, 31, 31),
                  ),
                ),
              )
            : const SizedBox(),
      ]),
    );
  }

  Widget gloryValue() => Stack(alignment: Alignment.center, children: [
        const Icon(
          Icons.star,
          size: 40,
          color: Color.fromARGB(255, 167, 51, 30),
        ),
        Text(
          "${_cost.glory}",
          style: const TextStyle(
            fontFamily: "CloisterBlack",
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ]);
}

Widget statBox<T>(String name, T stat) {
  return Column(
    children: [
      Text(name),
      Text(
        textAlign: TextAlign.end,
        "$stat",
      ),
    ],
  );
}
