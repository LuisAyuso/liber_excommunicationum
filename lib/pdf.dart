import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

String multilineCost(Currency cost) {
  if (cost.isBoth) {
    return "${cost.ducats} Ducats\n${cost.glory} Glory";
  }
  if (cost.isGlory) {
    return "${cost.glory} Glory";
  }
  return "${cost.ducats} Ducats";
}

Future<pw.Document> renderPdf(
  PdfPageFormat format,
  BuildContext context,
  WarbandModel warband,
  Roster roster,
  Armory armory,
) async {
  final fontData =
      await rootBundle.load('assets/fonts/CloisterBlackLight-axjg.ttf');
  final gothTtf = pw.Font.ttf(fontData);

  final doc = pw.Document();

  doc.addPage(pw.MultiPage(
      pageFormat: format,
      theme: pw.ThemeData(
        header0: pw.TextStyle(font: gothTtf),
        header1: pw.TextStyle(font: gothTtf),
        header2: pw.TextStyle(font: gothTtf),
        header3: pw.TextStyle(font: gothTtf),
        header4: pw.TextStyle(font: gothTtf),
        bulletStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      build: (pw.Context context) {
        return [
          pw.Center(
              child:
                  pw.Text(warband.name, style: pw.Theme.of(context).header0)),

          pw.Center(
              child: pw.Text("Warband Cost: ${warband.cost}",
                  style: pw.Theme.of(context).header3)),

          pw.Divider(),
          pw.Center(child: pw.Text(roster.elites)), // Elites
          pw.Divider(),

          ...warband.warriors
              .where((warrior) => warrior.type.isElite)
              .map((warrior) {
            return warriorBlock(context, warrior, armory);
          }),

          pw.NewPage(),
          pw.Center(child: pw.Text(roster.troop)), // Warriors
          pw.Divider(),

          ...warband.warriors
              .where((warrior) => !warrior.type.isElite)
              .map((warrior) {
            return warriorBlock(context, warrior, armory);
          }),
        ];
      }));

  return doc;
}

pw.Container warriorBlock(
    pw.Context context, WarriorModel warrior, Armory armory) {
  final ranged =
      warrior.currentWeapon(armory).where((w) => w.def.canRanged).toList();
  final melee = warrior.meleeWeaponsOrUnarmed(armory).toList();
  final armour = warrior.currentArmour(armory).toList();
  final equipment = warrior.currentEquipment(armory).toList();
  final upgrades = warrior.appliedUpgrades;

  final h2 = pw.Theme.of(context).header2;
  final bullet = pw.Theme.of(context).bulletStyle;
  final tableHeader = pw.Theme.of(context).tableHeader;

  return pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all()),
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.all(4),
    child: pw.Column(children: [
      pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Column(children: [
          pw.Row(children: [
            pw.Text(warrior.name, style: h2),
            pw.Spacer(),
            pw.Text(warrior.type.typeName, style: h2),
          ]),
          pw.Row(children: [
            pw.Text("Keywords:"),
            pw.Text(warrior.effectiveKeywords.join(", "), style: bullet),
            pw.Spacer(),
            pw.Text(warrior.totalCost.toString())
          ]),
        ]),
      ),
      pw.Table(children: [
        pw.TableRow(
            decoration: const pw.BoxDecoration(
                border: pw.TableBorder(bottom: pw.BorderSide(width: 1))),
            children: [
              pw.Text("Movement", style: tableHeader),
              pw.Text("Ranged", style: tableHeader),
              pw.Text("Melee", style: tableHeader),
              pw.Text("Armour", style: tableHeader),
              pw.Text("Cost", style: tableHeader),
            ]),
        pw.TableRow(children: [
          pw.Text(warrior.type.movement),
          pw.Text("${warrior.type.ranged}"),
          pw.Text("${warrior.type.melee}"),
          pw.Text("${warrior.computeArmorValue(armory)}"),
          pw.Text(multilineCost(warrior.totalCost)),
        ]),
        ...(ranged.isNotEmpty
            ? [
                pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.TableBorder(bottom: pw.BorderSide(width: 1)),
                    ),
                    children: [
                      pw.Text("Ranged Weapons", style: tableHeader),
                      pw.Text("Range", style: tableHeader),
                      pw.Text("Modifiers", style: tableHeader),
                      pw.Text("Keywords", style: tableHeader),
                      pw.Text("Cost", style: tableHeader),
                    ]),
                ...ranged.map((weapon) {
                  return pw.TableRow(children: [
                    pw.Text(weapon.name),
                    pw.Text("${weapon.def.range}"),
                    pw.Text(weapon.def.modifiers?.join("\n") ?? ""),
                    pw.Text(weapon.def.keywords?.join("\n") ?? ""),
                    pw.Text(multilineCost(weapon.use.cost)),
                  ]);
                }),
              ]
            : []),

        ...(melee.isNotEmpty
            ? [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    border: pw.TableBorder(bottom: pw.BorderSide(width: 1)),
                  ),
                  children: [
                    pw.Text("Melee Weapons", style: tableHeader),
                    pw.Text("Hands", style: tableHeader),
                    pw.Text("Modifiers", style: tableHeader),
                    pw.Text("Keywords", style: tableHeader),
                    pw.Text("Cost", style: tableHeader),
                  ],
                ),
                ...melee.map((weapon) {
                  return pw.TableRow(children: [
                    pw.Text(weapon.name),
                    pw.Text("${weapon.def.hands}"),
                    pw.Text(weapon.def.modifiers?.join("\n") ?? ""),
                    pw.Text(weapon.def.keywords?.join("\n") ?? ""),
                    pw.Text(multilineCost(weapon.use.cost)),
                  ]);
                }),
              ]
            : []), // MELEE

        ...(armour.isNotEmpty
            ? [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      border: pw.TableBorder(bottom: pw.BorderSide(width: 1))),
                  children: [
                    pw.Text("Armour", style: tableHeader),
                    pw.Text("Type", style: tableHeader),
                    pw.Text("Value", style: tableHeader),
                    pw.Spacer(),
                    pw.Text("Cost", style: tableHeader),
                  ],
                ),
                ...armour.map((armour) {
                  return pw.TableRow(children: [
                    pw.Text(armour.name),
                    pw.Text(armour.def.isBodyArmour
                        ? "Body armour"
                        : armour.def.isShield
                            ? "Shield"
                            : "-"),
                    pw.Text("${armour.def.value ?? ""}"),
                    pw.Spacer(),
                    pw.Text(multilineCost(armour.use.cost)),
                  ]);
                }),
              ]
            : []), // armour

        ...(equipment.isNotEmpty
            ? [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      border: pw.TableBorder(bottom: pw.BorderSide(width: 1))),
                  children: [
                    pw.Text("Equipment", style: tableHeader),
                    pw.Spacer(),
                    pw.Spacer(),
                    pw.Spacer(),
                    pw.Text("Cost", style: tableHeader),
                  ],
                ),
                ...equipment.map((equipment) {
                  return pw.TableRow(
                    children: [
                      pw.Text(
                        equipment.name,
                        style: pw.Theme.of(context).bulletStyle,
                      ),
                      pw.Spacer(),
                      pw.Spacer(),
                      pw.Spacer(),
                      pw.Text(multilineCost(equipment.use.cost)),
                    ],
                  );
                }),
              ]
            : []), // equipment

        ...(upgrades.isNotEmpty
            ? [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      border: pw.TableBorder(bottom: pw.BorderSide(width: 1))),
                  children: [
                    pw.Text("Upgrades", style: tableHeader),
                    pw.Spacer(),
                    pw.Spacer(),
                    pw.Spacer(),
                    pw.Spacer(),
                  ],
                ),
                ...upgrades.map((upgrade) {
                  return pw.TableRow(
                    children: [
                      pw.Text(upgrade.toString()),
                    ],
                  );
                }),
              ]
            : []), // equipment
      ]),
      pw.SizedBox(height: 8),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Column(children: [
          pw.Text("Experience", style: tableHeader),
          pw.Container(
            constraints:
                const pw.BoxConstraints(maxWidth: 20 * 6, maxHeight: 20 * 3),
            child: pw.GridView(
              crossAxisCount: 6,
              children: List.generate(
                  6 * 3,
                  (idx) => pw.Container(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(),
                            color: idx % 2 == 1
                                ? PdfColors.grey300
                                : PdfColors.white,
                          ),
                        ),
                      )).toList(),
            ),
          ),
        ]),
        pw.SizedBox(width: 16),
        pw.Column(children: [
          pw.Text("Scars", style: tableHeader),
          pw.SizedBox(height: 4),
          pw.SizedBox(
            width: 16,
            height: 16,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.SizedBox(
            width: 16,
            height: 16,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
            ),
          ),
        ]),
        pw.SizedBox(width: 16),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("Abilities:", style: tableHeader),
          pw.Text(warrior.type.abilities?.join(", ") ?? ""),
        ])
      ])
    ]),
  );
}
