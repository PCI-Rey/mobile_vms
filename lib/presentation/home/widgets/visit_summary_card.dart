import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';

class VisitSummaryCard extends StatelessWidget {
  final dynamic item;
  final double sw;
  final VoidCallback? onTap;
  final bool isSelected;

  const VisitSummaryCard({
    super.key,
    required this.item,
    required this.sw,
    this.onTap,
    this.isSelected = false,
  });

  static const _blue = Color(0xFF1976D2);

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'status_active'.tr;
      case 'checkin':
        return 'status_checkin'.tr;
      case 'checkout':
        return 'status_checkout'.tr;
      case 'expired':
        return 'status_expired'.tr;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rawStatus = item.visitorStatus.toString().toLowerCase();
    final bool isCheckin = rawStatus == 'checkin';
    final bool isDone = item.isPraregisterDone;

    return GestureDetector(
      onTap: isDone ? onTap : null,
      child: Opacity(
        opacity: isDone ? 1.0 : 0.5,
        child: Container(
          padding: EdgeInsets.all(sw * 0.035),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(
            color: isSelected ? _blue : Colors.grey.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
        children: [
          Container(
            width: sw * 0.112,
            height: sw * 0.112,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FD),
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: _blue,
              size: sw * 0.056,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.agenda,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: rfs(context, 14),
                  ),
                ),
                SizedBox(height: sw * 0.005),
                Text(
                  item.sitePlaceName,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: rfs(context, 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.025),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd MMM').format(item.visitorPeriodStart),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: rfs(context, 12),
                ),
              ),
              SizedBox(height: sw * 0.005),
              Row(
                children: [
                  Text(
                    DateFormat('HH:mm').format(item.visitorPeriodStart),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: rfs(context, 11),
                    ),
                  ),
                  Text(
                    ' – ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: rfs(context, 11),
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(item.visitorPeriodEnd),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: rfs(context, 11),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.01),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCheckin
                      ? const Color(0xFFDCFCE7)
                      : AppColors.primary50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _translateStatus(item.visitorStatus),
                  style: TextStyle(
                    fontSize: rfs(context, 10),
                    fontWeight: FontWeight.bold,
                    color: isCheckin
                        ? const Color(0xFF166534)
                        : AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )));
  }
}
