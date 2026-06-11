import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';

class GuestInvitationPage extends StatelessWidget {
  const GuestInvitationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'My Invitations',
          style: TextStyle(
            fontSize: rfs(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(rw(context, 24)),
              decoration: BoxDecoration(
                color: AppColors.primary50.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mail_outline_rounded,
                size: rw(context, 48),
                color: AppColors.primary500,
              ),
            ),
            vSpace(context, 24),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: rfs(context, 22),
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
            vSpace(context, 8),
            Text(
              'This Feature Was On Progress',
              style: TextStyle(
                fontSize: rfs(context, 14),
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
