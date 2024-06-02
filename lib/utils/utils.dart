import 'package:flutter/material.dart';

const Color tcRed = Color.fromARGB(255, 159, 60, 42);
const Color secondary = Color.fromARGB(255, 159, 119, 42);
const Color terciary = Color.fromARGB(255, 159, 42, 82);

const String appName = 'Liber Excommunicationum';

T? findIn<T>(Iterable<T> it, bool Function(T v) predicate) {
  return it.where(predicate).firstOrNull;
}
