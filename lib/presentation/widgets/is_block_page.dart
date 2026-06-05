import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../core/helper/responsive_helper.dart';

class BlockedOverlay extends StatelessWidget {
  const BlockedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blocked.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.locked.image(),
            vSpace(context, 20),
            Text(
              "BLOCKED",
              style: TextStyle(
                fontSize: rfs(context, 30),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            vSpace(context, 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 32)),
              child: Text(
                "Account activity has been blocked\nImmediately contact the VMS admin/operator",
                style: TextStyle(color: Colors.white, fontSize: rfs(context, 16)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

