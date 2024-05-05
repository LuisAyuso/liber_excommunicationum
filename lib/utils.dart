import 'package:flutter/material.dart';

class MyContent extends StatelessWidget {
  const MyContent({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          constraints: const BoxConstraints(maxWidth: 960), child: child),
    );
  }
}
