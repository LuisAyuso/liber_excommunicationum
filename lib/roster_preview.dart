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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(
                "Roster Preview",
                style: gothBlack24,
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    text: "Units",
                  ),
                  Tab(text: "Weapons, Armours,\n & Equipment"),
                ],
                labelStyle: gothBlack20,
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              child: TabBarView(
                children: [
                  ListView.separated(
                    itemBuilder: (context, idx) => UnitDescription(
                      unit: roster.units[idx],
                      armory: armory,
                    ),
                    separatorBuilder: (context, idx) => const Divider(),
                    itemCount: roster.units.length,
                  ),
                  ListView.separated(
                    itemBuilder: (context, idx) => ItemDescription(
                      item: roster.items[idx],
                      armory: armory,
                    ),
                    separatorBuilder: (context, idx) => const Divider(),
                    itemCount: roster.items.length,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class ItemDescription extends StatelessWidget {
  const ItemDescription({
    super.key,
    required this.item,
    required this.armory,
  });
  final ItemUse item;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    if (item is WeaponUse) return weaponDescription(item as WeaponUse);
    if (item is ArmourUse) return armorDescription(item as ArmourUse);
    if (item is EquipmentUse) return equipmentDescription(item as EquipmentUse);
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
                      .map((kw) => ItemChip(item: kw))
                      .toList(),
                )
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget armorDescription(ArmourUse item) {
    final def = armory.findArmour(item);
    return def.isBodyArmour
        ? bodyArmorDescription(item)
        : otherArmourDescription(item);
  }

  Widget otherArmourDescription(ArmourUse item) {
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

  Widget bodyArmorDescription(ArmourUse item) {
    final def = armory.findArmour(item);
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
                    Text("Armour", style: gothBlack20),
                  ],
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: tcRed)))),
              TableRow(children: [
                Text("${item.cost}"),
                Text("${def.value}"),
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
  const UnitDescription({super.key, required this.unit, required this.armory});
  final Unit unit;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    final ranged = bonus(unit.ranged);
    final melee = bonus(unit.melee);

    final effectiveArmour = unit.defaultItems?.fold(unit.armour, (v, item) {
          if (!armory.isArmour(item.itemName)) return v;
          final def = armory.findArmour(item.itemName);
          return v + (def.value ?? 0);
        }) ??
        unit.armour;
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
                Text("${unit.completeCost}"),
                Text("${unit.movement}"),
                Text(ranged),
                Text(melee),
                Text("$effectiveArmour"),
                Text(unit.base),
              ]),
            ],
          ),
        ),
        Row(
          children: (unit.defaultItems ?? [])
              .map((elem) => ItemChip(item: elem.itemName))
              .toList(),
        ),
        Row(
          children: unit.keywords.map((elem) => ItemChip(item: elem)).toList(),
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
