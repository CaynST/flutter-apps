
import 'package:flutter/material.dart';

const Color paper = Color(0xFFFAF6F0);
const Color ink = Color(0xFF202A38);
const Color vermilion = Color(0xFFC9441F);
const Color coral = Color(0xFFDF4B2A);
const Color moss = Color(0xFF5F7350);
const Color sand = Color(0xFFE7DDCF);
const Color pencil = Color(0xFF6F6A5E);
const Color errorInk = Color(0xFFA32B1C);

TextStyle fraunces({
  double size = 24,
  double weight = 600,
  double opsz = 40,
  Color color = ink,
  double height = 1.05,
  double letterSpacing = -0.4,
}) {
  return TextStyle(
    fontFamily: 'Fraunces',
    fontSize: size,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontVariations: <FontVariation>[
      FontVariation('wght', weight),
      FontVariation('opsz', opsz),
    ],
  );
}

TextStyle karla({
  double size = 15,
  double weight = 400,
  Color color = ink,
  double height = 1.45,
  double letterSpacing = 0,
}) {
  return TextStyle(
    fontFamily: 'Karla',
    fontSize: size,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontVariations: <FontVariation>[FontVariation('wght', weight)],
  );
}

ThemeData buildTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: vermilion,
    brightness: Brightness.light,
  ).copyWith(
    primary: vermilion,
    onPrimary: paper,
    secondary: moss,
    onSecondary: paper,
    surface: paper,
    onSurface: ink,
    outline: sand,
    outlineVariant: sand,
    error: errorInk,
    onError: paper,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: paper,
    fontFamily: 'Karla',
    textTheme: TextTheme(
      displaySmall: fraunces(size: 40),
      headlineMedium: fraunces(size: 28),
      titleLarge: fraunces(size: 22),
      titleMedium: karla(size: 16, weight: 600),
      bodyLarge: karla(size: 16),
      bodyMedium: karla(size: 15),
      bodySmall: karla(size: 13, color: pencil),
      labelLarge: karla(size: 15, weight: 700),
      labelSmall: karla(size: 12, weight: 600, color: pencil),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: paper,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: sand, width: 1),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: sand, width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: ink, width: 1.4),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: errorInk, width: 1.2),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: errorInk, width: 1.4),
      ),
      labelStyle: karla(size: 13, color: pencil),
      hintStyle: karla(size: 15, color: pencil),
      floatingLabelStyle: karla(size: 12, weight: 600, color: pencil),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: vermilion,
        foregroundColor: paper,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        textStyle: karla(size: 15, weight: 700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: const BorderSide(color: ink, width: 1.1),
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        textStyle: karla(size: 15, weight: 600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: vermilion,
        textStyle: karla(size: 14, weight: 600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: karla(color: paper),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(
      color: sand,
      thickness: 0.8,
      space: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: sand),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: vermilion,
      foregroundColor: paper,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: CircleBorder(side: BorderSide(color: ink, width: 1.4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: vermilion),
    iconTheme: const IconThemeData(color: ink),
  );
}
