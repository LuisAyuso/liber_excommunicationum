import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tc_thing/model/filters.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';
import 'package:tc_thing/roster_preview.dart';
import 'package:tc_thing/utils.dart';

import 'unit_selector.dart';

class WarbandView extends StatefulWidget {
  const WarbandView(
      {super.key,
      required this.title,
      required this.roster,
      required this.armory});
  final String title;
  final Roster roster;
  final Armory armory;

  @override
  State<WarbandView> createState() => _WarbandViewState();
}

class EditingModel extends ChangeNotifier {
  bool _editing = true;
  bool get editing => _editing;
  set editing(bool v) {
    _editing = v;
    notifyListeners();
  }
}

class _WarbandViewState extends State<WarbandView> {
  @override
  Widget build(BuildContext context) {
    return MyContent(
      child: ChangeNotifierProvider(
        create: (_) => EditingModel(),
        builder: (context, child) => Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(
              textAlign: TextAlign.left,
              widget.title,
              softWrap: true,
            ),
            actions: [
              SizedBox(
                child: FutureBuilder(
                    future: saveValue(context.watch<WarbandModel>()),
                    builder: (context, future) {
                      if (future.hasError) {
                        return const Icon(Icons.error);
                      }
                      if (!future.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return CurrencyWidget(cost: future.data!.cost);
                    }),
              ),
              IconButton(
                onPressed: () => openRosterPreview(context),
                icon: const Icon(Icons.note),
              ),
              context.watch<EditingModel>().editing
                  ? IconButton(
                      onPressed: () =>
                          context.read<EditingModel>().editing = false,
                      icon: const Icon(Icons.save),
                    )
                  : IconButton(
                      onPressed: () =>
                          context.read<EditingModel>().editing = true,
                      icon: const Icon(Icons.edit),
                    ),
            ],
          ),
          body: ListView.separated(
              itemBuilder: (context, idx) {
                if (idx == context.read<WarbandModel>().length) {
                  // allow scrolling past last
                  return const SizedBox(height: 500);
                }
                var warrior = context.read<WarbandModel>().warriors[idx];
                return WarriorBlock(
                    roster: widget.roster,
                    armory: widget.armory,
                    warrior: warrior);
              },
              separatorBuilder: (context, idx) => const Divider(),
              itemCount: context.watch<WarbandModel>().length + 1),
          floatingActionButton: context.watch<EditingModel>().editing
              ? FloatingActionButton(
                  onPressed: () => openUnitSelection(context),
                  tooltip: 'Add Unit',
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }

  void openRosterPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RosterPreview(roster: widget.roster, armory: widget.armory),
      ),
    );
  }

  void openUnitSelection(BuildContext context) {
    var value = context.read<WarbandModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
            value: value,
            builder: (context, child) =>
                UnitSelector(roster: widget.roster, armory: widget.armory)),
      ),
    );
  }

  Future<WarbandModel> saveValue(WarbandModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.title, jsonEncode(model.toJson()));
    await Future.delayed(const Duration(milliseconds: 500));
    return model;
  }
}

UnmodifiableListView<String> compressLabels(Iterable<ItemUse> items) {
  var map = <String, int>{};

  for (var item in items) {
    final name = item.getName;
    if (map.containsKey(name)) {
      map[name] = map[name]! + 1;
    } else {
      map[name] = 1;
    }
  }

  return UnmodifiableListView(map.entries.map((entries) {
    if (entries.value > 1) return "${entries.key} x${entries.value}";
    return entries.key;
  }));
}

class WarriorBlock extends StatelessWidget {
  WarriorBlock(
      {super.key,
      required this.roster,
      required this.armory,
      required this.warrior});
  final Roster roster;
  final Armory armory;
  final WarriorModel warrior;

  final ItemFilter onlyRanged = ItemFilter(rangedWeapon: true);
  final ItemFilter onlyMelee = ItemFilter(meleeWeapon: true);
  final ItemFilter onlyGrenades = ItemFilter(isGrenade: true);

  @override
  Widget build(BuildContext context) {
    final unitCount = context
        .read<WarbandModel>()
        .warriors
        .where((other) => other.type.typeName == warrior.type.typeName)
        .length;

    return ExpansionTile(
      tilePadding: const EdgeInsets.only(left: 8, right: 8),
      childrenPadding: const EdgeInsets.only(left: 8, right: 8),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NameEditor(
                  name: warrior.name,
                  editable: context.watch<EditingModel>().editing,
                  onChange: (newSex, name) {
                    // this is the sex change function, anytime!
                    changeName(warrior, name, newSex, context);
                  },
                ),
                Text(
                  warrior.type.typeName,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                TableLEX(headers: const [
                  "Total Cost",
                  "Mov.",
                  "Armour",
                ], rows: [
                  [
                    Text(warrior.totalCost.toString()),
                    Text(
                      textAlign: TextAlign.end,
                      warrior.type.movement,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      textAlign: TextAlign.end,
                      "${warrior.computeArmorValue(armory)}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ]
                ])
              ]),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.start,
            runSpacing: 2,
            children: compressLabels(warrior.weapons)
                .map<Widget>((w) => ItemChip(item: w))
                .toList(),
          ),
          Wrap(
              spacing: 8,
              alignment: WrapAlignment.start,
              children: compressLabels(warrior.armour)
                  .map<Widget>((w) => ItemChip(item: w))
                  .toList()),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.start,
            children: compressLabels(warrior.equipment)
                .map<Widget>((w) => ItemChip(item: w))
                .toList(),
          ),
        ],
      ),
      children: [
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...editControls(
                  context,
                  warrior,
                  warrior.availableWeapons(roster, armory),
                  warrior.availableArmours(roster, armory),
                  warrior.availableEquipment(roster, armory),
                  unitCount),
              ...warrior
                  .weaponsOrUnarmed(armory)
                  .map((item) => weaponLine(context, item, warrior)),
              ...warrior.armour
                  .map((item) => armorLine(context, item, warrior)),
              ...warrior.equipment
                  .map((item) => equipmentLine(context, item, warrior)),
            ]),
      ],
    );
  }

  void changeName(
      WarriorModel warrior, String? name, Sex newSex, BuildContext context) {
    warrior.name = name ?? makeName(roster, newSex, warrior.type.isElite);
    warrior.sex = newSex;
    context.read<WarbandModel>().invalidate();
  }

  UnmodifiableListView<Widget> editControls(
    BuildContext context,
    WarriorModel warrior,
    UnmodifiableListView<WeaponUse> availableWeapons,
    UnmodifiableListView<ArmourUse> availableArmours,
    UnmodifiableListView<EquipmentUse> availableEquipment,
    int unitCount,
  ) {
    if (context.watch<EditingModel>().editing) {
      return UnmodifiableListView([
        Row(children: [
          FilledButton.tonal(
            onPressed: availableWeapons.isEmpty
                ? null
                : () {
                    var wb = context.read<WarbandModel>();
                    showModalBottomSheet(
                        backgroundColor: Colors.black,
                        context: context,
                        builder: (BuildContext context) {
                          return ItemChooser(
                              elements: availableWeapons.toList(),
                              armory: armory,
                              filter: ItemChooserFilterDelegate(filters: {
                                "Ranged": onlyRanged,
                                "Grenades": onlyGrenades,
                                "Melee": onlyMelee,
                              }),
                              callback: (use) {
                                wb.getUID(warrior.uid).addItem(use, armory);
                                wb.invalidate();
                                Navigator.pop(context);
                              });
                        });
                  },
            child: const Text("+Weapon"),
          ),
          FilledButton.tonal(
            onPressed: availableArmours.isEmpty
                ? null
                : () {
                    var wb = context.read<WarbandModel>();
                    showModalBottomSheet(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        context: context,
                        builder: (BuildContext context) {
                          return ItemChooser(
                              elements: availableArmours.toList(),
                              armory: armory,
                              callback: (use) {
                                wb.getUID(warrior.uid).addItem(use, armory);
                                wb.invalidate();
                                Navigator.pop(context);
                              });
                        });
                  },
            child: const Text("+Armour"),
          ),
          FilledButton.tonal(
            onPressed: availableEquipment.isEmpty
                ? null
                : () {
                    var wb = context.read<WarbandModel>();
                    showModalBottomSheet(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        context: context,
                        builder: (BuildContext context) {
                          return ItemChooser(
                              elements: availableEquipment.toList(),
                              armory: armory,
                              callback: (use) {
                                wb.getUID(warrior.uid).addItem(use, armory);
                                wb.invalidate();
                                Navigator.pop(context);
                              });
                        });
                  },
            child: const Text("+Equipment"),
          ),
        ]),
        Row(children: [
          (warrior.type.max ?? double.infinity) > unitCount
              ? IconButton(
                  onPressed: () {
                    var wbm = context.read<WarbandModel>();
                    wbm.add(warrior.cloneWith(
                      name: makeName(
                          roster, warrior.type.sex, warrior.type.isElite),
                      newUid: wbm.nextUID(),
                    ));
                  },
                  icon: const Icon(Icons.copy),
                )
              : const SizedBox(),
          (warrior.type.min ?? 0) >= unitCount
              ? const SizedBox()
              : IconButton(
                  onPressed: () {
                    attemptRemove(context, warrior);
                  },
                  icon: const Icon(Icons.delete),
                )
        ]),
      ]);
    } else {
      return UnmodifiableListView([]);
    }
  }

  void attemptRemove(BuildContext context, WarriorModel warrior) {
    // remove the guy, and see it the list holds. if not, popup a
    // thing explaining why

    var without =
        context.read<WarbandModel>().warriors.map((u) => u.clone()).toList();
    without.removeWhere((w) => w.uid == warrior.uid);

    var reasons = <RichText>[];
    for (var other in without) {
      var withoutOther = without.map((u) => u.clone()).toList();
      withoutOther.removeWhere((w) => w.uid == other.uid);
      final wtype = other.type;
      if (!makeUnitFilter(wtype).isUnitAllowed(wtype, withoutOther)) {
        reasons.add(
          RichText(
            text: TextSpan(children: [
              const TextSpan(text: "Warrior "),
              TextSpan(
                text: other.name,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: tcRed),
              ),
              const TextSpan(text: " of type "),
              TextSpan(
                text: other.type.typeName,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.white),
              ),
              const TextSpan(text: " would break the rules"),
            ]),
          ),
        );
      }
    }

    if (reasons.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
                text: TextSpan(children: [
              const TextSpan(text: "Cannot remove "),
              TextSpan(
                text: warrior.name,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: tcRed),
              ),
            ])),
            const Divider(),
            ...reasons,
          ],
        )

            //ListView(
            //children: reasons.map((s) => Text(s)).toList(),
            //)
            //   duration: const Duration(milliseconds: 1500),
            //   width: 280.0, // Width of the SnackBar.
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 8.0, // Inner padding for SnackBar content.
            //   ),
            //   behavior: SnackBarBehavior.floating,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10.0),
            //   ),
            ),
      );
    } else {
      context.read<WarbandModel>().removeUID(warrior.uid);
    }
  }

  Widget weaponLine(
    BuildContext context,
    WeaponUse weapon,
    WarriorModel warrior,
  ) {
    final defaultItem = (warrior.type.defaultItems ?? [])
        .where((eq) => eq.itemName == weapon.getName)
        .firstOrNull;

    final replace = context.watch<EditingModel>().editing &&
            defaultItem != null &&
            defaultItem.replacements != null
        ? replaceWeapon(context, warrior, weapon, defaultItem)
        : null;
    final delete = context.watch<EditingModel>().editing && weapon.isRemovable
        ? IconButton(
            onPressed: () {
              warrior.removeItem(weapon, armory);
              context.read<WarbandModel>().invalidate();
            },
            icon: const Icon(Icons.delete))
        : null;
    final editWidgets = [replace, delete].nonNulls.toList();

    return ItemDescription(
        item: weapon,
        armory: armory,
        edit: editWidgets.isEmpty
            ? null
            : Row(
                children: editWidgets,
              ));
  }

  TextButton replaceWeapon(
    BuildContext context,
    WarriorModel warrior,
    WeaponUse oldWeapon,
    DefaultItem replaceableItem,
  ) {
    return TextButton(
      onPressed: () {
        var wb = context.read<WarbandModel>();
        final replacements = replaceableItem.replacements ?? ItemReplacement();
        showModalBottomSheet(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            context: context,
            builder: (BuildContext context) {
              final alterEgo = warrior.cloneWith(name: "", newUid: -1);
              alterEgo.removeItem(oldWeapon, armory);
              final candidates = alterEgo
                  .availableWeapons(
                roster,
                armory,
              )
                  .where((item) {
                if (item.getName == oldWeapon.getName) return false;
                if (!replacements.isAllowed(armory.findItem(item))) {
                  return false;
                }
                final defA = armory.findWeapon(oldWeapon);
                final defB = armory.findWeapon(item);
                return defA.canRanged == defB.canRanged;
              }).map((item) {
                final offsetCost = replacements.offsetCost ?? oldWeapon.getCost;
                item.cost = offsetCost.offset(item.cost);
                return item;
              }).toList();
              return ItemChooser(
                  elements: candidates,
                  armory: armory,
                  callback: (newWeapon) {
                    warrior.replace(oldWeapon, newWeapon, armory);
                    wb.invalidate();
                    Navigator.pop(context);
                  });
            });
      },
      child: const Text("Replace"),
    );
  }

  Widget armorLine(
      BuildContext context, ArmourUse armour, WarriorModel warrior) {
    final defaultItem = (warrior.type.defaultItems ?? [])
        .where((eq) => eq.itemName == armour.typeName)
        .firstOrNull;

    final replace = context.watch<EditingModel>().editing &&
            defaultItem != null &&
            defaultItem.replacements != null
        ? replaceArmour(context, warrior, armour, defaultItem)
        : null;
    final delete = context.watch<EditingModel>().editing && armour.isRemovable
        ? IconButton(
            onPressed: () {
              warrior.removeItem(armour, armory);
              context.read<WarbandModel>().invalidate();
            },
            icon: const Icon(Icons.delete))
        : null;
    final editWidgets = [replace, delete].nonNulls.toList();

    return ItemDescription(
        item: armour,
        armory: armory,
        edit: editWidgets.isEmpty
            ? null
            : Row(
                children: editWidgets,
              ));
  }

  TextButton replaceArmour(
    BuildContext context,
    WarriorModel warrior,
    ArmourUse oldArmour,
    DefaultItem replaceableItem,
  ) {
    return TextButton(
      onPressed: () {
        var wb = context.read<WarbandModel>();
        final replacements = replaceableItem.replacements ?? ItemReplacement();
        showModalBottomSheet(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            context: context,
            builder: (BuildContext context) {
              final alterEgo = warrior.cloneWith(name: "", newUid: -1);
              alterEgo.removeItem(oldArmour, armory);
              final newCandidates = alterEgo
                  .availableArmours(
                roster,
                armory,
              )
                  .where((item) {
                if (item.getName == oldArmour.getName) return false;
                return replacements.isAllowed(armory.findItem(item));
              }).map((item) {
                final offsetCost = replacements.offsetCost ?? oldArmour.cost;
                return ArmourUse(
                    typeName: item.typeName,
                    cost: offsetCost.offset(item.cost),
                    removable: item.removable,
                    filter: item.filter,
                    limit: item.limit);
              }).toList();
              return ItemChooser(
                  elements: newCandidates,
                  armory: armory,
                  callback: (newArmour) {
                    warrior.replace(oldArmour, newArmour, armory);
                    wb.invalidate();
                    Navigator.pop(context);
                  });
            });
      },
      child: const Text("Replace"),
    );
  }

  Widget equipmentLine(
      BuildContext context, EquipmentUse e, WarriorModel warrior) {
    return ItemDescription(
        item: e,
        armory: armory,
        edit: context.watch<EditingModel>().editing && e.isRemovable
            ? IconButton(
                onPressed: () {
                  warrior.removeItem(e, armory);
                  context.read<WarbandModel>().invalidate();
                },
                icon: const Icon(Icons.delete))
            : null);
  }
}

class NameEditor extends StatefulWidget {
  const NameEditor(
      {super.key, required this.name, required this.onChange, this.editable});
  final String name;
  final Function(Sex, String? name) onChange;
  final bool? editable;

  @override
  State<NameEditor> createState() => _NameEditorState();
}

enum NameEditorState { display, choose, write }

enum SexEditorState { none, male, female, custom, back }

class _NameEditorState extends State<NameEditor> {
  final textController = TextEditingController();
  NameEditorState _editing = NameEditorState.display;

  @override
  Widget build(BuildContext context) {
    return switch (_editing) {
      NameEditorState.display => display(context),
      NameEditorState.choose => choose(context),
      NameEditorState.write => write(context),
    };
  }

  Widget display(BuildContext context) {
    return Row(children: [
      Text(
        widget.name,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: tcRed)
            .apply(fontSizeFactor: 1.2),
      ),
      widget.editable ?? true
          ? IconButton(
              onPressed: () {
                setState(() {
                  _editing = NameEditorState.choose;
                });
              },
              icon: const Icon(Icons.edit),
            )
          : const SizedBox(),
    ]);
  }

  Widget choose(BuildContext context) {
    return SegmentedButton<SexEditorState>(
      segments: const [
        ButtonSegment<SexEditorState>(
            value: SexEditorState.male, icon: Icon(Icons.male)),
        ButtonSegment<SexEditorState>(
            value: SexEditorState.female, icon: Icon(Icons.female)),
        ButtonSegment<SexEditorState>(
            value: SexEditorState.custom, icon: Icon(Icons.edit)),
        ButtonSegment<SexEditorState>(
            value: SexEditorState.back, icon: Icon(Icons.undo)),
      ],
      selected: const <SexEditorState>{SexEditorState.none},
      onSelectionChanged: (v) {
        switch (v.first) {
          case SexEditorState.none:
          case SexEditorState.back:
            setState(() {
              _editing = NameEditorState.display;
            });
            break;
          case SexEditorState.male:
            widget.onChange(Sex.male, null);
            setState(() {
              _editing = NameEditorState.display;
            });
            break;
          case SexEditorState.female:
            widget.onChange(Sex.female, null);
            setState(() {
              _editing = NameEditorState.display;
            });
            break;
          case SexEditorState.custom:
            setState(() {
              _editing = NameEditorState.write;
            });
        }
      },
    );
  }

  Widget write(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'New name',
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _editing = NameEditorState.display;
                });
              },
              icon: const Icon(Icons.undo))),
      controller: textController,
      onEditingComplete: () {
        if (textController.text.isNotEmpty) {
          widget.onChange(Sex.custom, textController.text);
        }
        setState(() {
          _editing = NameEditorState.display;
        });
      },
    );
  }
}

class ItemChooserFilterDelegate {
  const ItemChooserFilterDelegate({required Map<String, ItemFilter> filters})
      : _filters = filters;

  final Map<String, ItemFilter> _filters;

  UnmodifiableListView<ItemFilter> get getFilters => UnmodifiableListView(
      _filters.entries.map((entry) => entry.value).toList());
  UnmodifiableListView<ButtonSegment<ItemFilter>> get buttonSegments =>
      UnmodifiableListView(_filters.entries
          .map((entry) => ButtonSegment<ItemFilter>(
              value: entry.value, label: Text(entry.key)))
          .toList());
}

class ItemChooser extends StatefulWidget {
  const ItemChooser({
    super.key,
    required this.callback,
    required this.elements,
    required this.armory,
    this.priceOffset = const Currency(),
    this.filter,
  });
  final void Function(ItemUse) callback;
  final List<ItemUse> elements;
  final Armory armory;
  final Currency priceOffset;
  final ItemChooserFilterDelegate? filter;

  @override
  State<ItemChooser> createState() => _ItemChooserState();
}

class _ItemChooserState extends State<ItemChooser> {
  late Set<ItemFilter> _currentFilter;

  ItemFilter get asFilter => ItemFilter.anyOf(_currentFilter.toList());
  UnmodifiableListView<ItemUse> get items {
    final filter = asFilter;
    return UnmodifiableListView(widget.elements
        .where((item) => filter.isItemAllowed(widget.armory.findItem(item)))
        .toList());
  }

  @override
  void initState() {
    _currentFilter =
        widget.filter?.getFilters.toSet() ?? {ItemFilter.trueValue()};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = items;
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      color: Colors.white,
      child: Column(
        children: [
          widget.filter != null
              ? SegmentedButton<ItemFilter>(
                  emptySelectionAllowed: false,
                  segments: widget.filter?.buttonSegments ?? [],
                  selected: _currentFilter,
                  multiSelectionEnabled: true,
                  onSelectionChanged: (filter) {
                    if (filter == _currentFilter) return;
                    setState(() => _currentFilter = filter);
                  })
              : const SizedBox(),
          Expanded(
            child: ListView.separated(
              itemBuilder: (ctx, idx) => InkWell(
                onTap: () => widget.callback(list[idx]),
                child: ItemDescription(
                  item: list[idx],
                  armory: widget.armory,
                ),
              ),
              separatorBuilder: (ctx, idx) => const Divider(),
              itemCount: list.length,
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyWidget extends StatelessWidget {
  const CurrencyWidget({super.key, required Currency cost, bool? simultaneous})
      : _cost = cost,
        _simultaneous = simultaneous ?? true;

  final Currency _cost;
  final bool _simultaneous;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
      child: _simultaneous
          ? Stack(children: [
              _cost.glory > 0
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      child: gloryValue(20),
                    )
                  : const SizedBox(),
              _cost.ducats > 0 ? ducatsValue(28) : const SizedBox(),
            ])
          : _cost.isDucats
              ? ducatsValue(20)
              : gloryValue(20),
    );
  }

  Widget ducatsValue(double size) {
    return Text("${_cost.ducats}");
  }

  Widget gloryValue(double size) =>
      Stack(alignment: Alignment.center, children: [
        const Icon(
          Icons.star,
          size: 40,
          color: tcRed,
        ),
        Text("${_cost.glory}"),
      ]);
}

Widget statBox<T>(BuildContext context, String name, T stat) {
  return Column(
    children: [
      Text(
        name,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      Text(
        textAlign: TextAlign.end,
        "$stat",
        style: Theme.of(context).textTheme.labelSmall,
      ),
    ],
  );
}
