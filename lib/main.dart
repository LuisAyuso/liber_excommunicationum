import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';
import 'package:tc_thing/utils.dart';

import 'warband_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liber Excommunicationum',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 228, 217, 9),
            primary: tcRed,
            secondary: secondary,
            tertiary: terciary,
            surface: Colors.white,
            brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const WarbandChooser(),
    );
  }
}

class WarbandChooser extends StatelessWidget {
  const WarbandChooser({super.key});
  @override
  Widget build(BuildContext context) {
    return MyContent(
      child: Scaffold(
        body: GridView.count(
          crossAxisCount: 2, // Number of columns in the grid
          children: [
            warbandButton(
                context, "Heretic Legion", "assets/lists/heretic_legion.json"),
            warbandButton(context, "Trench Pilgrims",
                "assets/lists/trench_pilgrims.json"),
            warbandButton(context, "The Principality of New Antioch",
                "assets/lists/new_antioch.json"),
            warbandButton(
                context, "The Iron Sultanate", "assets/lists/sultanate.json"),
            warbandButton(context, "The Cult of the Black Grail",
                "assets/lists/black_grail.json"),
          ],
        ),
      ),
    );
  }

  Widget warbandButton(BuildContext context, String name, String asset) {
    return InkWell(
      onTap: () {
        debugPrint('Button tapped: $name');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => WarbandPage(title: name, asset: asset)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(16)),
          border: Border.all(
              color: Colors.black, style: BorderStyle.solid, width: 4),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                name,
                style: gothBlack24bold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WarbandPage extends StatelessWidget {
  const WarbandPage({super.key, required this.title, required this.asset});
  final String asset;
  final String title;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadJson(context),
        builder: (context, future) {
          if (future.hasError) {
            return const Text("Failed to load roster");
          }
          if (!future.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var (roster, armory) = future.data!;
          return ChangeNotifierProvider(
            create: (_) => WarbandModel.prefill(roster, armory),
            builder: (context, _) => WarbandView(
              title: title,
              roster: roster,
              armory: armory,
            ),
          );
        });
  }

  Future<(Roster, Armory)> loadJson(context) async {
    var data = await DefaultAssetBundle.of(context).loadString(asset);
    final r = Roster.fromJson(jsonDecode(data));

    data = await DefaultAssetBundle.of(context)
        .loadString("assets/lists/armory.json");
    var a = Armory.fromJson(jsonDecode(data));
    a.extendWithUnique(r);
    return (r, a);
  }
}
