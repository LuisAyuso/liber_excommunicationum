import 'package:flutter/material.dart';

class MyContent extends StatelessWidget {
  const MyContent({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: const Color.fromARGB(255, 56, 56, 59)),
      Center(
        child: Container(
            constraints: const BoxConstraints(maxWidth: 960), child: child),
      ),
    ]);
  }
}
