import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tc_thing/model/model.dart';

class MyContent extends StatelessWidget {
  const MyContent({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.titleLarge!,
      child: Stack(children: [
        Container(color: const Color.fromARGB(255, 56, 56, 59)),
        Center(
          child: Container(
              constraints: const BoxConstraints(maxWidth: 960), child: child),
        ),
      ]),
    );
  }
}

const Color tcRed = Color.fromARGB(255, 159, 60, 42);
const Color secondary = Color.fromARGB(255, 159, 119, 42);
const Color terciary = Color.fromARGB(255, 159, 42, 82);

const String appName = 'Liber Excommunicationum';

String makeName(Roster roster, Sex sex, bool elite) {
  final prefixes = roster.elitePrefixes;
  final names = sex == Sex.male ? roster.namesM : roster.namesF;
  final surnames = roster.surnames;

  final random = Random();
  String prefix = "";
  if (elite && prefixes.isNotEmpty) {
    prefix = prefixes[random.nextInt(prefixes.length)];
    if (prefix[prefix.length - 1] != '-') prefix = "$prefix ";
  }

  final name = names[random.nextInt(names.length)];
  String surname = "";
  if (surnames.isNotEmpty) {
    surname = " ${surnames[random.nextInt(surnames.length)]}";
  }
  return "$prefix$name$surname";
}

class TableLEX extends StatelessWidget {
  const TableLEX({
    super.key,
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      horizontalMargin: 0,
      columnSpacing: 8.0,
      headingRowHeight: 32,
      dataRowMaxHeight: 32,
      dataRowMinHeight: 32,
      headingTextStyle: Theme.of(context).textTheme.titleSmall,
      dataTextStyle: Theme.of(context).textTheme.bodySmall,
      columns: headers.map((s) => DataColumn(label: Text(s))).toList(),
      rows: rows
          .map((r) => DataRow(cells: r.map((c) => DataCell(c)).toList()))
          .toList(),
    );
  }
}

class ItemChip extends StatelessWidget {
  const ItemChip({super.key, required this.item});
  final dynamic item;

  String get name {
    if (item is Item) return item.itemName;
    if (item is ItemUse) return item.getName;
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(name),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
