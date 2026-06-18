// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/core.dart';
import '../../core/helper/responsive_helper.dart';
import '../auth/controller/language_controller.dart';
import 'invitation/controller/invitation_controller.dart';

class TodayActivityPage extends StatefulWidget {
  const TodayActivityPage({super.key});

  @override
  State<TodayActivityPage> createState() => _TodayActivityPageState();
}

class _TodayActivityPageState extends State<TodayActivityPage> {
  late final InvitationController invitationController;
  late final LanguageController langCtrl;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<InvitationController>()) {
      invitationController = Get.find<InvitationController>();
    } else {
      invitationController = Get.put(InvitationController());
    }
    langCtrl = LanguageController.to;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          final isId = langCtrl.selectedLang.value == 'id';
          final date = invitationController.selectedDashboardDate.value;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          
          final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
          final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
          
          final String titleText;
          if (isToday) {
            titleText = isId ? 'Aktivitas Hari Ini' : 'Activity Today';
          } else if (isYesterday) {
            titleText = isId ? 'Aktivitas Kemarin' : 'Activity Yesterday';
          } else {
            titleText = isId ? 'Aktivitas' : 'Activity';
          }
          return Text(
            titleText,
            style: TextStyle(
              fontSize: rfs(context, 22),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          );
        }),
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(
            color: AppColors.grey300,
            height: rh(context, 1.0),
          ),
        ),
      ),
      body: Obx(() {
        final date = invitationController.selectedDashboardDate.value;
        final isId = langCtrl.selectedLang.value == 'id';
        
        final List<TodayActivityItem> activities = [];

        for (final item in invitationController.todayActivities) {
          final dateStr = item['actionAt']?.toString() ?? item['createdAt']?.toString();
          DateTime timestamp = DateTime.now();
          if (dateStr != null) {
            try {
              String normalized = dateStr;
              final dotIndex = normalized.indexOf('.');
              if (dotIndex != -1) {
                final tIndex = normalized.indexOf('T', dotIndex);
                final zIndex = normalized.indexOf('Z', dotIndex);
                final plusIndex = normalized.indexOf('+', dotIndex);
                int endSubSeconds = normalized.length;
                if (zIndex != -1) endSubSeconds = zIndex;
                else if (plusIndex != -1) endSubSeconds = plusIndex;
                
                final subSecondsStr = normalized.substring(dotIndex + 1, endSubSeconds);
                if (subSecondsStr.length > 6) {
                  final trimmed = subSecondsStr.substring(0, 6);
                  final suffix = endSubSeconds < normalized.length ? normalized.substring(endSubSeconds) : '';
                  normalized = '${normalized.substring(0, dotIndex)}.$trimmed$suffix';
                }
              }
              if (!normalized.endsWith('Z') && !normalized.contains('+')) {
                normalized = '${normalized}Z';
              }
              timestamp = DateTime.parse(normalized).toLocal();
            } catch (e) {
              debugPrint('Error parsing activity timestamp: $e');
            }
          }

          final String action = (item['action']?.toString() ?? '').toLowerCase();
          final String title;
          final IconData icon;
          final Color iconColor;
          final Color bgColor;

          if (action.contains('approve')) {
            title = isId ? 'Persetujuan disetujui' : 'Approval approved';
            icon = Icons.check_circle_outline;
            iconColor = const Color(0xFF43A047);
            bgColor = const Color(0xFFE8F5E9);
          } else if (action.contains('reject') || action.contains('deny')) {
            title = isId ? 'Persetujuan ditolak' : 'Approval rejected';
            icon = Icons.cancel_outlined;
            iconColor = const Color(0xFFD32F2F);
            bgColor = const Color(0xFFFFEBEE);
          } else if (action.contains('password')) {
            title = isId ? 'Ubah Kata Sandi' : 'Change Password';
            icon = Icons.lock_outline;
            iconColor = const Color(0xFF534AB7);
            bgColor = const Color(0xFFF3EEFE);
          } else {
            title = item['action']?.toString() ?? 'Activity';
            icon = Icons.info_outline;
            iconColor = const Color(0xFF1976D2);
            bgColor = const Color(0xFFE8F1FD);
          }

          final description = item['description']?.toString() ?? '';

          activities.add(TodayActivityItem(
            title: title,
            description: description,
            timestamp: timestamp,
            icon: icon,
            iconColor: iconColor,
            bgColor: bgColor,
          ));
        }

        // Sort activities descending by timestamp (newest first)
        activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (activities.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 24),
                vertical: rh(context, 32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: rw(context, 64),
                    color: Colors.grey.shade400,
                  ),
                  vSpace(context, 16),
                  Text(
                    isId ? 'Tidak ada aktivitas hari ini' : 'No activity today',
                    style: TextStyle(
                      fontSize: rfs(context, 15),
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(
            left: rw(context, 16),
            right: rw(context, 16),
            top: rh(context, 16),
            bottom: rh(context, 16) + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: activities.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.shade100,
            indent: rw(context, 76),
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: index == 0 ? const Radius.circular(16) : Radius.zero,
                  topRight: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottomLeft: index == activities.length - 1
                      ? const Radius.circular(16)
                      : Radius.zero,
                  bottomRight: index == activities.length - 1
                      ? const Radius.circular(16)
                      : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.015),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildActivityRow(context, activities[index]),
            );
          },
        );
      }),
    );
  }

  Widget _buildActivityRow(BuildContext context, TodayActivityItem activity) {
    final timeStr = DateFormat('HH:mm').format(activity.timestamp);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(context, 44),
            height: rw(context, 44),
            decoration: BoxDecoration(
              color: activity.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity.icon,
              color: activity.iconColor,
              size: rw(context, 20),
            ),
          ),
          hSpace(context, 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13.5),
                    color: Colors.black87,
                  ),
                ),
                vSpace(context, 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          hSpace(context, 12),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: rfs(context, 12),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class TodayActivityItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  TodayActivityItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
