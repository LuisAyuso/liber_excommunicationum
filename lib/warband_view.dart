import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';

import 'unit_selector.dart';

class WarriorModel {
  WarriorModel(
      {String? name,
      required this.uid,
      required this.type,
      required this.bucket})
      : name = name ?? "Generated";
  String name = "Generated name?";
  final int uid;
  final Unit type;
  List<Weapon> weapons = [];
  List<Armor> armor = [];
  List<Equipment> equipment = [];
  final int bucket;

  int get cost =>
      type.cost +
      weapons.fold<int>(0, (v, w) => w.cost + v) +
      armor.fold<int>(0, (v, w) => w.cost + v) +
      equipment.fold<int>(0, (v, w) => w.cost + v);
}

class WarbandModel extends ChangeNotifier {
  final List<WarriorModel> _items = [];
  int _id = 0;

  UnmodifiableListView<WarriorModel> get items => UnmodifiableListView(_items);
  int get length => _items.length;
  int get cost => _items.fold<int>(0, (v, w) => v + w.cost);

  void add(WarriorModel item) {
    _items.add(item);
    _items.sort((a, b) => a.bucket.compareTo(b.bucket));
    notifyListeners();
  }

  int nextUID() {
    return ++_id;
  }

  WarriorModel getUID(int uid) {
    return _items.firstWhere((w) => w.uid == uid);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class WarbandView extends StatelessWidget {
  const WarbandView({super.key, required this.title, required this.roster});
  final String title;
  final Roster roster;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${context.watch<WarbandModel>().cost} $title"),
      ),
      body: Center(
        child: ListView.separated(
            itemBuilder: (context, idx) {
              var warrior = context.read<WarbandModel>().items[idx];
              return warriorLine(context, warrior);
            },
            separatorBuilder: (context, idx) => const Divider(),
            itemCount: context.watch<WarbandModel>().length),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var value = context.read<WarbandModel>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                  value: value,
                  builder: (context, child) => UnitSelector(roster: roster)),
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget warriorLine(BuildContext context, WarriorModel warrior) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text("${warrior.cost}"),
          ),
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warrior.name,
                  style: const TextStyle(
                      fontFamily: "CloisterBlack",
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      color: Color.fromARGB(255, 167, 51, 30)),
                ),
                Text(
                  warrior.type.name,
                )
              ],
            ),
          ),
          const Divider(),
          Row(
            children: [
              statBox('${warrior.type.movement}"', 20),
              statBox(warrior.type.ranged, 20),
              statBox(warrior.type.melee, 20),
              statBox(warrior.type.armor, 20),
            ],
          )
        ],
      ),
      children: [
        Column(
          children: warrior.weapons.map<Widget>((w) => Text(w.name)).toList(),
        ),
        Row(
          children: [
            const SizedBox(
              width: 40,
            ),
            DropdownMenu(
              dropdownMenuEntries: roster.weapons
                  .map<DropdownMenuEntry<String>>((Weapon w) =>
                      DropdownMenuEntry(value: w.name, label: w.name))
                  .toList(),
              onSelected: (weapon) {
                var w = roster.weapons.firstWhere((w) => w.name == weapon);
                context.read<WarbandModel>().getUID(warrior.uid).weapons.add(w);
              },
            )
          ],
        ),
      ],
    );
  }
}

Widget statBox<T>(T stat, double size) {
  return SizedBox(
    width: 24,
    child: Text(
      textAlign: TextAlign.end,
      "$stat",
      style: TextStyle(fontSize: size),
    ),
  );
}
