import 'package:flutter/material.dart';
import '../../../core/core.dart';

class CustomActionCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const CustomActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Button.outlined(
        onPressed: onTap,
        label: label,
        icon: icon,
        borderRadius: 8.0,
        textColor: AppColors.grey800,
        fontSize: 16.0,
        borderColor: Colors.transparent,
        color: Colors.transparent,
        height: 40,
      ),
    );
  }
}
