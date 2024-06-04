import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';
import 'package:tc_thing/utils/utils.dart';

import 'controls/content_lex.dart';
import 'warband_view.dart';
import 'welcome_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final defTheme = Theme.of(context).textTheme;
    final textTheme = Theme.of(context).textTheme.copyWith(
          titleLarge: defTheme.titleLarge!.apply(fontFamily: "CloisterBlack"),
          titleMedium: defTheme.titleMedium!.apply(fontFamily: "CloisterBlack"),
          titleSmall: defTheme.titleSmall!.apply(fontFamily: "CloisterBlack"),
        );

    return MaterialApp(
      title: appName,
      theme: ThemeData(
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 228, 217, 9),
            primary: tcRed,
            secondary: secondary,
            tertiary: terciary,
            surface: Colors.white,
            brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const Welcome(),
    );
  }
}

class SavedListsManager extends StatefulWidget {
  const SavedListsManager({super.key});

  @override
  State<SavedListsManager> createState() => _SavedListsManagerState();
}

class _SavedListsManagerState extends State<SavedListsManager> {
  late List<String> x;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadSaved(),
        builder: (context, future) {
          if (future.hasError) {
            return const Text("Failed to load roster");
          }
          if (!future.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          x = future.data!.toList();

          return Container(
            padding: const EdgeInsets.all(8),
            child: ListView(children: [
              Text(
                "Stored Warbands",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              ...x.map<Widget>(
                (save) => Row(
                  children: [
                    Text(save),
                    const Spacer(),
                    IconButton(
                      onPressed: () => deleteSaved(save),
                      icon: const Icon(Icons.delete),
                    )
                  ],
                ),
              ),
            ]),
          );
        });
  }

  Future<void> deleteSaved(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    setState(() {
      x.remove(key);
    });
  }

  Future<Set<String>> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }
}

class WarbandChooser extends StatelessWidget {
  const WarbandChooser({super.key});
  @override
  Widget build(BuildContext context) {
    return ContentLex(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          title: const Text(appName),
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      context: context,
                      builder: (BuildContext context) {
                        return const SavedListsManager();
                      });
                },
                icon: const Icon(Icons.save))
          ],
        ),
        body: FutureBuilder(
          future: loadArmory(DefaultAssetBundle.of(context)),
          builder: (context, future) {
            if (future.hasError) return const Text("Failed to load armory");
            if (!future.hasData) return const CircularProgressIndicator();
            return GridView.count(
              crossAxisCount: 2, // Number of columns in the grid
              children: <Widget>[
                WarbandButton(
                  armoy: future.data!,
                  rosterAsset: "assets/lists/heretic_legion.json",
                  variantsAssets: const [
                    "assets/lists/naval_raiding_party.json",
                    "assets/lists/trench_ghosts.json",
                  ],
                ),
                WarbandButton(
                  armoy: future.data!,
                  rosterAsset: "assets/lists/trench_pilgrims.json",
                  variantsAssets: const [
                    "assets/lists/procession_of_the_sacred_affliction.json",
                    "assets/lists/cavalcade_of_the_tenth_plague.json"
                  ],
                ),
                WarbandButton(
                  armoy: future.data!,
                  rosterAsset: "assets/lists/sultanate.json",
                  variantsAssets: const [
                    "assets/lists/the_cabal_of_assassins.json",
                  ],
                ),
                WarbandButton(
                  armoy: future.data!,
                  rosterAsset: "assets/lists/new_antioch.json",
                  variantsAssets: const [
                    "assets/lists/papal_states_intervention_force.json",
                    "assets/lists/eire_rangers.json",
                    "assets/lists/stoßtruppen_of_the_free_state_of_prussia.json",
                    "assets/lists/kingdom_of_alba_assault_detachment.json",
                  ],
                ),
                WarbandButton(
                  armoy: future.data!,
                  rosterAsset: "assets/lists/black_grail.json",
                  variantsAssets: const [],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WarbandButton extends StatelessWidget {
  const WarbandButton({
    super.key,
    required this.armoy,
    required this.rosterAsset,
    required this.variantsAssets,
  });
  final String rosterAsset;
  final Armory armoy;
  final List<String> variantsAssets;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadRoster(
            DefaultAssetBundle.of(context), armoy, rosterAsset, variantsAssets),
        builder: (context, future) {
          if (future.hasError) return const Text("Failed to load armory");
          if (!future.hasData) return const CircularProgressIndicator();

          final (armoy, roster, variants) = future.data!;

          return InkWell(
            onTap: () => onTap(context, armoy, roster, variants),
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadiusDirectional.all(Radius.circular(16)),
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
                      roster.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .apply(fontSizeFactor: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void onTap(
    BuildContext context,
    Armory armoy,
    Roster roster,
    List<RosterVariant> variants,
  ) {
    final lists = [roster, ...variants.map((v) => v.apply(roster))];

    if (lists.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => WarbandPage(armory: armoy, roster: lists.first),
        ),
      );
      return;
    }

    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            ...lists.map<Widget>(
              (newRoster) => TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) =>
                          WarbandPage(armory: armoy, roster: newRoster),
                    ),
                  );
                },
                child: Text(newRoster.name),
              ),
            )
          ],
        );
      },
    );
  }
}

class WarbandPage extends StatelessWidget {
  const WarbandPage({super.key, required this.roster, required this.armory});
  final Roster roster;
  final Armory armory;

  @override
  Widget build(BuildContext context) {
    final title = roster.name;
    return FutureBuilder(
      future: loadSaves(roster.name),
      builder: (context, future) {
        if (future.hasError) {
          return const Text("Failed to load roster");
        }
        if (!future.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var (_, wb) = future.data!;
        return ChangeNotifierProvider(
          create: (_) => wb ?? WarbandModel.prefill(roster, armory),
          builder: (context, _) => WarbandView(
            title: title,
            roster: roster,
            armory: armory,
          ),
        );
      },
    );
  }
}

Future<(bool, WarbandModel?)> loadSaves(String listName) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(listName)) {
      final list = prefs.getString(listName);
      return (true, WarbandModel.fromJson(jsonDecode(list!)));
    }
  } catch (e) {
    debugPrint("load list dropped");
  }
  return (false, null);
}

Future<(Armory, Roster, List<RosterVariant>)> loadRoster(
  AssetBundle bundle,
  Armory armory,
  String rosterAsset,
  List<String> variantsAssets,
) async {
  var data = await bundle.loadString(rosterAsset);
  final roster = Roster.fromJson(jsonDecode(data));

  final variantsJson = await Stream.fromIterable(variantsAssets)
      .asyncMap((v) => bundle.loadString(v))
      .toList();

  final variants = variantsJson
      .map((json) => RosterVariant.fromJson(jsonDecode(json)))
      .toList();

  return (armory, roster, variants);
}

Future<Armory> loadArmory(AssetBundle bundle) async {
  final data = await bundle.loadString("assets/lists/armory.json");
  return Armory.fromJson(jsonDecode(data));
}
