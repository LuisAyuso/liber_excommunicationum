import 'package:flutter/material.dart';
import 'package:tc_thing/controls/item_chip.dart';
import 'package:tc_thing/controls/table_lex.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/utils/utils.dart';

class ItemDescription extends StatelessWidget {
  const ItemDescription({
    super.key,
    required this.item,
    required this.armory,
    this.edit,
  });
  final ItemUse item;
  final Armory armory;
  final Widget? edit;

  @override
  Widget build(BuildContext context) {
    if (item is WeaponUse) return weaponDescription(context, item as WeaponUse);
    if (item is ArmourUse) return armorDescription(context, item as ArmourUse);
    if (item is EquipmentUse) {
      return equipmentDescription(context, item as EquipmentUse);
    }
    assert(false, "unreachable");
    return const SizedBox();
  }

  Widget weaponDescription(BuildContext context, WeaponUse weapon) {
    final def = armory.findWeapon(weapon.typeName);
    var list = List<
        ({
          String cost,
          String type,
          String range,
          String modifiers
        })>.empty(growable: true);
    if (def.canRanged) {
      list.add((
        cost: weapon.cost.toString(),
        type: def.isGrenade ? "Grenades" : "${def.hands}-handed",
        range: '${def.range}"',
        modifiers: def.getModifiersString(Modifier(), ModifierType.ranged)
      ));
    }
    if (def.canMelee) {
      list.add((
        cost: def.canRanged ? "" : weapon.cost.toString(),
        type: "",
        range: 'Melee',
        modifiers: def.getModifiersString(Modifier(), ModifierType.melee)
      ));
    }
    assert(list.isNotEmpty);
    var headers = const ["Cost", "Type", "Range", "Modifiers"];
    var rows = list
        .map<List<Widget>>((entry) => [
              Text(entry.cost),
              Text(entry.type),
              Text(entry.range),
              Text(entry.modifiers),
            ])
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              weapon.typeName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: tcRed),
            ),
            const Spacer(),
            edit ?? const SizedBox(),
          ],
        ),
        TableLEX(headers: headers, rows: rows),
        Wrap(children: def.getKeywords.map((s) => ItemChip(item: s)).toList())
      ],
    );
  }

  Widget armorDescription(BuildContext context, ArmourUse item) {
    final def = armory.findArmour(item);
    return def.isBodyArmour
        ? bodyArmorDescription(context, item)
        : otherArmourDescription(context, item);
  }

  Widget otherArmourDescription(BuildContext context, ArmourUse item) {
    var headers = const [
      "Cost",
    ];
    var rows = [
      <Widget>[Text("${item.cost}")].toList(growable: true)
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              item.typeName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: tcRed),
            ),
            const Spacer(),
            edit ?? const SizedBox(),
          ],
        ),
        TableLEX(
          headers: headers,
          rows: rows,
        ),
      ],
    );
  }

  Widget bodyArmorDescription(BuildContext context, ArmourUse item) {
    final def = armory.findArmour(item);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              item.typeName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: tcRed),
            ),
            const Spacer(),
            edit ?? const SizedBox(),
          ],
        ),
        TableLEX(
          headers: const ["Cost", "Armour"],
          rows: [
            [
              Text("${item.cost}"),
              Text("${def.value}"),
            ]
          ],
        ),
        Wrap(children: def.getKeywords.map((s) => ItemChip(item: s)).toList())
      ],
    );
  }

  Widget equipmentDescription(BuildContext context, EquipmentUse item) {
    final def = armory.findEquipment(item);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              item.typeName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: tcRed),
            ),
            const Spacer(),
            edit ?? const SizedBox(),
          ],
        ),
        TableLEX(
          headers: const [
            "Cost",
          ],
          rows: [
            [
              Text("${item.cost}"),
            ]
          ],
        ),
        Wrap(children: def.getKeywords.map((s) => ItemChip(item: s)).toList())
      ],
    );
  }
}