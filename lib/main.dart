import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tc_thing/model/model.dart';
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
      title: 'Trench Crusade',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
            warbandButton(context, "Heretic Cult", "assets/lists/cult.json"),
            warbandButton(context, "Trench Pilgrims",
                "assets/lists/trench_pilgrims.json"),
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
          MaterialPageRoute(builder: (ctx) => WarbandPage(asset: asset)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class WarbandPage extends StatelessWidget {
  const WarbandPage({super.key, required this.asset});
  final String asset;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WarbandModel(),
      builder: (context, _) => FutureBuilder(
        future: loadJson(context),
        builder: (context, future) {
          if (future.hasError) {
            return const Text("Failed to load roster");
          }
          if (!future.hasData) {
            return const CircularProgressIndicator();
          }
          var (roster, armory) = future.data!;
          return WarbandView(
            title: "Warband!",
            roster: roster,
            armory: armory,
          );
        },
      ),
    );
  }

  Future<(Roster, Armory)> loadJson(context) async {
    var data = await DefaultAssetBundle.of(context).loadString(asset);
    final r = Roster.fromJson(jsonDecode(data));

    data = await DefaultAssetBundle.of(context)
        .loadString("assets/lists/armory.json");
    final a = Armory.fromJson(jsonDecode(data));

    return (r, a);
  }
}
