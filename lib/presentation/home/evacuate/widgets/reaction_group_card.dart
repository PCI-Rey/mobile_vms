import 'package:flutter/material.dart';
import '/../core/core.dart';
import '/../presentation/home/evacuate/detail_group_evacuate.dart';

class ReactionGroupCardFromData extends StatelessWidget {
  final Map<String, dynamic> group;

  const ReactionGroupCardFromData({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailGrupEvacuatePage(groupData: group),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(minWidth: 150),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 6),
              color: AppColors.primary900.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildStatusRow(Colors.green, 'Confirmed', group['confirmed']),
            const SizedBox(height: 8),
            _buildStatusRow(Colors.orange, 'No Reaction', group['noReaction']),
            const SizedBox(height: 8),
            _buildStatusRow(Colors.red, 'Decline', group['decline']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(Color dotColor, String label, int? count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${count ?? 0} Person',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
