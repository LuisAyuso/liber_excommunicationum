import 'package:flutter/material.dart';

class ContentLex extends StatelessWidget {
  const ContentLex({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.titleLarge!,
      child: Stack(children: [
        Container(color: const Color.fromARGB(255, 56, 56, 59)),
        Center(
          child: Container(
              constraints: const BoxConstraints(maxWidth: 960), child: child),
        ),
      ]),
    );
  }
}
