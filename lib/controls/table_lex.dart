import 'package:flutter/material.dart';

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
