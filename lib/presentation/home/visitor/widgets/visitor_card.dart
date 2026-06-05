import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';

enum AlarmStatus { high, medium, low }

class VisitorCard extends StatelessWidget {
  final String visitorName;
  final String alarmDescription;
  final String location;
  final String date;
  final String timeRange;
  final AlarmStatus status;
  final VoidCallback? onDeny;
  final VoidCallback? onApprove;
  final VoidCallback? onTrackVisitor;
  final VoidCallback? onCardTap;

  const VisitorCard({
    super.key,
    required this.visitorName,
    required this.alarmDescription,
    required this.location,
    required this.date,
    required this.timeRange,
    required this.status,
    this.onDeny,
    this.onApprove,
    this.onTrackVisitor,
    this.onCardTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case AlarmStatus.high:
        return Colors.red;
      case AlarmStatus.medium:
        return Colors.orange;
      case AlarmStatus.low:
        return Colors.green;
    }
  }

  String _getStatusText() {
    switch (status) {
      case AlarmStatus.high:
        return 'High';
      case AlarmStatus.medium:
        return 'Medium';
      case AlarmStatus.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(rw(context, 12)),
      child: Container(
        padding: EdgeInsets.all(rw(context, 16)),
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
            // Top section - Alarm icon, title, and date/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Alarm icon
                      Container(
                        width: rw(context, 40),
                        height: rw(context, 40),
                        decoration: BoxDecoration(
                          color: AppColors.primary500,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: rw(context, 20),
                        ),
                      ),
                      hSpace(context, 12),
                      // Alarm info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ALARM ALERT',
                              style: TextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                fontSize: rfs(context, 12),
                              ),
                            ),
                            Text(
                              visitorName,
                              style: TextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: rfs(context, 14)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                hSpace(context, 16),
                // Date and time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(date, style: TextStyles.bodySmall.copyWith(fontSize: rfs(context, 12))),
                    Text(timeRange, style: TextStyles.bodySmall.copyWith(fontSize: rfs(context, 12))),
                  ],
                ),
              ],
            ),

            vSpace(context, 12),

            // Middle section - Description and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alarmDescription, style: TextStyles.bodySmall.copyWith(fontSize: rfs(context, 12))),
                    ],
                  ),
                ),
                hSpace(context, 16),
                // Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                        fontSize: rfs(context, 12),
                      ),
                    ),
                    Text(
                      _getStatusText(),
                      style: TextStyles.bodySmall.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: rfs(context, 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Additional info (if provided)
            vSpace(context, 8),

            // Action buttons (only show if callbacks are provided)
            if (onDeny != null ||
                onApprove != null ||
                onTrackVisitor != null) ...[
              vSpace(context, 16),
              // Deny and Approve buttons
              if (onDeny != null || onApprove != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: rfs(context, 16),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onDeny != null) ...[
                            Button.filledRed(
                              onPressed: onDeny!,
                              label: 'Deny',
                              height: 32,
                              width: 100,
                              fontSize: 12,
                            ),
                            hSpace(context, 8),
                          ],
                          if (onApprove != null)
                            Button.filled(
                              onPressed: onApprove!,
                              label: 'Approve',
                              height: 32,
                              width: 100,
                              fontSize: 12,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

              // Track Visitor button
              if (onTrackVisitor != null) ...[
                vSpace(context, 8),
                Button.filled(
                  onPressed: onTrackVisitor!,
                  label: 'Track Visitor',
                  height: 32,
                  width: double.infinity,
                  fontSize: 12,
                  color: AppColors.info500,
                  textColor: AppColors.grey900,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
