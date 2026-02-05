import 'package:flutter/material.dart';
import '../../../../core/components/custom_card.dart';
import '../../../../core/core.dart';

class IteneraryList extends StatelessWidget {
  const IteneraryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for visitors
    final List<Map<String, dynamic>> iteneraryList = [
      {
        'title': 'Check In',
        'subtitle': 'Check in Gedung Visitor',
        'image': Assets.icons.pointLocation.image(height: 40),
      },
      {
        'title': 'Parking',
        'subtitle': 'Parking Gedung',
        'image': Assets.icons.mingcuteCarFill.image(height: 40),
      },
    ];

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Iternary',
              style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${iteneraryList.length} requests',
              style: TextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SpaceHeight(10),

        // List of visitor cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: iteneraryList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final visitor = iteneraryList[index];
            return CustomCard(
              backgroundIconColor: AppColors.primary500,
              title: visitor['title'],
              subtitle: visitor['subtitle'],
              image: visitor['image'],
              size: 32,
            );
          },
        ),
      ],
    );
  }
}
