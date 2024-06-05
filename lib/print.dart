import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const sep = 120.0;

pw.Document renderPdf(WarbandModel warband, Roster roster, Armory armory) {
  final doc = pw.Document();

  doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Center(child: pw.Center(child: pw.Text(warband.name))),

          pw.Row(
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                padding: const pw.EdgeInsets.only(
                    left: 16, top: 8, right: 16, bottom: 40),
                child: pw.Text("Pay Chest"),
              ),
              pw.Spacer(),
              pw.Container(
                constraints: const pw.BoxConstraints(minWidth: 240),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                padding: const pw.EdgeInsets.only(
                    left: 16, top: 80, right: 16, bottom: 8),
                child: pw.Center(child: pw.Text("Insignia")),
              ),
              pw.Spacer(),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                padding: const pw.EdgeInsets.only(
                    left: 16, top: 8, right: 16, bottom: 40),
                child: pw.Text("Glory Points"),
              ),
              pw.Divider(),
            ],
          ),

          pw.Divider(),
          pw.Center(child: pw.Text(roster.elites)), // Elites

          ...warband.warriors
              .where((warrior) => warrior.type.isElite)
              .map((warrior) {
            return warriorBlock(warrior, armory);
          }),

          pw.Divider(),
          pw.Center(child: pw.Text(roster.troop)), // Warriors

          ...warband.warriors
              .where((warrior) => !warrior.type.isElite)
              .map((warrior) {
            return warriorBlock(warrior, armory);
          }),
        ];
      }));

  return doc;
}

pw.Container warriorBlock(WarriorModel warrior, Armory armory) {
  final ranged =
      warrior.currentWeapon(armory).where((w) => w.def.canRanged).toList();
  final melee = warrior.meleeWeaponsOrUnarmed(armory).toList();
  final armour = warrior.currentArmour(armory).toList();
  final equipment = warrior.currentEquipment(armory).toList();

  return pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all()),
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.all(4),
    child: pw.Column(
      children: [
        pw.Row(children: [
          pw.Text(warrior.name),
          pw.Spacer(),
          pw.Text(warrior.type.typeName),
        ]),
        pw.Row(children: [
          pw.Text("Keywords:"),
          pw.Text(warrior.effectiveKeywords.join(", ")),
        ]),
        pw.Table(children: [
          pw.TableRow(children: [
            pw.Text("Cost"),
            pw.Text("Movement"),
            pw.Text("Ranged"),
            pw.Text("Melee"),
            pw.Text("Armour"),
          ]),
          pw.TableRow(children: [
            pw.Text("${warrior.totalCost}"),
            pw.Text(warrior.type.movement),
            pw.Text("${warrior.type.ranged}"),
            pw.Text("${warrior.type.melee}"),
            pw.Text("${warrior.computeArmorValue(armory)}"),
          ])
        ]),

        ...(ranged.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(children: [
                  pw.TableRow(children: [
                    pw.Text("Ranged Weapons"),
                    pw.Text("Range"),
                    pw.Text("Modifiers"),
                    pw.Text("Keywords"),
                    pw.Text("Cost"),
                  ]),
                  ...warrior
                      .currentWeapon(armory)
                      .where((w) => w.def.canRanged)
                      .map((weapon) {
                    return pw.TableRow(children: [
                      pw.Text(weapon.name),
                      pw.Text("${weapon.def.range}"),
                      pw.Text(weapon.def.modifiers?.join("\n") ?? ""),
                      pw.Text(weapon.def.keywords?.join("\n") ?? ""),
                      pw.Text("${weapon.use.cost}"),
                    ]);
                  }),
                ])
              ]
            : []),

        ...(melee.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(children: [
                  pw.TableRow(children: [
                    pw.Text("Melee Weapons"),
                    pw.Text("Hands"),
                    pw.Text("Modifiers"),
                    pw.Text("Keywords"),
                    pw.Text("Cost"),
                  ]),
                  ...warrior.meleeWeaponsOrUnarmed(armory).map((weapon) {
                    return pw.TableRow(children: [
                      pw.Text(weapon.name),
                      pw.Text("${weapon.def.hands}"),
                      pw.Text(weapon.def.modifiers?.join("\n") ?? ""),
                      pw.Text(weapon.def.keywords?.join("\n") ?? ""),
                      pw.Text("${weapon.use.cost}"),
                    ]);
                  }),
                ])
              ]
            : []), // MELEE

        ...(armour.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(children: [
                  pw.TableRow(children: [
                    pw.Text("Armour"),
                    pw.Text("Type"),
                    pw.Text("Value"),
                    pw.Text("Cost"),
                  ]),
                  ...warrior.currentArmour(armory).map((armour) {
                    return pw.TableRow(children: [
                      pw.Text(armour.name),
                      pw.Text(armour.def.isBodyArmour
                          ? "Body armour"
                          : armour.def.isShield
                              ? "Shield"
                              : "-"),
                      pw.Text("${armour.def.value ?? ""}"),
                      pw.Text("${armour.use.cost}"),
                    ]);
                  }),
                ])
              ]
            : []), // armour

        ...(equipment.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(children: [
                  pw.TableRow(children: [
                    pw.Text("Equipment"),
                    pw.Text("Cost"),
                  ]),
                  ...warrior.currentEquipment(armory).map((equipment) {
                    return pw.TableRow(children: [
                      pw.Text(equipment.name),
                      pw.Text("${equipment.use.cost}"),
                    ]);
                  }),
                ]),
              ]
            : []), // equipment
      ],
    ),
  );
}

void printWarband(BuildContext context, Roster roster, Armory armory) async {
  final warband = context.read<WarbandModel>();
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async =>
          renderPdf(warband, roster, armory).save());
}

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.doc});
  final pw.Document doc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("preview"),
      ),
      body: PdfPreview(
        build: (fmt) => doc.save(),
      ),
    );
  }
}

void previewWarband(BuildContext context, Roster roster, Armory armory) {
  final warband = context.read<WarbandModel>();

  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (ctx) =>
            PreviewScreen(doc: renderPdf(warband, roster, armory))),
  );
}
