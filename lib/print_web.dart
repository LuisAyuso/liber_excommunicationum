import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

import 'package:tc_thing/pdf.dart';
import 'package:web/web.dart' as web;

void printWarband(BuildContext context, Roster roster, Armory armory) async {
  final warband = context.read<WarbandModel>();
  final doc =
      await renderPdf(PdfPageFormat.a4, context, warband, roster, armory);
  downloadFile(await doc.save(), "${warband.name}.pdf");
}

void downloadFile(Uint8List bytes, String filename) {
  final web.HTMLAnchorElement anchor =
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = "data:application/octet-stream;base64,${base64Encode(bytes)}"
        ..style.display = 'none'
        ..download = filename;

  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);
}
