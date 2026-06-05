import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';

Widget buildSquareStatCard(BuildContext context, String title, String value, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(rw(context, 10)),
      border: Border.all(color: AppColors.grey300, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: rw(context, 10),
          offset: Offset(0, rh(context, 4)),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyles.subtitle3.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: rfs(context, 13),
          ),
          textAlign: TextAlign.center,
        ),
        vSpace(context, 8),
        Text(
          value,
          style: TextStyles.subtitle1.copyWith(
            color: AppColors.primary500,
            fontSize: rfs(context, 16),
          ),
        ),
      ],
    ),
  );
}

