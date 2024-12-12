import 'package:flutter/material.dart';

ThemeData LightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color.fromARGB(255, 235, 238, 238),
    primary: Color.fromARGB(255, 5, 22, 26),
    secondary: Color.fromARGB(255, 7, 46, 51),
    inversePrimary: Color.fromARGB(255, 12, 112, 117),
  ),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Color.fromARGB(255, 109, 165, 192),
        displayColor: Color.fromARGB(255, 109, 165, 192),
      ),
);
