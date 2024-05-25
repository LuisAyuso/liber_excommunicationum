import 'package:flutter/material.dart';
import 'package:tc_thing/main.dart';
import 'package:tc_thing/utils/utils.dart';

import 'controls/content_lex.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});
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
                          const Text("Beta 0.6"),
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
                          const Text('- Rework of name generator algorithm.'),
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
