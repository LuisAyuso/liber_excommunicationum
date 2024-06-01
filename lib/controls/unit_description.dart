import 'package:flutter/material.dart';
import 'package:tc_thing/controls/item_chip.dart';
import 'package:tc_thing/controls/table_lex.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/utils/utils.dart';

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

    String countStr = "";
    if (unit.min != null && unit.max != null && unit.min == unit.max) {
      countStr = "${unit.min!} ";
    } else if (unit.min != null && unit.max == null) {
      countStr = "${unit.min!} ";
    } else if (unit.max != null) {
      countStr = "${unit.min ?? 0}-${unit.max!} ";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "$countStr${unit.typeName}",
            style:
                Theme.of(context).textTheme.titleMedium!.copyWith(color: tcRed),
          ),
        ),
        TableLEX(
          headers: const [
            "Cost",
            "Movement",
            "Ranged",
            "Melee",
            "Armour",
            "Base"
          ],
          rows: [
            [
              Text("${unit.cost}"),
              Text(unit.movement),
              Text(ranged),
              Text(melee),
              Text("$effectiveArmour"),
              Text(unit.base),
            ]
          ],
        ),
        Wrap(
            children: (unit.defaultItems ?? [])
                .map((elem) => ItemChip(item: elem.itemName))
                .toList()),
        Wrap(children: unit.keywords.map((s) => ItemChip(item: s)).toList())
      ],
    );
  }
}
