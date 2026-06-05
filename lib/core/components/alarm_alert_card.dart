import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../helper/responsive_helper.dart';

enum AlarmStatus { high, medium, low }

class AlarmAlertCard extends StatelessWidget {
  final String visitorName;
  final String alarmDescription;
  final String location;
  final String date;
  final String timeRange;
  final AlarmStatus status;
  final VoidCallback? onDeny;
  final VoidCallback? onApprove;
  final VoidCallback? onTrackVisitor;

  const AlarmAlertCard({
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
    return Container(
      padding: EdgeInsets.all(rw(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 10)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, rh(context, 4)),
            color: AppColors.primary900.withValues(alpha: 0.07),
            blurRadius: rw(context, 5),
            spreadRadius: rw(context, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALARM ALERT',
                            style: TextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            visitorName,
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              hSpace(context, 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(date, style: TextStyles.bodySmall),
                  Text(timeRange, style: TextStyles.bodySmall),
                ],
              ),
            ],
          ),

          vSpace(context, 12),

          // Middle section
          Row(
            children: [
              Expanded(
                child: Text(alarmDescription, style: TextStyles.bodySmall),
              ),
              hSpace(context, 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Status',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _getStatusText(),
                    style: TextStyles.bodySmall.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          vSpace(context, 8),

          vSpace(context, 16),

          // Location & Approve/Deny buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  location,
                  style: TextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              hSpace(context, 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button.filledRed(
                    onPressed: onDeny ?? () {},
                    label: 'Deny',
                    height: rh(context, 32),
                    width: rw(context, 100),
                    fontSize: rfs(context, 12),
                  ),
                  hSpace(context, 8),
                  Button.filled(
                    onPressed: onApprove ?? () {},
                    label: 'Approve',
                    height: rh(context, 32),
                    width: rw(context, 100),
                    fontSize: rfs(context, 12),
                  ),
                ],
              ),
            ],
          ),

          vSpace(context, 8),

          // Track Visitor button
          Button.filled(
            onPressed: onTrackVisitor ?? () {},
            label: 'Track Visitor',
            height: rh(context, 32),
            width: double.infinity,
            fontSize: rfs(context, 12),
            color: AppColors.info500,
            textColor: AppColors.grey900,
          ),
        ],
      ),
    );
  }
}
