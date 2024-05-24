import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class Welcome extends StatelessWidget {
  const Welcome({super.key});
  @override
  Widget build(BuildContext context) {
    return MyContent(
      child: Material(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: [
                          Text(
                            appName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: tcRed)
                                .apply(fontSizeFactor: 1.3),
                            textAlign: TextAlign.center,
                          ),
                          const Text("Beta 0.5"),
                        ],
                      ),
                      const Text(
                        'Hello There, welcome to my tool to build Trench Crusade lists.'
                        'I have some ideas about how I did not like other roster apps, and this is my chance to do something different,'
                        'I would come out with some better introduction here, and with it I would try to explain why this tools needs to be.'
                        '\n'
                        '\n'
                        'In the meanwhile there are a couple of things to say:'
                        '\n'
                        '- Roster Lists are intelectual property of Trench Crusade. I clame no ownership and I hope they do not excommunicate me for doing this!'
                        '\n'
                        '- This is a work in progress, please be kind with errors'
                        '\n'
                        '- This tool uses some basic storage/cookies mechanisms for its normal operation, by using the tool you accept them as well.',
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Last Changes:',
                              style: Theme.of(context).textTheme.titleMedium),
                          const Text(
                              '- Fixed limits of legionaries, prevent ilegal lists on remove.'),
                          const Text(
                              '- Lists are persistent, they are saved automatically.'),
                          const Text(
                              '- You can repeat weapons now, as long as the limitations work out.'),
                          const Text('- No more 24" shotguns.'),
                          const Text("- One Satchel Charge per model."),
                          const Text("- Add grenades filter")
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => const WarbandChooser()),
                            );
                          },
                          child: const Text(
                            "Let's go already!",
                          )),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
              ...x.map<Widget>((save) => Row(
                    children: [
                      Text(save),
                      const Spacer(),
                      IconButton(
                          onPressed: () => deleteSaved(save),
                          icon: const Icon(Icons.delete))
                    ],
                  )),
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
    return MyContent(
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
        var (roster, armory, wb) = future.data!;
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

  Future<(Roster, Armory, WarbandModel?)> loadJson(context) async {
    var data = await DefaultAssetBundle.of(context).loadString(asset);
    final r = Roster.fromJson(jsonDecode(data));

    data = await DefaultAssetBundle.of(context)
        .loadString("assets/lists/armory.json");
    var a = Armory.fromJson(jsonDecode(data));
    a.extendWithUnique(r);

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(title)) {
        final list = prefs.getString(title);
        final wb = WarbandModel.fromJson(jsonDecode(list!));
        return (r, a, wb);
      }
    } catch (e) {
      debugPrint("load list dropped");
    }

    await Future.delayed(const Duration(milliseconds: 500));
    return (r, a, null);
  }
}
