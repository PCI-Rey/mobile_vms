import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/core.dart';
import 'controller/alarm_controller.dart';
import 'list_alarm_page.dart';

class AlarmList extends StatelessWidget {
  const AlarmList({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject or find controller
    final AlarmController controller = Get.isRegistered<AlarmController>()
        ? Get.find<AlarmController>()
        : Get.put(AlarmController());

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alarm Alerts',
              style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () {
                context.push(const AlarmListPage());
              },
              child: Text(
                'More',
                style: TextStyles.bodySmall500.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),

        const SpaceHeight(10),

        // Obx for reactive UI
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.errorMessage.value != null) {
            return _buildErrorWidget(
              context,
              controller.errorMessage.value!,
              controller,
            );
          }

          return _buildAlarmList(context, controller.alarms, false, controller);
        }),
      ],
    );
  }

  Widget _buildAlarmList(
    BuildContext context,
    List<dynamic> alarms,
    bool isActionLoading,
    AlarmController controller,
  ) {
    // Batasi hanya menampilkan 2 alarm teratas untuk home screen
    final displayAlarms = alarms.take(2).toList();

    if (displayAlarms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.notifications_off, size: 48, color: Colors.grey[400]),
              const SpaceHeight(8),
              Text(
                'Tidak ada alarm saat ini',
                style: TextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayAlarms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alarm = displayAlarms[index];
        // Note: isActionLoading logic might need adjustment if handled per item in controller
        // For simplicity reusing strict boolean for now, or could check controller state

        return AlarmAlertCard(
          visitorName: alarm.visitorName,
          alarmDescription: alarm.alarmDescription,
          location: alarm.location,
          date: alarm.date,
          timeRange: alarm.timeRange,
          status: alarm.status,
          key: ValueKey('alarm_${alarm.id}'),
          onDeny: (alarm.isDenied || alarm.isApproved)
              ? null
              : () {
                  _showConfirmationDialog(
                    context,
                    'Deny Alarm',
                    'Apakah Anda yakin ingin menolak alarm dari ${alarm.visitorName}?',
                    () => controller.denyAlarm(alarm.id),
                  );
                },
          onApprove: (alarm.isDenied || alarm.isApproved)
              ? null
              : () {
                  _showConfirmationDialog(
                    context,
                    'Approve Alarm',
                    'Apakah Anda yakin ingin menyetujui alarm dari ${alarm.visitorName}?',
                    () => controller.approveAlarm(alarm.id),
                  );
                },
          onTrackVisitor: () {
            controller.trackVisitor(alarm.id);
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String message,
    AlarmController controller,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SpaceHeight(8),
            Text(
              'Terjadi Kesalahan',
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SpaceHeight(4),
            Text(
              message,
              style: TextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SpaceHeight(12),
            ElevatedButton.icon(
              onPressed: () {
                controller.loadAlarms();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                textStyle: TextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }
}
