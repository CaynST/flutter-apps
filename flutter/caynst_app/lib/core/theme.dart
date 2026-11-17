import 'package:flutter/material.dart';

const Color seedColor = Color(0xFF3F5BD9);

ThemeData buildTheme(Brightness brightness) {
  final ColorScheme scheme =
      ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
