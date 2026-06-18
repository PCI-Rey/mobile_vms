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
          return Text(
            isId ? 'Aktivitas Hari Ini' : 'Activity Today',
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

        // 1. Invitations created today
        for (final item in invitationController.allRawVisitors) {
          if (item.flow.toLowerCase() == 'quickaccessvisit') continue;
          if (item.agenda.isEmpty && item.hostName.isEmpty && item.visitorTypeName.isEmpty) continue;
          
          final createdAt = item.invitationCreatedAt ?? item.visitorPeriodStart;
          if (createdAt.year == date.year &&
              createdAt.month == date.month &&
              createdAt.day == date.day) {
            activities.add(TodayActivityItem(
              title: isId ? 'Undangan dibuat' : 'Invitation created',
              description: item.visitorName.trim().isEmpty ? item.agenda : '${item.visitorName.trim()} - ${item.agenda}',
              timestamp: createdAt,
              icon: Icons.calendar_month_outlined,
              iconColor: const Color(0xFF3B6D11),
              bgColor: const Color(0xFFEAF3DE),
            ));
          }
        }

        // 2. Quick Access created today
        for (final item in invitationController.allRawVisitors) {
          if (item.flow.toLowerCase() != 'quickaccessvisit') continue;
          if (item.agenda.isEmpty && item.hostName.isEmpty && item.visitorTypeName.isEmpty) continue;
          
          final createdAt = item.invitationCreatedAt ?? item.visitorPeriodStart;
          if (createdAt.year == date.year &&
              createdAt.month == date.month &&
              createdAt.day == date.day) {
            activities.add(TodayActivityItem(
              title: isId ? 'Quick Access dibuat' : 'Quick Access created',
              description: item.visitorName.trim().isEmpty ? item.agenda : '${item.visitorName.trim()} - ${item.agenda}',
              timestamp: createdAt,
              icon: Icons.flash_on_rounded,
              iconColor: const Color(0xFFFF9800),
              bgColor: const Color(0xFFFFF4E5),
            ));
          }
        }

        // 3. Share Links created today
        for (final item in invitationController.dashboardShareLinks) {
          final dateStr = item['created_at']?.toString() ??
              item['visitor_period_start']?.toString() ??
              item['expired_at']?.toString();
          if (dateStr != null) {
            try {
              String normalized = dateStr;
              if (!normalized.endsWith('Z') && !normalized.contains('+')) {
                normalized = '${normalized.replaceFirst(' ', 'T')}Z';
              }
              final createdAt = DateTime.parse(normalized).toLocal();
              if (createdAt.year == date.year &&
                  createdAt.month == date.month &&
                  createdAt.day == date.day) {
                activities.add(TodayActivityItem(
                  title: isId ? 'Tautan dibagikan' : 'Link shared',
                  description: '${item['site_place_name'] ?? item['site_name'] ?? 'Gedung'} - ${item['agenda'] ?? ''}',
                  timestamp: createdAt,
                  icon: Icons.add_link,
                  iconColor: const Color(0xFF534AB7),
                  bgColor: const Color(0xFFF3EEFE),
                ));
              }
            } catch (e) {
              debugPrint('Error parsing share link date: $e');
            }
          }
        }

        // 4. Approvals processed today
        for (final ticket in invitationController.approvalTickets) {
          final isPending = (ticket.approvalActorStatus ?? '').toLowerCase() == 'pending' ||
                            (ticket.approvalStatus ?? '').toLowerCase() == 'pending';
          final isApproved = (ticket.approvalActorStatus ?? '').toLowerCase() == 'approved' ||
                             (ticket.approvalStatus ?? '').toLowerCase() == 'approved';
          final isRejected = (ticket.approvalActorStatus ?? '').toLowerCase() == 'rejected' ||
                             (ticket.approvalActorStatus ?? '').toLowerCase() == 'denied' ||
                             (ticket.approvalStatus ?? '').toLowerCase() == 'rejected' ||
                             (ticket.approvalStatus ?? '').toLowerCase() == 'denied';

          if (isPending) {
            final createdAt = ticket.approvalTicketAt;
            if (createdAt != null &&
                createdAt.year == date.year &&
                createdAt.month == date.month &&
                createdAt.day == date.day) {
              activities.add(TodayActivityItem(
                title: isId ? 'Persetujuan diterima' : 'Approval request received',
                description: 'Akses pending untuk ${ticket.hostName ?? 'Visitor'} - ${ticket.agenda ?? ''}',
                timestamp: createdAt,
                icon: Icons.access_time,
                iconColor: const Color(0xFFE65100),
                bgColor: const Color(0xFFFFF3E0),
              ));
            }
          } else if (isApproved) {
            final approvedAt = ticket.approvedAt ?? ticket.approvalTicketAt;
            if (approvedAt != null &&
                approvedAt.year == date.year &&
                approvedAt.month == date.month &&
                approvedAt.day == date.day) {
              activities.add(TodayActivityItem(
                title: isId ? 'Persetujuan disetujui' : 'Approval approved',
                description: 'Akses disetujui untuk ${ticket.hostName ?? 'Visitor'} - ${ticket.agenda ?? ''}',
                timestamp: approvedAt,
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF43A047),
                bgColor: const Color(0xFFE8F5E9),
              ));
            }
          } else if (isRejected) {
            final approvedAt = ticket.approvedAt ?? ticket.approvalTicketAt;
            if (approvedAt != null &&
                approvedAt.year == date.year &&
                approvedAt.month == date.month &&
                approvedAt.day == date.day) {
              activities.add(TodayActivityItem(
                title: isId ? 'Persetujuan ditolak' : 'Approval rejected',
                description: 'Akses ditolak untuk ${ticket.hostName ?? 'Visitor'} - ${ticket.agenda ?? ''}',
                timestamp: approvedAt,
                icon: Icons.cancel_outlined,
                iconColor: const Color(0xFFD32F2F),
                bgColor: const Color(0xFFFFEBEE),
              ));
            }
          }
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
