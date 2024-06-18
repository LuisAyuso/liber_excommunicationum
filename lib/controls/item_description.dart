import 'package:flutter/material.dart';
import 'package:tc_thing/controls/item_chip.dart';
import 'package:tc_thing/controls/table_lex.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/utils/utils.dart';

class ItemDescription extends StatelessWidget {
  const ItemDescription({
    super.key,
    required this.use,
    required this.item,
    this.edit,
  });
  final ItemUse use;
  final dynamic item;
  final Widget? edit;

  @override
  Widget build(BuildContext context) {
    if (item is Weapon) return weaponDescription(context, use, item as Weapon);
    if (item is Armour) return armorDescription(context, use, item as Armour);
    if (item is Equipment) {
      return equipmentDescription(context, use, item as Equipment);
    }
    assert(false, "unreachable");
    return const SizedBox();
  }

  Widget weaponDescription(BuildContext context, ItemUse use, Weapon weapon) {
    var list = List<
        ({
          String cost,
          String type,
          String range,
          String modifiers
        })>.empty(growable: true);
    if (weapon.canRanged) {
      list.add((
        cost: use.cost.toString(),
        type: weapon.isGrenade ? "Grenades" : "${weapon.hands}-handed",
        range: '${weapon.range}"',
        modifiers: weapon.getModifiersString(Modifier(), ModifierType.ranged)
      ));
    }
    if (weapon.canMelee) {
      list.add((
        cost: weapon.canRanged ? "" : use.cost.toString(),
        type: "",
        range: 'Melee',
        modifiers: weapon.getModifiersString(Modifier(), ModifierType.melee)
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
        Wrap(
            children: weapon.getKeywords.map((s) => ItemChip(item: s)).toList())
      ],
    );
  }

  Widget armorDescription(BuildContext context, ItemUse use, Armour armour) {
    return armour.isBodyArmour
        ? bodyArmorDescription(context, use, item)
        : otherArmourDescription(context, use, item);
  }

  Widget otherArmourDescription(
      BuildContext context, ItemUse use, Armour armour) {
    var headers = const [
      "Cost",
    ];
    var rows = [
      <Widget>[Text("${use.cost}")].toList(growable: true)
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              armour.typeName,
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

  Widget bodyArmorDescription(
      BuildContext context, ItemUse use, Armour armour) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              armour.typeName,
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
              Text("${use.cost}"),
              Text("${armour.value}"),
            ]
          ],
        ),
        Wrap(
            children: armour.getKeywords.map((s) => ItemChip(item: s)).toList())
      ],
    );
  }

  Widget equipmentDescription(
      BuildContext context, ItemUse use, Equipment equipment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              use.typeName,
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
              Text("${use.cost}"),
            ]
          ],
        ),
        equipment.rules == null
            ? const SizedBox()
            : RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'rules: ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: equipment.rules,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
        Wrap(
            children:
                equipment.getKeywords.map((s) => ItemChip(item: s)).toList())
      ],
    );
  }
}
