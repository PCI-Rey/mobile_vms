import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CircleMenu extends StatelessWidget {
  final Widget image;
  final String? menuName;
  final double size;
  final Color backgroundColor;

  const CircleMenu({
    required this.image,
    this.menuName,
    this.backgroundColor = AppColors.primary100,
    this.size = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: image),
        ),
        if (menuName != null && menuName!.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Wrap with Flexible to prevent overflow
          Flexible(
            child: Text(
              menuName!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}