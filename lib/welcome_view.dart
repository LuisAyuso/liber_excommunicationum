import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tc_thing/main.dart';
import 'package:tc_thing/utils/utils.dart';

import 'controls/content_lex.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return ContentLex(
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
                          const Text("Beta 0.7"),
                        ],
                      ),
                      FutureBuilder(
                        future: getWelcomeText(),
                        builder: (context, future) {
                          if (future.hasError) {
                            return const Text("");
                          }
                          if (!future.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return Markdown(shrinkWrap: true, data: future.data!);
                        },
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
                        ),
                      ),
                      const Divider(),
                      FutureBuilder(
                        future: getChangelog(),
                        builder: (context, future) {
                          if (future.hasError) {
                            return const Text("");
                          }
                          if (!future.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return Markdown(shrinkWrap: true, data: future.data!);
                        },
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
                            "Cool, let's go now",
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

  Future<String> getWelcomeText() async {
    return await rootBundle.loadString('assets/welcome.md');
  }

  Future<String> getChangelog() async {
    return await rootBundle.loadString('assets/changelog.md');
  }
}
