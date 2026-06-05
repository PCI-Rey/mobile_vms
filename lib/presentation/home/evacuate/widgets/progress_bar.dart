import 'package:flutter/material.dart';
import '../../../../core/helper/responsive_helper.dart';

class ProgressSection extends StatelessWidget {
  final Map<String, dynamic>? groupData;
  final List<Map<String, dynamic>>? allGroups;

  const ProgressSection({super.key, this.groupData, this.allGroups});

  @override
  Widget build(BuildContext context) {
    // Calculate data based on whether it's for a single group or all groups
    late int confirmed;
    late int noReaction;
    late int decline;
    late int total;
    late int expectedTotal;

    if (groupData != null) {
      // Single group data
      confirmed = groupData!['confirmed'] ?? 0;
      noReaction = groupData!['noReaction'] ?? 0;
      decline = groupData!['decline'] ?? 0;
      total = confirmed + noReaction + decline;
      // Assume expected total is 30 for single group (you can make this dynamic)
      expectedTotal = 30;
    } else if (allGroups != null) {
      // All groups combined
      confirmed = 0;
      noReaction = 0;
      decline = 0;

      for (var group in allGroups!) {
        confirmed += (group['confirmed'] as int? ?? 0);
        noReaction += (group['noReaction'] as int? ?? 0);
        decline += (group['decline'] as int? ?? 0);
      }
      total = confirmed + noReaction + decline;
      // Expected total for all groups (you can make this dynamic)
      expectedTotal = 90; // 30 per group * 3 groups
    } else {
      // Default values
      confirmed = 0;
      noReaction = 0;
      decline = 0;
      total = 0;
      expectedTotal = 1;
    }

    // Calculate overall progress percentage
    double overallProgress = expectedTotal > 0 ? total / expectedTotal : 0.0;
    double progressPercentage = overallProgress * 100;

    return Container(
      padding: EdgeInsets.all(rw(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: rw(context, 4),
            offset: Offset(0, rh(context, 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: TextStyle(
              fontSize: rfs(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          vSpace(context, 16),

          // Single overall progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(rw(context, 8)),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: rh(context, 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(rw(context, 8)),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: overallProgress.clamp(0.0, 1.0),
                  child: Container(
                    height: rh(context, 24),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(rw(context, 8)),
                    ),
                    child: Center(
                      child: Text(
                        '${progressPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rfs(context, 12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          vSpace(context, 12),

          // Progress details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Responses: $total of $expectedTotal',
                style: TextStyle(fontSize: rfs(context, 14), color: Colors.grey.shade600),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}% Complete',
                style: TextStyle(
                  fontSize: rfs(context, 14),
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
