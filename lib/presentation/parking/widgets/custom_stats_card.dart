import 'package:flutter/material.dart';
import '../../../core/core.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
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
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
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
                const SizedBox(width: 8),
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
