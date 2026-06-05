import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../detail_group_evacuate.dart';

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
        constraints: BoxConstraints(minWidth: rw(context, 150)),
        padding: EdgeInsets.all(rw(context, 20)),
        margin: EdgeInsets.only(bottom: rh(context, 20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 10)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, rh(context, 6)),
              color: AppColors.primary900.withValues(alpha: 0.1),
              blurRadius: rw(context, 10),
              spreadRadius: rw(context, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['title'] ?? '',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: rfs(context, 16)),
            ),
            vSpace(context, 12),
            _buildStatusRow(context, Colors.green, 'Confirmed', group['confirmed']),
            vSpace(context, 8),
            _buildStatusRow(context, Colors.orange, 'No Reaction', group['noReaction']),
            vSpace(context, 8),
            _buildStatusRow(context, Colors.red, 'Decline', group['decline']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, Color dotColor, String label, int? count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: rw(context, 10),
          height: rw(context, 10),
          margin: EdgeInsets.only(top: rh(context, 5)),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        hSpace(context, 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${count ?? 0} Person',
                style: TextStyle(fontSize: rfs(context, 12), color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
