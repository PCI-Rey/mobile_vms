import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';

class VisitSummaryCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  final bool isSelected;

  const VisitSummaryCard({
    super.key,
    required this.item,
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
          padding: EdgeInsets.all(rw(context, 14)),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(rw(context, 16)),
            border: Border.all(
              color: isSelected ? _blue : Colors.grey.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: rw(context, 10),
                offset: Offset(0, rh(context, 4)),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: rw(context, 44),
                height: rw(context, 44),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FD),
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: _blue,
                  size: rw(context, 22),
                ),
              ),
              hSpace(context, 12),
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
                    vSpace(context, 2),
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
              hSpace(context, 10),
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
                  vSpace(context, 2),
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
                  vSpace(context, 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 8),
                      vertical: rh(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: isCheckin
                          ? const Color(0xFFDCFCE7)
                          : AppColors.primary50,
                      borderRadius: BorderRadius.circular(rw(context, 20)),
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
        ),
      ),
    );
  }
}
