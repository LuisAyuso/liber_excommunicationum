import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';
import 'package:tc_thing/roster_preview.dart';
import 'package:tc_thing/utils.dart';

import 'unit_selector.dart';

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
    final unitCount = context
        .read<WarbandModel>()
        .items
        .where((other) => other.type.typeName == warrior.type.typeName)
        .length;

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
                warrior.type.typeName,
              )
            ],
          ),
        ),
        const VerticalDivider(),
        Row(
          children: [
            statBox("Mov:", '${warrior.type.movement}"'),
            statBox("Armour:", warrior.computeArmorValue(widget.armory)),
          ],
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(
            children: warrior.weapons
                .map<Widget>((w) => ItemChip(text: w.typeName))
                .toList(),
          ),
          Row(
            children: warrior.armour
                    .map<Widget>((w) => ItemChip(text: w.typeName))
                    .toList() +
                warrior.equipment
                    .map<Widget>((w) => ItemChip(text: w.typeName))
                    .toList(),
          ),
        ]),
      ]),
      childrenPadding: const EdgeInsets.all(16),
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
              editControls(
                  warrior,
                  warrior.availableWeapons(widget.roster, widget.armory),
                  warrior.availableArmours(widget.roster, widget.armory),
                  warrior.availableEquipment(widget.roster, widget.armory),
                  unitCount),
        ),
      ],
    );
  }

  UnmodifiableListView<Widget> editControls(
    WarriorModel warrior,
    Iterable<WeaponUse> availableWeapons,
    Iterable<ArmorUse> availableArmours,
    Iterable<EquipmentUse> availableEquipment,
    int unitCount,
  ) {
    if (_editMode) {
      return UnmodifiableListView([
        Row(children: [
          TextButton(
            onPressed: availableWeapons.isEmpty
                ? null
                : () {
                    var wb = context.read<WarbandModel>();
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return ItemChooser(
                              elements: availableWeapons.toList(),
                              armory: widget.armory,
                              callback: (eq) {
                                final e = widget.roster.weapons
                                    .firstWhere((w) => w.typeName == eq);
                                wb.getUID(warrior.uid).weapons.add(e);
                                wb.invalidate();
                                Navigator.pop(context);
                              });
                        });
                  },
            child: const Text("+Weapon"),
          ),
          TextButton(
            onPressed: availableArmours.isEmpty
                ? null
                : () {
                    var wb = context.read<WarbandModel>();
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return ItemChooser(
                              elements: availableArmours.toList(),
                              armory: widget.armory,
                              callback: (eq) {
                                final e = widget.roster.armour
                                    .firstWhere((w) => w.typeName == eq);
                                wb.getUID(warrior.uid).armour.add(e);
                                wb.invalidate();
                                Navigator.pop(context);
                              });
                        });
                  },
            child: const Text("+Armour"),
          ),
          TextButton(
            onPressed: availableEquipment.isEmpty
                ? null
                : () {
                    var wb = context.read<WarbandModel>();
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return ItemChooser(
                              elements: availableEquipment.toList(),
                              armory: widget.armory,
                              callback: (eq) {
                                final e = widget.roster.equipment
                                    .firstWhere((w) => w.typeName == eq);
                                wb.getUID(warrior.uid).equipment.add(e);
                                wb.invalidate();
                                Navigator.pop(context);
                              });
                        });
                  },
            child: const Text("+Equipment"),
          ),
        ]),
        Row(children: [
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

  Widget weaponLine(
    BuildContext context,
    WeaponUse weapon,
    WarriorModel warrior,
  ) {
    final def = widget.armory.findWeapon(weapon);
    final defaultItem = (warrior.type.defaultItems ?? [])
        .where((eq) => eq.itemName == weapon.typeName)
        .firstOrNull;
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: CurrencyWidget(
            cost: weapon.cost,
            simultaneous: false,
          ),
        ),
        SizedBox(width: 240, child: Text(weapon.typeName)),
        const Spacer(),
        Text(def.getModifiersString),
        defaultItem != null && defaultItem.replacements != null
            ? replaceWeapon(context, warrior, weapon, defaultItem)
            : const SizedBox(),
        _editMode && weapon.isRemovable
            ? IconButton(
                onPressed: () {
                  warrior.weapons
                      .removeWhere((d) => weapon.typeName == d.typeName);
                  context.read<WarbandModel>().invalidate();
                },
                icon: const Icon(Icons.delete))
            : const SizedBox()
      ],
    );
  }

  TextButton replaceWeapon(
    BuildContext context,
    WarriorModel warrior,
    WeaponUse weapon,
    DefaultItem replaceableItem,
  ) {
    return TextButton(
      onPressed: () {
        var wb = context.read<WarbandModel>();
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              final alterEgo = warrior.copyWith(name: "", newUid: -1);
              alterEgo.weapons
                  .removeWhere((d) => weapon.typeName == d.typeName);
              final replacements = alterEgo
                  .availableWeapons(
                widget.roster,
                widget.armory,
              )
                  .where((item) {
                if (item.getName == weapon.getName) return false;
                if (!replaceableItem.replacements!.isAllowed(item.getName)) {
                  return false;
                }
                final defA = widget.armory.findWeapon(weapon);
                final defB = widget.armory.findWeapon(item);
                return defA.canRanged == defB.canRanged;
              }).map((item) {
                item.cost = weapon.cost.offset(item.cost);
                return item;
              }).toList();
              return ItemChooser(
                  elements: replacements,
                  armory: widget.armory,
                  callback: (eq) {
                    warrior.weapons
                        .removeWhere((d) => weapon.typeName == d.typeName);
                    final e = widget.roster.weapons
                        .firstWhere((w) => w.typeName == eq);
                    warrior.weapons.add(e);
                    wb.invalidate();

                    Navigator.pop(context);
                  });
            });
      },
      child: const Text("Replace"),
    );
  }

  Widget armorLine(BuildContext context, ArmorUse a, WarriorModel warrior) {
    final def = widget.armory.findArmour(a);
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: CurrencyWidget(
            cost: a.cost,
            simultaneous: false,
          ),
        ),
        SizedBox(width: 240, child: Text(a.typeName)),
        const Divider(),
        Row(
          children: [Text("Armour: ${def.value ?? 0}")],
        ),
        const Spacer(),
        _editMode && a.isRemovable
            ? IconButton(
                onPressed: () {
                  warrior.armour.removeWhere((d) => a.typeName == d.typeName);
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
        SizedBox(width: 240, child: Text(e.typeName)),
        const Spacer(),
        _editMode && e.isRemovable
            ? IconButton(
                onPressed: () {
                  warrior.equipment
                      .removeWhere((d) => e.typeName == d.typeName);
                  context.read<WarbandModel>().invalidate();
                },
                icon: const Icon(Icons.delete))
            : const SizedBox()
      ],
    );
  }
}

class ItemChooser extends StatelessWidget {
  const ItemChooser({
    super.key,
    required this.callback,
    required this.elements,
    required this.armory,
    this.priceOffset = const Currency(),
  });
  final void Function(String) callback;
  final List<dynamic> elements;
  final Armory armory;
  final Currency priceOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ListView.separated(
            itemBuilder: (ctx, idx) => InkWell(
              onTap: () => callback(elements[idx].typeName),
              child: ItemDescription(
                item: elements[idx],
                armory: armory,
              ),
            ),
            separatorBuilder: (ctx, idx) => const Divider(),
            itemCount: elements.length,
          ),
        ),
      ),
    );
  }
}

class ItemChip extends StatelessWidget {
  const ItemChip({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
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
