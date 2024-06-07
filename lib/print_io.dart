import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

import 'package:tc_thing/pdf.dart';

void printWarband(BuildContext context, Roster roster, Armory armory) async {
  final warband = context.read<WarbandModel>();

  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: const Text("PDF")),
          body: PdfPreview(
            build: (format) async =>
                (await renderPdf(format, context, warband, roster, armory))
                    .save(),
            allowSharing: false,
            canChangeOrientation: false,
          ),
        ),
      ),
    );
  }
}
