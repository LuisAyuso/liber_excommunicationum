import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';
import 'package:tc_thing/roster_preview.dart';
import 'package:tc_thing/utils.dart';

class UnitSelector extends StatelessWidget {
  const UnitSelector({super.key, required this.roster, required this.armory});
  final Roster roster;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    return MyContent(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            "Choose an Unit",
            style: gothBlack24,
          ),
        ),
        body: Center(
          child: ListView.separated(
              itemBuilder: (context, idx) =>
                  makeUnitEntry(context, roster.units[idx], roster, idx),
              separatorBuilder: (context, idx) => const Divider(),
              itemCount: roster.units.length),
        ),
      ),
    );
  }

  Widget makeUnitEntry(
      BuildContext context, Unit unit, Roster roster, int idx) {
    return Builder(builder: (context) {
      final currentList = context.watch<WarbandModel>();
      int count = 0;
      for (var element in currentList.items) {
        if (element.type.typeName == unit.typeName) {
          count++;
        }
      }
      final bool enabled = (unit.max == null || count < unit.max!);

      return InkWell(
        onTap: enabled
            ? () {
                var wb = context.read<WarbandModel>();
                wb.add(WarriorModel(
                    name: makeName(roster, unit.sex, unit.isElite),
                    uid: wb.nextUID(),
                    type: unit,
                    bucket: idx,
                    armory: armory));
                Navigator.pop(context);
              }
            : null,
        child: UnitDescription(unit: unit),
      );
    });
  }
}
