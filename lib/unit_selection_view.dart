import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/filters.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';
import 'package:tc_thing/utils/name_generator.dart';

import 'controls/content_lex.dart';
import 'controls/unit_description.dart';

Map<String, int> makeBuckets(Roster roster) {
  var res = <String, int>{};
  for (var i = 0; i < roster.units.length; i++) {
    res[roster.units[i].typeName] = i;
  }
  return res;
}

class UnitSelector extends StatefulWidget {
  UnitSelector({super.key, required this.roster, required this.armory})
      : buckets = makeBuckets(roster);

  final Roster roster;
  final Armory armory;
  final Map<String, int> buckets;

  @override
  State<UnitSelector> createState() => _UnitSelectorState();
}

UnitFilter onlyElites = UnitFilter.elites();
UnitFilter onlyTroops = UnitFilter.troops();

UnitFilter makeUnitFilter(Unit unit, [UnitFilter? extra]) {
  return UnitFilter.allOf([unit.effectiveUnitFilter, extra].nonNulls);
}

class _UnitSelectorState extends State<UnitSelector> {
  late UnmodifiableListView<Unit> units;
  late UnmodifiableListView<(Unit, String)> filteredOut;

  @override
  Widget build(BuildContext context) {
    final warband = context.read<WarbandModel>();
    final elites = UnmodifiableListView(widget.roster.units.where((unit) =>
        makeUnitFilter(unit, onlyElites)
            .isUnitAllowed(unit, warband.warriors))).toList();
    final troops = UnmodifiableListView(widget.roster.units.where((unit) =>
        makeUnitFilter(unit, onlyTroops)
            .isUnitAllowed(unit, warband.warriors))).toList();

    return ContentLex(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(
                "Choose an Unit",
              ),
              bottom: TabBar(
                tabs: [
                  Tab(text: widget.roster.elites),
                  Tab(text: widget.roster.troop),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ListView.separated(
                    itemBuilder: (context, idx) => makeUnitEntry(
                          context,
                          elites[idx],
                          widget.buckets[elites[idx].typeName]!,
                        ),
                    separatorBuilder: (context, idx) => const Divider(),
                    itemCount: elites.length),
                ListView.separated(
                    itemBuilder: (context, idx) => makeUnitEntry(
                          context,
                          troops[idx],
                          widget.buckets[troops[idx].typeName]!,
                        ),
                    separatorBuilder: (context, idx) => const Divider(),
                    itemCount: troops.length),
              ],
            )),
      ),
    );
  }

  Widget makeUnitEntry(
    BuildContext context,
    Unit unit,
    int bucket,
  ) {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () {
          var wb = context.read<WarbandModel>();
          final newWarrior = WarriorModel(
            name: generateName(unit.sex, unit.keywords),
            uid: wb.nextUID(),
            type: unit,
            bucket: bucket,
          );
          newWarrior.populateBuiltIn(widget.roster, widget.armory);
          wb.add(newWarrior);
          Navigator.pop(context);
        },
        child: UnitDescription(
          unit: unit,
          armory: widget.armory,
        ),
      );
    });
  }
}
