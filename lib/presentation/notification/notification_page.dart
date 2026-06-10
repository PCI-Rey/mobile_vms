import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import '../../core/components/alarm_alert_card.dart';
import '../../data/models/alarm_model.dart';
import '../home/alarm/controller/alarm_controller.dart';
import '../home/alarm/list_alarm_page.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  late final AlarmController alarmController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AlarmController>()) {
      alarmController = Get.find<AlarmController>();
    } else {
      alarmController = Get.put(AlarmController());
    }
  }

  String selectedType = 'all';

  List<AlarmModel> getAlarmsForType(String type) {
    final sourceAlarms = alarmController.alarms;
    if (sourceAlarms.isEmpty) return [];

    List<AlarmModel> result = [];
    if (type == 'general') {
      result = List.generate(5, (index) {
        final base = sourceAlarms[index % sourceAlarms.length];
        return base.copyWith(
          id: 'gen_$index',
          alarmDescription: 'General Notification ${index + 1}',
          status: AlarmStatus.low,
        );
      });
    } else if (type == 'alarm') {
      result = List.generate(5, (index) {
        final base = sourceAlarms[index % sourceAlarms.length];
        return base.copyWith(
          id: 'alr_$index',
          alarmDescription: 'Critical Alert ${index + 1}',
          status: AlarmStatus.high,
        );
      });
    } else {
      final gen = List.generate(5, (index) {
        final base = sourceAlarms[index % sourceAlarms.length];
        return base.copyWith(
          id: 'all_gen_$index',
          alarmDescription: 'General Notification ${index + 1}',
          status: AlarmStatus.low,
        );
      });
      final alr = List.generate(5, (index) {
        final base = sourceAlarms[index % sourceAlarms.length];
        return base.copyWith(
          id: 'all_alr_$index',
          alarmDescription: 'Critical Alert ${index + 1}',
          status: AlarmStatus.high,
        );
      });
      result = [...gen, ...alr];
    }

    // Tampilkan 3 data saja yang paling atas
    return result.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(rw(context, 20)),
      child: Container(
        width: double.infinity,
        height:
            MediaQuery.of(context).size.height * 0.8, // 80% of screen height
        constraints: BoxConstraints(
          maxWidth: rw(context, 500),
          maxHeight: rh(context, 600),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: rh(context, 20),
                horizontal: rw(context, 24),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(rw(context, 20)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: rfs(context, 20),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: rw(context, 32),
                      height: rw(context, 32),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: rw(context, 18),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 24)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = 'all';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 10),
                          vertical: rh(context, 8),
                        ),
                        decoration: BoxDecoration(
                          color: selectedType == 'all'
                              ? AppColors.primary500
                              : Colors.white,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                          border: Border.all(
                            width: 1,
                            color: AppColors.grey400,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'All',
                          style: TextStyle(
                            color: selectedType == 'all'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: rfs(context, 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  hSpace(context, 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = 'general';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 10),
                          vertical: rh(context, 8),
                        ),
                        decoration: BoxDecoration(
                          color: selectedType == 'general'
                              ? AppColors.primary500
                              : Colors.white,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                          border: Border.all(
                            width: 1,
                            color: AppColors.grey400,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'General',
                          style: TextStyle(
                            color: selectedType == 'general'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: rfs(context, 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  hSpace(context, 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = 'alarm';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 10),
                          vertical: rh(context, 8),
                        ),
                        decoration: BoxDecoration(
                          color: selectedType == 'alarm'
                              ? AppColors.primary500
                              : Colors.white,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                          border: Border.all(
                            width: 1,
                            color: AppColors.grey400,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Alarm',
                          style: TextStyle(
                            color: selectedType == 'alarm'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: rfs(context, 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            vSpace(context, 12),

            // More button row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      int initialTab = 0;
                      if (selectedType == 'general') {
                        initialTab = 1;
                      } else if (selectedType == 'alarm') {
                        initialTab = 2;
                      }
                      context.push(AlarmListPage(initialTab: initialTab));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'More',
                          style: TextStyle(
                            color: AppColors.primary500,
                            fontWeight: FontWeight.w600,
                            fontSize: rfs(context, 14),
                          ),
                        ),
                        hSpace(context, 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: rw(context, 12),
                          color: AppColors.primary500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            vSpace(context, 12),

            // Notification list using AlarmAlertCard
            Expanded(
              child: Obx(() {
                final alarmsToShow = getAlarmsForType(selectedType);

                if (alarmsToShow.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: rw(context, 64),
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        vSpace(context, 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: rfs(context, 16),
                            color: Colors.grey.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 16),
                  ),
                  itemCount: alarmsToShow.length,
                  separatorBuilder: (context, index) => vSpace(context, 12),
                  itemBuilder: (context, index) {
                    final alarm = alarmsToShow[index];
                    return AlarmAlertCard(
                      index: index,
                      visitorName: alarm.visitorName,
                      alarmDescription: alarm.alarmDescription,
                      location: alarm.location,
                      date: alarm.date,
                      timeRange: alarm.timeRange,
                      status: alarm.status,
                      key: ValueKey('notif_alarm_${alarm.id}_$index'),
                    );
                  },
                );
              }),
            ),

            // Bottom padding
            vSpace(context, 20),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the notification dialog
void showNotificationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const NotificationDialog(),
  );
}

// Alternative function if you want to show as bottom sheet
void showNotificationBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 20)),
        ),
      ),
      child: const NotificationDialog(),
    ),
  );
}
