import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'title': 'Notifikasi',
      'date': 'Mon, 16 Jul 2025 10:00',
      'description': 'John Doe triggered a high-risk alarm at Lobby 2.',
      'textColor': AppColors.primary500,
      'backgroundIconColor': AppColors.primary500,
      'backgroundColor': Colors.white,
      'icon': const Icon(FontAwesomeIcons.bell, color: Colors.white, size: 18),
      'notificationType': 'general',
    },
    {
      'id': 2,
      'title': 'Notifikasi Approval',
      'date': 'Mon, 16 Jul 2025 10:00',
      'description': 'An unknown visitor entered the restricted area.',
      'textColor': AppColors.primary500,
      'backgroundColor': Colors.white,
      'backgroundIconColor': AppColors.primary500,
      'icon': const Icon(FontAwesomeIcons.bell, color: Colors.white, size: 18),
      'notificationType': 'general',
    },
    {
      'id': 3,
      'title': 'Notifikasi Alarm',
      'date': 'Mon, 16 Jul 2025 10:00',
      'description': 'Visitor completed scanning successfully.',
      'textColor': AppColors.error500,
      'backgroundIconColor': AppColors.error500,
      'backgroundColor': AppColors.error100,
      'icon': Assets.icons.bell.image(
        width: 18,
        height: 18,
        color: Colors.white,
      ),
      'notificationType': 'alarm',
    },
  ];

  void _handleApprove(int id) {
    debugPrint("✅ Approved $id");
    _removeNotification(id);
  }

  void _handleDeny(int id) {
    debugPrint("❌ Denied $id");
    _removeNotification(id);
  }

  void _removeNotification(int id) {
    setState(() {
      notifications.removeWhere((notif) => notif['id'] == id);
    });
  }

  String selectedType = 'all';

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedType == 'all') return notifications;
    return notifications
        .where((notif) => notif['notificationType'] == selectedType)
        .toList();
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

            vSpace(context, 16),

            // Notification list
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
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
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 16),
                      ),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notif = filteredNotifications[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: rh(context, 12)),
                          child: NotificationCard(
                            title: notif['title'],
                            date: notif['date'],
                            description: notif['description'],
                            backgroundColor: notif['backgroundColor'],
                            textColor: notif['textColor'],
                            backgroundIconColor: notif['backgroundIconColor'],
                            iconData: notif['icon'],
                            primaryActionLabel: 'Approve',
                            secondaryActionLabel: 'Deny',
                            onPrimaryAction: () => _handleApprove(notif['id']),
                            onSecondaryAction: () => _handleDeny(notif['id']),
                          ),
                        );
                      },
                    ),
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
