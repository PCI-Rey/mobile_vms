import 'package:flutter/material.dart';
import '../../core/core.dart';

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
            const SizedBox(height: 20),
            const Text(
              "BLOCKED",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Account activity has been blocked\nImmediately contact the VMS admin/operator",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
