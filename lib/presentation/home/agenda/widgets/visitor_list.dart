import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class VisitorList extends StatelessWidget {
  const VisitorList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for visitors - In a real implementation this would come from VisitorController
    final List<Map<String, dynamic>> visitorList = [
      {
        'name': 'Tommy',
        'company': 'PT. Lorem ipsum',
        'destination': 'Gedung HQ',
        'date': 'Mon, 26 June 2025',
        'timeRange': '10:00 - 13:00',
        'avatar': Assets.images.avaPerson1.image(height: 40),
      },
      {
        'name': 'Sarah',
        'company': 'CV Karya Abadi',
        'destination': 'Gedung Operasional',
        'date': 'Tue, 27 June 2025',
        'timeRange': '14:00 - 16:00',
        'avatar': Assets.images.avaPerson2.image(height: 40),
      },
    ];

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Extended Request',
              style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${visitorList.length} requests',
              style: TextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SpaceHeight(10),

        // List of visitor cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visitorList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final visitor = visitorList[index];
            return VisitorCard(
              visitorName: visitor['name'],
              companyName: visitor['company'],
              destination: visitor['destination'],
              date: visitor['date'],
              timeRange: visitor['timeRange'],
              avatar: visitor['avatar'],
              onDeny: () {
                // print('Deny ${visitor['name']}');
              },
              onApprove: () {
                // print('Approve ${visitor['name']}');
              },
            );
          },
        ),
      ],
    );
  }
}
