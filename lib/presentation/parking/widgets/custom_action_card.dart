import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';

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
      child: Button.outlined(
        onPressed: onTap,
        label: label,
        icon: icon,
        borderRadius: rw(context, 8.0),
        textColor: AppColors.grey800,
        fontSize: rfs(context, 16.0),
        borderColor: Colors.transparent,
        color: Colors.transparent,
        height: rh(context, 40),
      ),
    );
  }
}
