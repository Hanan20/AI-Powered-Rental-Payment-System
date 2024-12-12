import 'package:flutter/material.dart';

ThemeData DarkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Color.fromARGB(255, 5, 22, 26),
    primary: Color.fromARGB(255, 7, 46, 51),
    secondary: Color.fromARGB(255, 12, 112, 117),
    inversePrimary: Color.fromARGB(255, 109, 165, 192),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: const Color.fromARGB(255, 109, 165, 192),
        displayColor: const Color.fromARGB(255, 109, 165, 192),
      ),
);
