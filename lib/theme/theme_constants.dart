import 'package:flutter/material.dart';

Color primaryColor = const Color.fromARGB(255, 16, 56, 91);

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  backgroundColor: const Color.fromARGB(255, 216, 229, 253),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(primaryColor),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    ),
  ),
  textTheme: TextTheme(
    titleMedium: const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    labelMedium: const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  backgroundColor: const Color.fromARGB(255, 21, 25, 44),
  canvasColor: const Color.fromARGB(255, 13, 10, 24),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      backgroundColor: MaterialStateProperty.all(Colors.white),
      foregroundColor: MaterialStateProperty.all(Colors.black),
      overlayColor: MaterialStateProperty.all(Colors.black26),
    ),
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      // color: Colors.black,
    ),
    labelMedium: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
);
