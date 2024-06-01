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
                  separatorBuilder: (context, idx) => const SizedBox(),
                  itemCount: roster.items.length,
                ),
              ],
            )),
      ),
    );
  }
}