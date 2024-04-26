import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tc_thing/model/model.dart';

import 'warband_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
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
    var data = await DefaultAssetBundle.of(context)
        .loadString("assets/lists/cult.json");
    final r = Roster.fromJson(jsonDecode(data));

    data = await DefaultAssetBundle.of(context)
        .loadString("assets/lists/armory.json");
    final a = Armory.fromJson(jsonDecode(data));

    return (r, a);
  }
}
