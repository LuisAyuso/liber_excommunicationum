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
        future: loadRoster(context),
        builder: (context, roster) {
          if (roster.hasError) {
            return const Text("Failed to load roster");
          }
          if (!roster.hasData) {
            return const CircularProgressIndicator();
          }
          return WarbandView(title: "Warband!", roster: roster.data!);
        },
      ),
    );
  }

  Future<Roster> loadRoster(context) async {
    var data = await DefaultAssetBundle.of(context)
        .loadString("assets/lists/cult.json");
    var d = jsonDecode(data);
    return Roster.fromJson(d);
  }
}
