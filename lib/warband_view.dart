import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/roster_preview.dart';
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
  List<ArmorUse> armour = [];
  List<EquipmentUse> equipment = [];
  final int bucket;

  WarriorModel copyWith({required String name, required int newUid}) {
    var w = WarriorModel(name: name, uid: newUid, type: type, bucket: bucket);
    w.weapons = List.of(weapons);
    w.armour = List.of(armour);
    w.equipment = List.of(equipment);
    return w;
  }

  Currency get totalCost => baseCost + equipmentCost;
  Currency get baseCost => type.cost;
  Currency get equipmentCost =>
      weapons.fold<Currency>(Currency.free(), (v, w) => w.cost + v) +
      armour.fold<Currency>(Currency.free(), (v, w) => w.cost + v) +
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
        armour.add(ArmorUse(name: item, builtIn: true));
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
    return type.armour +
        armour
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
            CurrencyWidget(cost: context.watch<WarbandModel>().cost),
            Text(widget.title),
            const Spacer(),
            InkWell(
              child: const Icon(Icons.note),
              onTap: () => openRosterPreview(context),
            ),
            const VerticalDivider(),
            const Text("Edit:"),
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

  void openRosterPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RosterPreview(roster: widget.roster, armory: widget.armory),
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
    final armours = warrior.armour.map((a) => getArmorDef(a));
    final pistols = weapons.fold(0, (v, w) => v + (w.isPistol ? 1 : 0));
    final firearms = weapons.fold(0, (v, w) => v + ((w.isFirearm) ? 1 : 0));
    final melee = weapons.fold(0, (v, w) => v + (w.isMeleeWeapon ? 1 : 0));

    final allowPistol =
        (firearms == 0 && pistols < 2) || (firearms == 1 && pistols < 1);
    final allowMelee =
        armours.where((a) => a.isShield).isEmpty ? melee <= 2 : melee <= 1;
    final freeHands = 2 -
        weapons.where((w) => w.isMeleeWeapon).fold(0, (v, w) => v + w.hands);

    final unitCount = context
        .read<WarbandModel>()
        .items
        .where((other) => other.type.name == warrior.type.name)
        .length;

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

    final availableArmours = widget.roster.armour.where((armour) {
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
        CurrencyWidget(
          cost: warrior.totalCost,
        ),
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(warrior.name, style: gothRed24),
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
            statBox("Armour:", warrior.getArmorValue(widget.armory)),
          ],
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(
            children: warrior.weapons
                .map<Widget>((w) => ItemChip(name: w.name))
                .toList(),
          ),
          Row(
            children: warrior.armour
                    .map<Widget>((w) => ItemChip(name: w.name))
                    .toList() +
                warrior.equipment
                    .map<Widget>((w) => ItemChip(name: w.name))
                    .toList(),
          ),
        ]),
      ]),
      children: [
        Column(
          children: warrior.weapons
                  .map<Widget>((w) => weaponLine(context, w, warrior))
                  .toList() +
              warrior.armour
                  .map<Widget>((a) => armorLine(context, a, warrior))
                  .toList() +
              warrior.equipment
                  .map<Widget>((e) => equipmentLine(context, e, warrior))
                  .toList() +
              editControls(warrior, availableWeapons, availableArmours,
                  availableEquipment, unitCount),
        ),
      ],
    );
  }

  UnmodifiableListView<Widget> editControls(
    WarriorModel warrior,
    Iterable<WeaponUse> weapons,
    Iterable<ArmorUse> armours,
    Iterable<EquipmentUse> equipment,
    int unitCount,
  ) {
    if (_editMode) {
      return UnmodifiableListView([
        Row(children: [
          Container(
              constraints: const BoxConstraints(minWidth: 120),
              child: const Text("Add Weapon: ")),
          itemDropDownMenu(weapons, warrior, (weapon) {
            final w = widget.roster.weapons.firstWhere((w) => w.name == weapon);
            context.read<WarbandModel>().getUID(warrior.uid).weapons.add(w);
            context.read<WarbandModel>().invalidate();
          }),
        ]),
        Row(children: [
          Container(
              constraints: const BoxConstraints(minWidth: 120),
              child: const Text("Add Armour: ")),
          itemDropDownMenu(armours, warrior, (armour) {
            final a = widget.roster.armour.firstWhere((w) => w.name == armour);
            context.read<WarbandModel>().getUID(warrior.uid).armour.add(a);
            context.read<WarbandModel>().invalidate();
          }),
        ]),
        Row(children: [
          Container(
              constraints: const BoxConstraints(minWidth: 120),
              child: const Text("Add Equipment: ")),
          itemDropDownMenu(equipment, warrior, (eq) {
            final e = widget.roster.equipment.firstWhere((w) => w.name == eq);
            context.read<WarbandModel>().getUID(warrior.uid).equipment.add(e);
            context.read<WarbandModel>().invalidate();
          }),
          const Spacer(),
          (warrior.type.max ?? double.infinity) > unitCount
              ? IconButton(
                  onPressed: () {
                    var wbm = context.read<WarbandModel>();
                    wbm.add(warrior.copyWith(
                        name: makeName(
                            widget.roster.namesM, widget.roster.surnames),
                        newUid: wbm.nextUID()));
                  },
                  icon: const Icon(Icons.copy),
                )
              : const SizedBox(),
          IconButton(
            onPressed: () {
              context.read<WarbandModel>().removeUID(warrior.uid);
            },
            icon: const Icon(Icons.delete),
          )
        ]),
      ]);
    } else {
      return UnmodifiableListView([]);
    }
  }

  DropdownMenu<String> itemDropDownMenu(Iterable<ItemUse> it,
      WarriorModel warrior, void Function(String) onSelected) {
    return DropdownMenu(
      dropdownMenuEntries: it
          .map<DropdownMenuEntry<String>>((ItemUse w) => DropdownMenuEntry(
              value: w.getName,
              label: w.getName,
              labelWidget: Text(w.getName),
              leadingIcon: CurrencyWidget(
                cost: w.getCost,
                simultaneous: false,
              )))
          .toList(),
      onSelected: (item) {
        if (item != null) onSelected(item);
      },
    );
  }

  Widget weaponLine(BuildContext context, WeaponUse w, WarriorModel warrior) {
    final def = getWeaponDef(w);
//    var ranged = rangedToString(def, warrior, "Ranged ");
//    var melee = meleeToString(def, warrior, "Melee ");
//    var injury = def.injury == null ? "" : " Injury ${def.injury ?? 0}";
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: CurrencyWidget(
            cost: w.cost,
            simultaneous: false,
          ),
        ),
        SizedBox(
          width: 240,
          child: Text(w.name),
        ),
        const Divider(),
        Text(def.getModifiersString),
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
        SizedBox(
          width: 40,
          child: CurrencyWidget(
            cost: a.cost,
            simultaneous: false,
          ),
        ),
        SizedBox(
          width: 240,
          child: Text(a.name),
        ),
        const Divider(),
        Row(
          children: [Text("Armour: ${def.value ?? 0}")],
        ),
        const Spacer(),
        _editMode && !a.isBuiltIn
            ? IconButton(
                onPressed: () {
                  warrior.armour.removeWhere((d) => a.name == d.name);
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
        SizedBox(
          width: 40,
          child: CurrencyWidget(
            cost: e.cost,
            simultaneous: false,
          ),
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

  Armour getArmorDef(ArmorUse w) =>
      widget.armory.armours.firstWhere((def) => def.name == w.name);

  Equipment getEquipmentDef(EquipmentUse w) =>
      widget.armory.equipments.firstWhere((def) => def.name == w.name);
}

class ItemChip extends StatelessWidget {
  const ItemChip({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(name),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class CurrencyWidget extends StatelessWidget {
  const CurrencyWidget(
      {super.key,
      required Currency cost,
      double? width,
      double? height,
      bool? simultaneous})
      : _cost = cost,
        _width = width ?? 60,
        _height = height ?? 60,
        _simultaneous = simultaneous ?? true;

  final double _width;
  final double _height;
  final Currency _cost;
  final bool _simultaneous;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: CircleAvatar(
        child: _simultaneous
            ? Stack(children: [
                _cost.glory > 0
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: gloryValue(20),
                      )
                    : const SizedBox(),
                _cost.ducats > 0
                    ? Center(
                        child: ducatsValue(28),
                      )
                    : const SizedBox(),
              ])
            : _cost.isDucats
                ? ducatsValue(20)
                : gloryValue(20),
      ),
    );
  }

  Widget ducatsValue(double size) {
    return Center(
      child: Text(
        "${_cost.ducats}",
        style: TextStyle(
          fontFamily: "CloisterBlack",
          fontWeight: FontWeight.w600,
          fontSize: size,
          color: const Color.fromARGB(255, 32, 31, 31),
        ),
      ),
    );
  }

  Widget gloryValue(double size) =>
      Stack(alignment: Alignment.center, children: [
        const Icon(
          Icons.star,
          size: 40,
          color: tcRed,
        ),
        Text(
          "${_cost.glory}",
          style: TextStyle(
            fontFamily: "CloisterBlack",
            fontWeight: FontWeight.w400,
            fontSize: size,
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
