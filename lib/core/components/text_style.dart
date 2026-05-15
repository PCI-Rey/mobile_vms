import 'package:flutter/material.dart';
import '../constants/colors.dart';

class TextStyles {
  // Headline
  static const TextStyle headline1 = TextStyle(fontSize: 96, fontWeight: FontWeight.bold, color: AppColors.grey800, letterSpacing: -1.5);
  static const TextStyle headline2 = TextStyle(fontSize: 59, fontWeight: FontWeight.bold, color: AppColors.grey800, letterSpacing: -0.5);
  static const TextStyle headline3 = TextStyle(fontSize: 37, fontWeight: FontWeight.bold, color: AppColors.grey800);
  static const TextStyle headline4 = TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: AppColors.grey800);
  static const TextStyle headline5 = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.grey800);
  static const TextStyle headline6 = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.grey800);
  
  // Subtitle
  static const TextStyle subtitle1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.grey800);
  static const TextStyle subtitle2 = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey800);
  static const TextStyle subtitle3 = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grey600);

  // Body
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.grey800);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.grey700);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.grey600);
  static const TextStyle bodySmall400 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.grey600);
  static const TextStyle bodySmall500 = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.grey700);
  static const TextStyle bodySmall600 = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey800);

  // Caption
  static const TextStyle caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.grey500);

  // Overline
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.grey500,
  );
}
