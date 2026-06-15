// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import '../../core/components/alarm_alert_card.dart';
import '../../data/models/alarm_model.dart';
import '../home/alarm/controller/alarm_controller.dart';
import '../home/alarm/list_alarm_page.dart';
import '../auth/controller/user_controller.dart';
import 'package:intl/intl.dart';
import '../home/invitation/controller/invitation_controller.dart';
import '../../data/models/approval_ticket_model.dart';
import '../home/approval/approval_page.dart';
import '../home/approval/widgets/approve_detail_model.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  late final AlarmController alarmController;
  late final InvitationController invitationController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AlarmController>()) {
      alarmController = Get.find<AlarmController>();
    } else {
      alarmController = Get.put(AlarmController());
    }
    if (Get.isRegistered<InvitationController>()) {
      invitationController = Get.find<InvitationController>();
    } else {
      invitationController = Get.put(InvitationController());
    }
  }

  bool _checkIsGuest() {
    final user = UserController.to.user.value;
    if (user == null) return true;
    final r = (user.roleAccess ?? 'guest').toLowerCase();
    if (r == 'guest' || r == 'visitor' || r == 'driver') {
      return true;
    }
    if (user.invitationCode != null && user.invitationCode!.isNotEmpty) {
      return true;
    }
    if (user.visitorCode != null && user.visitorCode!.isNotEmpty) {
      return true;
    }
    final employeeRoles = [
      'operator',
      'employee',
      'admin',
      'superadmin',
      'staff',
    ];
    return !employeeRoles.contains(r);
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: rfs(context, 16),
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rw(context, 8)),
              ),
            ),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
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

    return result;
  }

  Widget _buildEmptyState() {
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

  @override
  Widget build(BuildContext context) {
    final isGuest = _checkIsGuest();

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
                vertical: rh(context, 16),
                horizontal: rw(context, 20),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(rw(context, 20)),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: rw(context, 32)),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: rfs(context, 18),
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
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

            // Content Area with soft grey background
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(rw(context, 20)),
                  ),
                ),
                child: Column(
                  children: [
                    vSpace(context, 16),
                    // Filter tabs (Guest only)
                    if (isGuest) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 20),
                        ),
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
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 20),
                                    ),
                                    border: Border.all(
                                      width: 1,
                                      color: selectedType == 'all'
                                          ? AppColors.primary500
                                          : AppColors.grey400,
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
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 20),
                                    ),
                                    border: Border.all(
                                      width: 1,
                                      color: selectedType == 'general'
                                          ? AppColors.primary500
                                          : AppColors.grey400,
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
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 20),
                                    ),
                                    border: Border.all(
                                      width: 1,
                                      color: selectedType == 'alarm'
                                          ? AppColors.primary500
                                          : AppColors.grey400,
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
                    ],

                    // Notification list
                    Expanded(
                      child: Obx(() {
                        if (isGuest) {
                          final alarmsToShow = getAlarmsForType(selectedType);

                          if (alarmsToShow.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              rw(context, 16),
                              0,
                              rw(context, 16),
                              rh(context, 16),
                            ),
                            itemCount: alarmsToShow.length,
                            separatorBuilder: (context, index) =>
                                vSpace(context, 12),
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
                        } else {
                          final pendingTickets = invitationController
                              .approvalTickets
                              .where((t) {
                                final isPending =
                                    (t.approvalActorStatus ?? '')
                                            .toLowerCase() ==
                                        'pending' ||
                                    (t.approvalStatus ?? '').toLowerCase() ==
                                        'pending';
                                return isPending;
                              })
                              .toList();

                          // Sort descending by visitorPeriodStart
                          pendingTickets.sort((a, b) {
                            if (a.visitorPeriodStart == null &&
                                b.visitorPeriodStart == null) {
                              return 0;
                            }
                            if (a.visitorPeriodStart == null) return 1;
                            if (b.visitorPeriodStart == null) return -1;
                            return b.visitorPeriodStart!.compareTo(
                              a.visitorPeriodStart!,
                            );
                          });

                          if (pendingTickets.isEmpty) {
                            return _buildEmptyState();
                          }

                          final displayList = pendingTickets;

                          return ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              rw(context, 16),
                              0,
                              rw(context, 16),
                              rh(context, 16),
                            ),
                            itemCount: displayList.length,
                            separatorBuilder: (context, index) =>
                                vSpace(context, 12),
                            itemBuilder: (context, index) {
                              final ticket = displayList[index];
                              return _buildApprovalCard(
                                context,
                                ticket,
                                index + 1,
                                invitationController,
                              );
                            },
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(
    BuildContext context,
    ApprovalTicketModel ticket,
    int no,
    InvitationController controller,
  ) {
    final start = ticket.visitorPeriodStart;
    final startStr = start != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(start)
        : '-';

    final isPending =
        ticket.approvalActorStatus?.toLowerCase() == 'pending' ||
        ticket.approvalStatus?.toLowerCase() == 'pending';
    final isApproved =
        ticket.approvalActorStatus?.toLowerCase() == 'approved' ||
        ticket.approvalStatus?.toLowerCase() == 'approved';
    final isRejected =
        ticket.approvalActorStatus?.toLowerCase() == 'rejected' ||
        ticket.approvalActorStatus?.toLowerCase() == 'denied' ||
        ticket.approvalStatus?.toLowerCase() == 'rejected' ||
        ticket.approvalStatus?.toLowerCase() == 'denied';

    final host = ticket.hostName ?? 'Unknown Host';
    final agenda = ticket.agenda ?? 'Meeting';
    final type = ticket.visitorTypeName ?? 'Visitor';
    controller.fetchVisitorNameForTicket(ticket);

    return Obx(() {
      final tId = ticket.approvalTicketId ?? ticket.ticketId ?? '';
      final isUnread = controller.unreadTicketIds.contains(tId);

      final cardContent = Container(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 12),
          vertical: rh(context, 12),
        ),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 16)),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: rw(context, 8),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TikTok style avatar / icon
            Stack(
              children: [
                Container(
                  width: rw(context, 46),
                  height: rw(context, 46),
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    color: AppColors.primary500,
                    size: rw(context, 22),
                  ),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: rw(context, 12),
                      height: rw(context, 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            hSpace(context, 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final ticketId =
                        ticket.approvalTicketId ?? ticket.ticketId ?? '';
                    final displayName =
                        controller.ticketVisitorNames[ticketId] ?? host;
                    return RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: rfs(context, 14.5),
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: displayName,
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ' requested approval for ',
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: agenda,
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  vSpace(context, 6),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: rfs(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  vSpace(context, 2),
                  Text(
                    startStr,
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Obx(() {
                    final ticketIdStr =
                        ticket.approvalTicketId ?? ticket.ticketId;
                    final isPostponed =
                        ticketIdStr != null &&
                        controller.postponedTicketIds.contains(ticketIdStr) &&
                        controller.reminderCountdown.value > 0;

                    if (isPostponed) {
                      final mins = controller.reminderCountdown.value ~/ 60;
                      final secs = controller.reminderCountdown.value % 60;
                      final timeStr =
                          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: EdgeInsets.only(top: rh(context, 4)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: rw(context, 14),
                              color: AppColors.primary500,
                            ),
                            hSpace(context, 4),
                            Text(
                              'Will be back on $timeStr',
                              style: TextStyle(
                                fontSize: rfs(context, 12.5),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  if (isApproved) ...[
                    vSpace(context, 6),
                    Text(
                      '✓ Approved',
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (isRejected) ...[
                    vSpace(context, 6),
                    Text(
                      '✗ Rejected',
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        color: const Color(0xFFC62828),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          Get.to(() => const ApprovalPage());
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 16)),
              ),
            ),
            builder: (ctx) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        isUnread
                            ? Icons.mark_email_read_outlined
                            : Icons.mark_email_unread_outlined,
                      ),
                      title: Text(
                        isUnread ? 'Mark As Read' : 'Mark As Not Read',
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (isUnread) {
                          controller.unreadTicketIds.remove(tId);
                        } else {
                          controller.unreadTicketIds.add(tId);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Remind Me'),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (tId.isNotEmpty) {
                          controller.startReminderTimer(30, tId, () {
                            controller.fetchApprovalTickets();
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: cardContent,
      );
    });
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

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final AlarmController alarmController;
  late final InvitationController invitationController;
  String selectedType = 'all';

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AlarmController>()) {
      alarmController = Get.find<AlarmController>();
    } else {
      alarmController = Get.put(AlarmController());
    }
    if (Get.isRegistered<InvitationController>()) {
      invitationController = Get.find<InvitationController>();
    } else {
      invitationController = Get.put(InvitationController());
    }
  }

  bool _checkIsGuest() {
    final user = UserController.to.user.value;
    if (user == null) return true;
    final r = (user.roleAccess ?? 'guest').toLowerCase();
    if (r == 'guest' || r == 'visitor' || r == 'driver') {
      return true;
    }
    if (user.invitationCode != null && user.invitationCode!.isNotEmpty) {
      return true;
    }
    if (user.visitorCode != null && user.visitorCode!.isNotEmpty) {
      return true;
    }
    final employeeRoles = [
      'operator',
      'employee',
      'admin',
      'superadmin',
      'staff',
    ];
    return !employeeRoles.contains(r);
  }

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
    return result;
  }

  Widget _buildEmptyState() {
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

  Widget _buildApprovalCard(
    BuildContext context,
    ApprovalTicketModel ticket,
    int no,
    InvitationController controller,
  ) {
    final start = ticket.visitorPeriodStart;
    final startStr = start != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(start)
        : '-';

    final isApproved =
        ticket.approvalActorStatus?.toLowerCase() == 'approved' ||
        ticket.approvalStatus?.toLowerCase() == 'approved';
    final isRejected =
        ticket.approvalActorStatus?.toLowerCase() == 'rejected' ||
        ticket.approvalActorStatus?.toLowerCase() == 'denied' ||
        ticket.approvalStatus?.toLowerCase() == 'rejected' ||
        ticket.approvalStatus?.toLowerCase() == 'denied';

    final host = ticket.hostName ?? 'Unknown Host';
    final agenda = ticket.agenda ?? 'Meeting';
    final type = ticket.visitorTypeName ?? 'Visitor';
    controller.fetchVisitorNameForTicket(ticket);

    return Obx(() {
      final tId = ticket.approvalTicketId ?? ticket.ticketId ?? '';
      final isUnread = controller.unreadTicketIds.contains(tId);

      final cardContent = Container(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 12),
          vertical: rh(context, 12),
        ),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 16)),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: rw(context, 8),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: rw(context, 46),
                  height: rw(context, 46),
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    color: AppColors.primary500,
                    size: rw(context, 22),
                  ),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: rw(context, 12),
                      height: rw(context, 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            hSpace(context, 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final ticketId =
                        ticket.approvalTicketId ?? ticket.ticketId ?? '';
                    final displayName =
                        controller.ticketVisitorNames[ticketId] ?? host;
                    return RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: rfs(context, 14.5),
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: displayName,
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ' requested approval for ',
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: agenda,
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: TextStyle(
                              fontSize: rfs(context, 14.5),
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  vSpace(context, 6),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: rfs(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  vSpace(context, 2),
                  Text(
                    startStr,
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Obx(() {
                    final ticketIdStr =
                        ticket.approvalTicketId ?? ticket.ticketId;
                    final isPostponed =
                        ticketIdStr != null &&
                        controller.postponedTicketIds.contains(ticketIdStr) &&
                        controller.reminderCountdown.value > 0;

                    if (isPostponed) {
                      final mins = controller.reminderCountdown.value ~/ 60;
                      final secs = controller.reminderCountdown.value % 60;
                      final timeStr =
                          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: EdgeInsets.only(top: rh(context, 4)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: rw(context, 14),
                              color: AppColors.primary500,
                            ),
                            hSpace(context, 4),
                            Text(
                              'Will be back on $timeStr',
                              style: TextStyle(
                                fontSize: rfs(context, 12.5),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  if (isApproved) ...[
                    vSpace(context, 6),
                    Text(
                      '✓ Approved',
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (isRejected) ...[
                    vSpace(context, 6),
                    Text(
                      '✗ Rejected',
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        color: const Color(0xFFC62828),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

      return GestureDetector(
        onTap: () {
          Get.to(() => const ApprovalPage());
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 16)),
              ),
            ),
            builder: (ctx) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        isUnread
                            ? Icons.mark_email_read_outlined
                            : Icons.mark_email_unread_outlined,
                      ),
                      title: Text(
                        isUnread ? 'Mark As Read' : 'Mark As Not Read',
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (isUnread) {
                          controller.unreadTicketIds.remove(tId);
                        } else {
                          controller.unreadTicketIds.add(tId);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Remind Me'),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (tId.isNotEmpty) {
                          controller.startReminderTimer(30, tId, () {
                            controller.fetchApprovalTickets();
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: cardContent,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = _checkIsGuest();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: rfs(context, 20),
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          vSpace(context, 16),
          // Filter tabs (Guest only)
          if (isGuest) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
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
                            color: selectedType == 'all'
                                ? AppColors.primary500
                                : AppColors.grey400,
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
                            color: selectedType == 'general'
                                ? AppColors.primary500
                                : AppColors.grey400,
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
                            color: selectedType == 'alarm'
                                ? AppColors.primary500
                                : AppColors.grey400,
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
          ],
          // Notification list
          Expanded(
            child: Obx(() {
              if (isGuest) {
                final alarmsToShow = getAlarmsForType(selectedType);

                if (alarmsToShow.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    rw(context, 16),
                    0,
                    rw(context, 16),
                    rh(context, 16),
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
              } else {
                final pendingTickets = invitationController.approvalTickets
                    .where((t) {
                      final isPending =
                          (t.approvalActorStatus ?? '').toLowerCase() ==
                              'pending' ||
                          (t.approvalStatus ?? '').toLowerCase() == 'pending';
                      return isPending;
                    })
                    .toList();

                pendingTickets.sort((a, b) {
                  if (a.visitorPeriodStart == null &&
                      b.visitorPeriodStart == null)
                    return 0;
                  if (a.visitorPeriodStart == null) return 1;
                  if (b.visitorPeriodStart == null) return -1;
                  return b.visitorPeriodStart!.compareTo(a.visitorPeriodStart!);
                });

                if (pendingTickets.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    rw(context, 16),
                    0,
                    rw(context, 16),
                    rh(context, 16),
                  ),
                  itemCount: pendingTickets.length,
                  separatorBuilder: (context, index) => vSpace(context, 12),
                  itemBuilder: (context, index) {
                    final ticket = pendingTickets[index];
                    return _buildApprovalCard(
                      context,
                      ticket,
                      index + 1,
                      invitationController,
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
