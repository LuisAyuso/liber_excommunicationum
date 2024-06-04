import 'package:flutter/material.dart';

import 'controls/item_description.dart';
import 'model/model.dart';
import 'controls/content_lex.dart';
import 'controls/unit_description.dart';

class RosterPreview extends StatelessWidget {
  const RosterPreview({super.key, required this.roster, required this.armory});
  final Roster roster;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    final items = roster.allAvailableItems(armory).toList();

    return ContentLex(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(
                "Roster Preview",
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Units"),
                  Tab(text: "Weapons, Armours,\n & Equipment"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    itemBuilder: (context, idx) => UnitDescription(
                      unit: roster.units[idx],
                      armory: armory,
                    ),
                    separatorBuilder: (context, idx) => const Divider(),
                    itemCount: roster.units.length,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    itemBuilder: (context, idx) => ItemDescription(
                      use: items[idx].use,
                      item: items[idx].def,
                    ),
                    separatorBuilder: (context, idx) => const SizedBox(),
                    itemCount: items.length,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
