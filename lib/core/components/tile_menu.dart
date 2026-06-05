import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../helper/responsive_helper.dart';

class TileMenu extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const TileMenu({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(rw(context, 12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(context, 12), vertical: rh(context, 16)),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary500,
                ),
                padding: EdgeInsets.all(rw(context, 10)),
                child: icon,
              ),
              hSpace(context, 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: rfs(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
