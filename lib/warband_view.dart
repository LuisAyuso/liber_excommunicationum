import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';

import 'unit_selector.dart';

class WarriorModel {
  WarriorModel(
      {String? name,
      required this.uid,
      required this.type,
      required this.bucket})
      : name = name ?? "Generated";
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

  int get cost => baseCost + equipmentCost;
  int get baseCost => type.cost;
  int get equipmentCost =>
      weapons.fold<int>(0, (v, w) => w.cost + v) +
      armor.fold<int>(0, (v, w) => w.cost + v) +
      equipment.fold<int>(0, (v, w) => w.cost + v);

  int getArmorValue(Armory armory) {
    return type.armor +
        armor
            .map((a) => armory.armors.firstWhere((e) => e.name == a.name))
            .map((a) => a.value ?? 0)
            .fold(0, (a, b) => a + b);
  }
}

class WarbandModel extends ChangeNotifier {
  final List<WarriorModel> _items = [];
  int _id = 0;

  UnmodifiableListView<WarriorModel> get items => UnmodifiableListView(_items);
  int get length => _items.length;
  int get cost => _items.fold<int>(0, (v, w) => v + w.cost);

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(children: [
          Text("${context.watch<WarbandModel>().cost} ${widget.title}"),
          const Spacer(),
          Switch(value: _editMode, onChanged: (v) => edit = v)
        ]),
      ),
      body: Center(
        child: ListView.separated(
            itemBuilder: (context, idx) {
              var warrior = context.read<WarbandModel>().items[idx];
              return warriorLine(context, warrior);
            },
            separatorBuilder: (context, idx) => const Divider(),
            itemCount: context.watch<WarbandModel>().length),
      ),
      floatingActionButton: _editMode
          ? FloatingActionButton(
              onPressed: () {
                var value = context.read<WarbandModel>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                        value: value,
                        builder: (context, child) =>
                            UnitSelector(roster: widget.roster)),
                  ),
                );
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : null,
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
      for (var keyword in warrior.type.keywords) {
        if (weapon.keywordFilter.where((kw) => kw == keyword).isNotEmpty) {
          return false;
        }
      }

      final def = getWeaponDef(weapon);
      if (def.isPistol && allowPistol) return true;
      if (def.isFirearm && firearms < 1) return true;
      if (def.isMeleeWeapon && allowMelee) {
        return freeHands >= def.hands;
      }

      return false;
    });

    final bodyArmour = armours.where((a) => a.isArmour).isNotEmpty;
    final shield = armours.where((a) => a.isShield).isNotEmpty;

    final availableArmors = widget.roster.armor.where((armour) {
      final def = getArmorDef(armour);
      if (def.isArmour && bodyArmour) return false;
      if (def.isShield && shield) return false;

      return true;
    });

    final availableEquipment = widget.roster.equipment.where((e) {
      debugPrint(e.name);
      final eq = getEquipmentDef(e);
      if (!eq.isConsumable &&
          warrior.equipment.where((e) => e.name == eq.name).isNotEmpty) {
        return false;
      }

      return true;
    });

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(children: [
        SizedBox(
          width: 40,
          child: Text("${warrior.cost}"),
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
                    dropdownMenuEntries: availableArmors
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
        _editMode
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
        _editMode
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
        _editMode
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
      widget.armory.armors.firstWhere((def) => def.name == w.name);

  Equipment getEquipmentDef(EquipmentUse w) =>
      widget.armory.equipments.firstWhere((def) => def.name == w.name);
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
