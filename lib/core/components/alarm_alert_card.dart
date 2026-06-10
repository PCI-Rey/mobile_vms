import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../helper/responsive_helper.dart';

enum AlarmStatus { high, medium, low }

class AlarmAlertCard extends StatelessWidget {
  final int index;
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
    this.index = 0,
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
        return const Color(0xFFE53935); // Red
      case AlarmStatus.medium:
        return const Color(0xFFFB8C00); // Orange
      case AlarmStatus.low:
        return const Color(0xFF43A047); // Green
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: rw(context, 10),
            offset: Offset(0, rh(context, 3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              left: rw(context, 16),
              right: rw(context, 16),
              top: rh(context, 16),
              bottom: rh(context, 12),
            ),
            child: Row(
              children: [
                Container(
                  width: rw(context, 26),
                  height: rw(context, 26),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF005596),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                hSpace(context, 10),
                Expanded(
                  child: Text(
                    visitorName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: rfs(context, 16),
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                hSpace(context, 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 8),
                    vertical: rh(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(rw(context, 20)),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Body
          Padding(
            padding: EdgeInsets.only(
              left: rw(context, 16),
              right: rw(context, 16),
              top: rh(context, 12),
              bottom: rh(context, 16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.notifications_active_outlined,
                        'Description',
                        alarmDescription,
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.location_on_outlined,
                        'Location',
                        location,
                      ),
                    ),
                  ],
                ),
                vSpace(context, 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.calendar_today_outlined,
                        'Date',
                        date,
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.access_time_outlined,
                        'Time',
                        timeRange,
                      ),
                    ),
                  ],
                ),
                vSpace(context, 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Button.filledRed(
                        onPressed: () {
                          Get.snackbar(
                            'Success',
                            'Alarm for $visitorName denied successfully',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        label: 'Deny',
                        height: rh(context, 36),
                        fontSize: rfs(context, 12),
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: Button.filled(
                        onPressed: () {
                          Get.snackbar(
                            'Success',
                            'Alarm for $visitorName approved successfully',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        label: 'Approve',
                        height: rh(context, 36),
                        fontSize: rfs(context, 12),
                      ),
                    ),
                  ],
                ),
                vSpace(context, 8),
                Button.filled(
                  onPressed: () {
                    Get.snackbar(
                      'Track Visitor',
                      'Visitor $visitorName is currently at $location',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF005596),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  },
                  label: 'Track Visitor',
                  height: rh(context, 36),
                  width: double.infinity,
                  fontSize: rfs(context, 14),
                  color: const Color(0xFF29B6F6),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardField(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: rw(context, 12), color: Colors.grey.shade400),
        hSpace(context, 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 12),
                  color: Colors.grey.shade500,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: rfs(context, 10),
                        fontWeight: FontWeight.w600,
                        color: color ?? Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (trailing != null) ...[hSpace(context, 4), trailing],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
