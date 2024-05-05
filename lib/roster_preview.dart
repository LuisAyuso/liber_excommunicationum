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
          title: const Text("Choose an Unit"),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
              itemBuilder: (context, idx) => entry(idx),
              separatorBuilder: (context, idx) => const Divider(),
              itemCount: roster.units.length + roster.items.length),
        ),
      ),
    );
  }

  Widget entry(int idx) {
    if (idx < roster.units.length) {
      return unitDescription(idx);
    } else {
      return itemDescription(idx - roster.units.length);
    }
  }

  Widget itemDescription(int idx) {
    final item = roster.items[idx];
    return Row(
      children: [
        Text("${item.getCost.ducats}"),
        const Divider(),
        Text(item.getName),
      ],
    );
  }

  Widget unitDescription(int idx) {
    final unit = roster.units[idx];

    final ranged = bonus(unit.ranged);
    final melee = bonus(unit.melee);
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                width: 40,
                child: Center(
                    child: unit.max != 0
                        ? Text(
                            "${unit.max}",
                            style: gothRed24,
                          )
                        : const SizedBox())),
            Text(
              unit.name,
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
                    Text("Armor", style: gothBlack20),
                    Text("Base", style: gothBlack20),
                  ],
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: tcRed)))),
              TableRow(children: [
                Text("${unit.cost.ducats}"),
                Text("${unit.movement}"),
                Text(ranged),
                Text(melee),
                Text("${unit.armor}"),
                Text("${unit.base}"),
              ]),
            ],
          ),
        ),
        Row(
          children: (unit.builtInItems ?? [])
              .map((elem) => ItemChip(name: elem))
              .toList(),
        ),
        Row(
          children: unit.keywords.map((elem) => ItemChip(name: elem)).toList(),
        )
      ],
    );
  }
}
