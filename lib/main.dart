import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:collection';

import 'package:tc_thing/model/model.dart';

class WarriorModel {
  WarriorModel({String? name, required this.type}) : name = name ?? "Generated";
  String name = "Generated name?";
  Unit type = Unit();
  List<Weapon> weapons = [];
  List<Armor> armor = [];
  List<Equipment> equipment = [];

  int get cost =>
      type.cost +
      weapons.fold<int>(0, (v, w) => w.cost + v) +
      armor.fold<int>(0, (v, w) => w.cost + v) +
      equipment.fold<int>(0, (v, w) => w.cost + v);
}

class WarbandModel extends ChangeNotifier {
  final List<WarriorModel> _items = [];

  UnmodifiableListView<WarriorModel> get items => UnmodifiableListView(_items);
  int get length => _items.length;

  void add(WarriorModel item) {
    _items.add(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class UnitSelector extends StatelessWidget {
  const UnitSelector({super.key});

  Future<Roster> loadRoster(context) async {
    var data = await DefaultAssetBundle.of(context)
        .loadString("assets/lists/cult.json");
    var d = jsonDecode(data);
    return Roster.fromJson(d);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder(
          future: loadRoster(context),
          builder: (context, roster) {
            if (roster.hasError) {
              return const Text("Failed to load roster");
            }
            if (!roster.hasData) {
              return const CircularProgressIndicator();
            }

            final r = roster.data!;
            return ListView.separated(
                itemBuilder: (context, idx) =>
                    makeUnitEntry(context, r.units[idx], r),
                separatorBuilder: (context, idx) => const Divider(),
                itemCount: r.units.length);
          },
        ),
      ),
    );
  }

  String makeName(List<String> names, List<String> surnames) {
    final random = Random();
    final name = names[random.nextInt(names.length)];
    final surname = surnames[random.nextInt(surnames.length)];
    return "$name $surname";
  }

  Widget makeUnitEntry(BuildContext context, Unit unit, Roster r) {
    var prefix = unit.name
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .join('');
    if (prefix.length > 3) prefix = prefix.substring(0, 2);

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
            child: Text(prefix),
          ),
          title: Text(unit.name),
          subtitle: Text(unit.name),
          trailing: unit.max == 0
              ? const Icon(Icons.all_inclusive)
              : Text("$count-${unit.max}"),
        ),
        onTap: () {
          if (enabled) {
            context.read<WarbandModel>().add(
                WarriorModel(name: makeName(r.names, r.surnames), type: unit));
            Navigator.pop(context);
          }
        },
      );
    });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WarbandModel(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: Center(
          child: ListView.separated(
              itemBuilder: (context, idx) {
                var warrior = context.read<WarbandModel>().items[idx];
                return ListTile(
                  leading: Text("${warrior.cost}"),
                  title: Text(warrior.name),
                  subtitle: Text(warrior.type.name),
                );
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
                  builder: (context, child) => const UnitSelector(),
                ),
              ),
            );
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
