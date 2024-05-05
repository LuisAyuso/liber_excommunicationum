import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/warband_view.dart';

String makeName(List<String> names, List<String> surnames) {
  final random = Random();
  final name = names[random.nextInt(names.length)];
  final surname = surnames[random.nextInt(surnames.length)];
  return "$name $surname";
}

class UnitSelector extends StatelessWidget {
  const UnitSelector({super.key, required this.roster, required this.armory});
  final Roster roster;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.separated(
            itemBuilder: (context, idx) =>
                makeUnitEntry(context, roster.units[idx], roster, idx),
            separatorBuilder: (context, idx) => const Divider(),
            itemCount: roster.units.length),
      ),
    );
  }

  Widget makeUnitEntry(BuildContext context, Unit unit, Roster r, int idx) {
    return Builder(builder: (context) {
      final currentList = context.watch<WarbandModel>();
      int count = 0;
      for (var element in currentList.items) {
        if (element.type.name == unit.name) {
          count++;
        }
      }
      final bool enabled = (unit.max == 0 || count < unit.max);

      return InkWell(
        child: ListTile(
          leading: CircleAvatar(
            child: CostWidget(cost: unit.cost),
          ),
          title: Text(unit.name),
          subtitle: Text(unit.name),
          trailing: unit.max == 0
              ? const Icon(Icons.all_inclusive)
              : Text("$count-${unit.max}"),
        ),
        onTap: () {
          if (enabled) {
            var wb = context.read<WarbandModel>();
            wb.add(WarriorModel(
                name: makeName(r.namesM, r.surnames),
                uid: wb.nextUID(),
                type: unit,
                bucket: idx,
                armory: armory));
            Navigator.pop(context);
          }
        },
      );
    });
  }
}
