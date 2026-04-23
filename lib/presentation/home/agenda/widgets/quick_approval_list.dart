import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class QuickApprovalList extends StatelessWidget {
  const QuickApprovalList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for visitors
    final List<Map<String, dynamic>> quickApprovalList = [
      {
        'name': 'Tommy',
        'company': 'PT. Lorem ipsum',
        'destination': 'Gedung HQ',
        'date': 'Mon, 26 June 2025',
        'timeRange': '10:00 - 13:00',
        'avatar': Assets.images.avaPerson1.image(height: 40),
        'status': VisitorStatus.pending,
      },
    
    ];

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Approval',
              style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${quickApprovalList.length} requests',
              style: TextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SpaceHeight(10),

        // List of visitor cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickApprovalList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final visitor = quickApprovalList[index];
            return VisitorCard(
              status: visitor['status'],
              visitorName: visitor['name'],
              companyName: visitor['company'],
              destination: visitor['destination'],
              date: visitor['date'],
              timeRange: visitor['timeRange'],
              avatar: visitor['avatar'],
              onDeny: () {
              },
              onApprove: () {
              },
            );
          },
        ),
      ],
    );
  }
}
