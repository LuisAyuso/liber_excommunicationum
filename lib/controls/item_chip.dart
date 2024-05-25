import 'package:flutter/material.dart';
import 'package:tc_thing/model/model.dart';

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
