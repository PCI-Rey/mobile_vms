import 'package:flutter/material.dart';

class TextStyles {
  // Headline
  static const TextStyle headline1 = TextStyle(fontSize: 96, fontWeight: FontWeight.bold);
  static const TextStyle headline2 = TextStyle(fontSize: 59, fontWeight: FontWeight.bold);
  static const TextStyle headline3 = TextStyle(fontSize: 37, fontWeight: FontWeight.bold);
  static const TextStyle headline4 = TextStyle(fontSize: 23, fontWeight: FontWeight.bold);
  static const TextStyle headline5 = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  static const TextStyle headline6 = TextStyle(fontSize: 9, fontWeight: FontWeight.bold);
  
  // Subtitle
  static const TextStyle subtitle1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle subtitle2 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle subtitle3 = TextStyle(fontSize: 13, fontWeight: FontWeight.normal);

  // Body
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
  static const TextStyle bodySmall400 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle bodySmall500 = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle bodySmall600 = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

  // Caption
  static const TextStyle caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400);

  // Overline
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  );
}
