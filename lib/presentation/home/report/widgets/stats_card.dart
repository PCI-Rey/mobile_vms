import 'package:flutter/material.dart';
import '../../../../core/core.dart';
Widget buildSquareStatCard(String title, String value, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.grey300, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyles.subtitle3.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyles.subtitle1.copyWith(color: AppColors.primary500),
        ),
      ],
    ),
  );
}
