import 'package:flutter/material.dart';
import 'package:tc_thing/utils.dart';
import 'package:tc_thing/warband_view.dart';

import 'model/model.dart';

class RosterPreview extends StatelessWidget {
  const RosterPreview({super.key, required this.roster, required this.armory});
  final Roster roster;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    return MyContent(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Roster Preview"),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
              itemBuilder: (context, idx) => entry(idx),
              separatorBuilder: (context, idx) => makeDivider(idx),
              itemCount: roster.units.length + roster.items.length),
        ),
      ),
    );
  }

  Widget makeDivider(int idx) {
    if (idx == roster.units.length - 1) {
      return const Column(children: [
        Divider(),
        Text(
          "Weapons, Armour\n & Equipment",
          style: gothBlackBig,
        ),
      ]);
    }

    return const Divider();
  }

  Widget entry(int idx) {
    if (idx < roster.units.length) {
      return UnitDescription(unit: roster.units[idx]);
    } else {
      return ItemDescription(
        item: roster.items[idx - roster.units.length],
        armory: armory,
      );
    }
  }
}

class ItemDescription extends StatelessWidget {
  const ItemDescription({
    super.key,
    required this.item,
    required this.armory,
  });
  final dynamic item;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    if (item is WeaponUse) return weaponDescription(item);
    if (item is ArmorUse) return armorDescription(item);
    if (item is EquipmentUse) return equipmentDescription(item);
    assert(false, "unreachable");
    return const SizedBox();
  }

  Widget weaponDescription(WeaponUse weapon) {
    final def = armory.findWeapon(weapon.typeName);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 40),
            Text(
              weapon.typeName,
              style: gothRed24,
            )
          ],
        ),
        Center(
          child: Table(
            children: [
              const TableRow(
                  children: [
                    Text("Cost", style: gothBlack20),
                    Text("Type", style: gothBlack20),
                    Text("Range", style: gothBlack20),
                    Text("Modifiers", style: gothBlack20),
                    Text("Keywords", style: gothBlack20),
                  ],
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: tcRed)))),
              TableRow(children: [
                Text("${weapon.cost}"),
                def.isGrenade
                    ? const Text("Grenades")
                    : Text("${def.hands}-handed"),
                Column(
                  children: [
                    def.canRanged ? Text('${def.range}"') : const SizedBox(),
                    def.canMelee ? const Text("Melee") : const SizedBox(),
                  ],
                ),
                Text(def.getModifiersString(Modifier(), ModifierType.any)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (def.keywords ?? [])
                      .map((kw) => ItemChip(text: kw))
                      .toList(),
                )
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget armorDescription(ArmorUse item) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 40),
            Text(
              item.typeName,
              style: gothRed24,
            )
          ],
        ),
        Center(
          child: Table(
            children: [
              const TableRow(
                  children: [
                    Text("Cost", style: gothBlack20),
                  ],
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: tcRed)))),
              TableRow(children: [
                Text("${item.cost}"),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget equipmentDescription(EquipmentUse item) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 40),
            Text(
              item.typeName,
              style: gothRed24,
            )
          ],
        ),
        Center(
          child: Table(
            children: [
              const TableRow(
                  children: [
                    Text("Cost", style: gothBlack20),
                  ],
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: tcRed)))),
              TableRow(children: [
                Text("${item.cost}"),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class UnitDescription extends StatelessWidget {
  const UnitDescription({super.key, required this.unit});
  final Unit unit;

  @override
  Widget build(BuildContext context) {
    final ranged = bonus(unit.ranged);
    final melee = bonus(unit.melee);
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 40, child: Center(child: unitCount(unit))),
            Text(
              unit.typeName,
              style: gothRed24,
            )
          ],
        ),
        Center(
          child: Table(
            children: [
              const TableRow(
                  children: [
                    Text("Cost", style: gothBlack20),
                    Text("Movement", style: gothBlack20),
                    Text("Ranged", style: gothBlack20),
                    Text("Melee", style: gothBlack20),
                    Text("Armour", style: gothBlack20),
                    Text("Base", style: gothBlack20),
                  ],
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: tcRed)))),
              TableRow(children: [
                Text("${unit.cost}"),
                Text("${unit.movement}"),
                Text(ranged),
                Text(melee),
                Text("${unit.armour}"),
                Text(unit.base),
              ]),
            ],
          ),
        ),
        Row(
          children: (unit.defaultItems ?? [])
              .map((elem) => ItemChip(text: elem.itemName))
              .toList(),
        ),
        Row(
          children: unit.keywords.map((elem) => ItemChip(text: elem)).toList(),
        )
      ],
    );
  }

  Widget unitCount(Unit unit) {
    if (unit.max == null) return const SizedBox();

    final min = unit.min ?? 0;
    final max = unit.max!;

    if (min == max) return Text("$max", style: gothRed24);
    return Text("$min-$max", style: gothRed24);
  }
}
