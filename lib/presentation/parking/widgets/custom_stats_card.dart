import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';

class CustomStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? valueColor;

  const CustomStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.onTap,
    this.valueColor = AppColors.primary500,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(vertical: rh(context, 16.0), horizontal: rw(context, 12.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: rw(context, 6),
            offset: Offset(0, rh(context, 3)),
          ),
        ],
      ),
      child: icon == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                vSpace(context, 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: rfs(context, 24),
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary500),
                hSpace(context, 8),
                Text(title, style: TextStyles.headline3),
              ],
            ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }

    return child;
  }
}
