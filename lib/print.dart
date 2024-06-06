import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;

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
  WarbandModel warband,
  Roster roster,
  Armory armory,
) async {
  final doc = pw.Document();

  doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Center(child: pw.Center(child: pw.Text(warband.name))),
          pw.Center(
              child: pw.Center(child: pw.Text("Band Cost: ${warband.cost}"))),

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
  final upgrades = warrior.appliedUpgrades;

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
            pw.Text("Movement"),
            pw.Text("Ranged"),
            pw.Text("Melee"),
            pw.Text("Armour"),
            pw.Text("Cost"),
          ]),
          pw.TableRow(children: [
            pw.Text(warrior.type.movement),
            pw.Text("${warrior.type.ranged}"),
            pw.Text("${warrior.type.melee}"),
            pw.Text("${warrior.computeArmorValue(armory)}"),
            pw.Text(multilineCost(warrior.totalCost)),
          ])
        ]),

        ...(ranged.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Text("Ranged Weapons"),
                      pw.Text("Range"),
                      pw.Text("Modifiers"),
                      pw.Text("Keywords"),
                      pw.Text("Cost"),
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
                  ],
                )
              ]
            : []),

        ...(melee.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Text("Melee Weapons"),
                      pw.Text("Hands"),
                      pw.Text("Modifiers"),
                      pw.Text("Keywords"),
                      pw.Text("Cost"),
                    ]),
                    ...melee.map((weapon) {
                      return pw.TableRow(children: [
                        pw.Text(weapon.name),
                        pw.Text("${weapon.def.hands}"),
                        pw.Text(weapon.def.modifiers?.join("\n") ?? ""),
                        pw.Text(weapon.def.keywords?.join("\n") ?? ""),
                        pw.Text(multilineCost(weapon.use.cost)),
                      ]);
                    }),
                  ],
                )
              ]
            : []), // MELEE

        ...(armour.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Text("Armour"),
                      pw.Text("Type"),
                      pw.Text("Value"),
                      pw.Text("Cost"),
                    ]),
                    ...armour.map((armour) {
                      return pw.TableRow(children: [
                        pw.Text(armour.name),
                        pw.Text(armour.def.isBodyArmour
                            ? "Body armour"
                            : armour.def.isShield
                                ? "Shield"
                                : "-"),
                        pw.Text("${armour.def.value ?? ""}"),
                        pw.Text(multilineCost(armour.use.cost)),
                      ]);
                    }),
                  ],
                )
              ]
            : []), // armour

        ...(equipment.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Text("Equipment"),
                      pw.Text("Cost"),
                    ]),
                    ...equipment.map((equipment) {
                      return pw.TableRow(
                        children: [
                          pw.Text(equipment.name),
                          pw.Text(multilineCost(equipment.use.cost)),
                        ],
                      );
                    }),
                  ],
                ),
              ]
            : []), // equipment

        ...(upgrades.isNotEmpty
            ? [
                pw.Divider(),
                pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Text("Upgrades"),
                    ]),
                    ...upgrades.map((upgrade) {
                      return pw.TableRow(
                        children: [
                          pw.Text(upgrade.toString()),
                        ],
                      );
                    }),
                  ],
                ),
              ]
            : []), // equipment
      ],
    ),
  );
}

void printWarband(BuildContext context, Roster roster, Armory armory) async {
  final warband = context.read<WarbandModel>();
  if (kIsWeb) {
    final doc = await renderPdf(warband, roster, armory);
    downloadFile(await doc.save(), "${warband.name}.pdf");
  }
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
