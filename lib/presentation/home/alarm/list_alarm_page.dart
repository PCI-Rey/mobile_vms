import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../../data/models/alarm_model.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import 'controller/alarm_controller.dart';
import '../../auth/controller/user_controller.dart';
import '../invitation/controller/invitation_controller.dart';
import '../../../data/models/approval_ticket_model.dart';
import '../approval/approval_page.dart';
import '../approval/widgets/approve_detail_model.dart';

class AlarmListPage extends StatefulWidget {
  final int initialTab;
  const AlarmListPage({super.key, this.initialTab = 0});

  @override
  State<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage>
    with SingleTickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  late final AlarmController controller;
  late final InvitationController invitationController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    if (Get.isRegistered<AlarmController>()) {
      controller = Get.find<AlarmController>();
    } else {
      controller = Get.put(AlarmController());
    }
    if (Get.isRegistered<InvitationController>()) {
      invitationController = Get.find<InvitationController>();
    } else {
      invitationController = Get.put(InvitationController());
    }
    // Load alarms when page initializes
    controller.loadAlarms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isGuest = _checkIsGuest();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Alarm Alert',
          style: TextStyle(
            fontSize: rfs(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(rw(context, 24)),
              decoration: BoxDecoration(
                color: AppColors.primary50.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                size: rw(context, 48),
                color: AppColors.primary500,
              ),
            ),
            vSpace(context, 24),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: rfs(context, 22),
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
            vSpace(context, 8),
            Text(
              'This Feature Was On Progress',
              style: TextStyle(
                fontSize: rfs(context, 14),
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalTicketList(
    BuildContext context,
    List<ApprovalTicketModel> tickets,
  ) {
    if (tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(rw(context, 20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off,
                size: rw(context, 64),
                color: Colors.grey[400],
              ),
              vSpace(context, 16),
              Text(
                'No pending approvals for today',
                style: TextStyles.bodyLarge.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await invitationController.fetchApprovalTickets();
      },
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: tickets.length,
        separatorBuilder: (context, index) => vSpace(context, 12),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return _buildApprovalCard(
            context,
            ticket,
            index + 1,
            invitationController,
          );
        },
      ),
    );
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

    final cardContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TikTok style avatar / icon
          Container(
            width: rw(context, 40),
            height: rw(context, 40),
            decoration: const BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.badge_outlined,
              color: AppColors.primary500,
              size: rw(context, 20),
            ),
          ),
          hSpace(context, 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: rfs(context, 14),
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: host,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(text: ' requested approval for '),
                      TextSpan(
                        text: agenda,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                vSpace(context, 4),
                Text(
                  '$type • $startStr',
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    color: Colors.grey.shade500,
                  ),
                ),
                if (isPending) ...[
                  vSpace(context, 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => VisitorApprovalDialog.show(
                          context,
                          ticket,
                          controller,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(context, 16),
                            vertical: rh(context, 6),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 8)),
                          ),
                        ),
                        child: Text(
                          'Approve',
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      hSpace(context, 8),
                      OutlinedButton(
                        onPressed: () => _confirmAction(
                          context,
                          title: 'Tolak Approval',
                          message:
                              'Apakah Anda yakin ingin menolak approval ini?',
                          onConfirm: () => controller.rejectMeetingHostAction(
                            approvalTicketId:
                                ticket.approvalTicketId ??
                                ticket.ticketId ??
                                '',
                            actorId: ticket.actorId ?? '',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD32F2F),
                          side: const BorderSide(color: Color(0xFFD32F2F)),
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(context, 16),
                            vertical: rh(context, 6),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 8)),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (isApproved) ...[
                  vSpace(context, 6),
                  Text(
                    '✓ Approved',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (isRejected) ...[
                  vSpace(context, 6),
                  Text(
                    '✗ Rejected',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
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
      onTap: () => ApprovalDetailModal.show(context, ticket),
      child: cardContent,
    );
  }

  Widget _buildTabContent(BuildContext context, String type) {
    return Obx(() {
      if (controller.errorMessage.value != null) {
        return _buildErrorWidget(context, controller.errorMessage.value!);
      }

      final sourceAlarms = controller.filteredAlarms;
      if (sourceAlarms.isEmpty) {
        return _buildAlarmList(context, []);
      }

      // Generate dummy data according to requirements
      List<AlarmModel> alarms = [];
      if (type == 'GENERAL') {
        alarms = List.generate(5, (index) {
          final base = sourceAlarms[index % sourceAlarms.length];
          return base.copyWith(
            id: 'gen_$index',
            alarmDescription: 'General Notification ${index + 1}',
            status: AlarmStatus.low,
          );
        });
      } else if (type == 'ALARM') {
        alarms = List.generate(5, (index) {
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
        alarms = [...gen, ...alr];
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 20.0),
          vertical: rh(context, 16.0),
        ),
        child: _buildAlarmList(context, alarms),
      );
    });
  }

  Widget _buildAlarmList(BuildContext context, List<AlarmModel> alarms) {
    if (alarms.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(rw(context, 20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off,
                size: rw(context, 64),
                color: Colors.grey[400],
              ),
              vSpace(context, 16),
              Text(
                'Tidak ada alarm ditemukan',
                style: TextStyles.bodyLarge.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              vSpace(context, 8),
              Text(
                selectedGedung != null || startDate != null || endDate != null
                    ? 'Coba ubah filter untuk melihat lebih banyak alarm'
                    : 'Belum ada alarm yang tersedia',
                style: TextStyles.bodySmall.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              if (selectedGedung != null ||
                  startDate != null ||
                  endDate != null) ...[
                vSpace(context, 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedGedung = null;
                      startDate = null;
                      endDate = null;
                    });
                    controller.loadAlarms();
                  },
                  icon: Icon(Icons.clear_all, size: rw(context, 16)),
                  label: const Text('Hapus Semua Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 16),
                      vertical: rh(context, 8),
                    ),
                    textStyle: TextStyles.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        controller.loadAlarms();
      },
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: alarms.length,
        separatorBuilder: (context, index) => vSpace(context, 12),
        itemBuilder: (context, index) {
          final alarm = alarms[index];

          return AlarmAlertCard(
            index: index,
            visitorName: alarm.visitorName,
            alarmDescription: alarm.alarmDescription,
            location: alarm.location,
            date: alarm.date,
            timeRange: alarm.timeRange,
            status: alarm.status,
            key: ValueKey('alarm_${alarm.id}_$index'),
            onDeny: (alarm.isDenied == true || alarm.isApproved == true)
                ? null
                : () {
                    _showConfirmationDialog(
                      context,
                      'Deny Alarm',
                      'Apakah Anda yakin ingin menolak alarm dari ${alarm.visitorName}?',
                      () => controller.denyAlarm(alarm.id),
                    );
                  },
            onApprove: (alarm.isDenied == true || alarm.isApproved == true)
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
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(context, 20.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: rw(context, 64),
              color: Colors.red[400],
            ),
            vSpace(context, 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyles.bodyLarge.copyWith(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            vSpace(context, 8),
            Text(
              message,
              style: TextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            vSpace(context, 20),
            ElevatedButton.icon(
              onPressed: () {
                _reloadWithCurrentFilters();
              },
              icon: Icon(Icons.refresh, size: rw(context, 16)),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 20),
                  vertical: rh(context, 12),
                ),
                textStyle: TextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reloadWithCurrentFilters() {
    _applyFilter();
  }

  void _applyFilter() {
    try {
      if (selectedGedung != null || startDate != null || endDate != null) {
        debugPrint(
          'Reloading with filters - Gedung: $selectedGedung, Start: $startDate, End: $endDate',
        );
        controller.loadAlarmsWithFilter(
          startDate: startDate,
          endDate: endDate,
          gedung: selectedGedung,
        );
      } else {
        debugPrint('Reloading all alarms');
        controller.loadAlarms();
      }
    } catch (e) {
      debugPrint('Error in applyFilter: $e');
      controller.loadAlarms();
    }
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
