import 'package:flutter/material.dart';
import '../../../../core/core.dart';

enum AlertStatus { done, ongoing }

class EvacuateAlertCard extends StatelessWidget {
  final String visitorName;
  final String alarmDescription;
  final String location;
  final String date;
  final String timeRange;
  final AlertStatus status;

  const EvacuateAlertCard({
    super.key,
    required this.visitorName,
    required this.alarmDescription,
    required this.location,
    required this.date,
    required this.timeRange,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case AlertStatus.ongoing:
        return Colors.red;

      case AlertStatus.done:
        return AppColors.success500;
    }
  }

  String _getStatusText() {
    switch (status) {
      case AlertStatus.done:
        return 'Done';
      case AlertStatus.ongoing:
        return 'On Going';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Top section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Assets.icons.evacuationFire.image(height: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EVACUATE ALERT',
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            visitorName,
                            style: TextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SpaceHeight(10),
                          Text(
                            'Confirmed 23 Person',
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w200,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SpaceHeight(10),

                          Text(
                            alarmDescription,
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w200,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(date, style: TextStyles.bodySmall),
                  Text(timeRange, style: TextStyles.bodySmall),
                ],
              ),
            ],
          ),

          const SpaceHeight(12),

          // Middle section
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sebastian',
                  style: TextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Status', style: TextStyles.bodySmall500),
                  const SpaceWidth(5),
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
        ],
      ),
    );
  }
}
