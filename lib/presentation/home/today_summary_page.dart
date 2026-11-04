import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:excel/excel.dart' as xl;
import '../../core/core.dart';
import '../../core/helper/responsive_helper.dart';
import '../auth/controller/language_controller.dart';
import '../auth/controller/user_controller.dart';
import '../../data/models/access_pass_model.dart';
import '../../data/models/alarm_model.dart';
import '../../data/models/approval_ticket_model.dart';
import '../notification/notification_page.dart';
import 'alarm/controller/alarm_controller.dart';
import 'approval/approval_page.dart';
import 'invitation/controller/invitation_controller.dart';
import 'invitation/send_invitation_page.dart';
import 'new_visitor_page.dart';

class TodaySummaryPage extends StatelessWidget {
  const TodaySummaryPage({super.key});

  InvitationController _getInvitationController() {
    return Get.isRegistered<InvitationController>()
        ? Get.find<InvitationController>()
        : Get.put(InvitationController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final invitationController = _getInvitationController();
    final date = invitationController.selectedDashboardDate.value;
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    final String lang = Get.isRegistered<LanguageController>()
        ? LanguageController.to.selectedLang.value
        : 'id';

    String formatDate(DateTime d) {
      try {
        return DateFormat(
          'EEEE, d MMMM yyyy',
          lang == 'id' ? 'id_ID' : 'en_US',
        ).format(d);
      } catch (e) {
        return DateFormat('EEEE, d MMMM yyyy').format(d);
      }
    }

    // Calculations matching home_page.dart
    final todaySummaryCount = invitationController.visitorTodayCount.value;

    final waitingApprovalCount = invitationController.approvalTickets.where((t) {
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
      final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
      final isRejected = actorStatus == 'rejected' ||
          actorStatus == 'denied' ||
          ticketStatus == 'rejected' ||
          ticketStatus == 'denied';
      final isPending = !isApproved && !isRejected;
      if (!isPending) {
        return false;
      }
      final itemDate = t.visitorPeriodStart;
      if (itemDate == null) {
        return false;
      }
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).length;

    final activeInvitationCount = invitationController.allRawVisitors.where((item) {
      if (item.flow.toLowerCase() == 'quickaccessvisit' ||
          item.visitorStatus.toLowerCase() == 'undercreated' ||
          (item.agenda.trim().isEmpty && item.visitorTypeName.trim().isEmpty) ||
          item.visitorPeriodStart.year < 2000) {
        return false;
      }
      final itemDate = item.visitorPeriodStart;
      if (itemDate.year != date.year ||
          itemDate.month != date.month ||
          itemDate.day != date.day) {
        return false;
      }
      if (item.visitorPeriodEnd.isBefore(DateTime.now())) {
        return false;
      }
      return true;
    }).length;

    int notificationCount = 0;
    final user = UserController.to.user.value;
    bool isGuest = true;
    if (user != null) {
      final r = (user.roleAccess ?? 'guest').toLowerCase();
      if ([
        'operator',
        'employee',
        'admin',
        'superadmin',
        'staff',
      ].contains(r)) {
        isGuest = false;
      }
    }

    if (isGuest) {
      final alarmCtrl = Get.isRegistered<AlarmController>()
          ? Get.find<AlarmController>()
          : Get.put(AlarmController());
      notificationCount = alarmCtrl.alarms.where((alarm) {
        final itemDate = alarm.createdAt;
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      }).length;
    } else {
      notificationCount = invitationController.approvalTickets.where((t) {
        final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
        final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
        final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
        final isRejected = actorStatus == 'rejected' ||
            actorStatus == 'denied' ||
            ticketStatus == 'rejected' ||
            ticketStatus == 'denied';
        final isPending = !isApproved && !isRejected;
        if (!isPending) {
          return false;
        }
        final itemDate = t.visitorPeriodStart;
        if (itemDate == null) {
          return false;
        }
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      }).length;
    }

    final String pageTitle = lang == 'id'
        ? (isToday ? 'Ringkasan Hari Ini' : 'Ringkasan')
        : (isToday ? 'Today Summary' : 'Summary');

    final String tabAll = lang == 'id' ? 'Semua Ringkasan' : 'All Summary';
    final String tabDetail = lang == 'id' ? 'Detail' : 'Detail';
    final String tabHistory = lang == 'id' ? 'Riwayat Aktifitas' : 'Activity Log';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black87),
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pageTitle,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: rfs(context, 24),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(date),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(rh(context, 48)),
            child: Container(
              color: Colors.white,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary600,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: AppColors.primary600,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: EdgeInsets.zero,
                  labelStyle: TextStyle(
                    fontSize: rfs(context, 15),
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: rfs(context, 15),
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: tabAll),
                    Tab(text: tabDetail),
                    Tab(text: tabHistory),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildSemuaRingkasanTab(context, todaySummaryCount, waitingApprovalCount, activeInvitationCount, notificationCount, isGuest, lang, formatDate(date)),
            _buildDetailTab(context, todaySummaryCount, waitingApprovalCount, activeInvitationCount, notificationCount, isGuest, lang),
            _buildRiwayatAktifitasTab(context, lang, formatDate(date), formatDate(date.subtract(const Duration(days: 1)))),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: ALL SUMMARY (SEMUA RINGKASAN) ---
  Widget _buildSemuaRingkasanTab(
    BuildContext context,
    int visitorCount,
    int approvalCount,
    int invitationCount,
    int notificationCount,
    bool isGuest,
    String lang,
    String formattedDate,
  ) {
    final bool isIndo = lang == 'id';

    final String labelVisitor = isIndo ? 'Visitor Hari Ini' : 'Visitor Today';
    final String labelApproval = isIndo ? 'Menunggu Persetujuan' : 'Waiting Approval';
    final String labelInvitation = isIndo ? 'Undangan Aktif' : 'Active Invitation';
    final String labelAlarm = isIndo ? 'Notifikasi Aktif' : 'Active Notification';

    final String unitPeople = isIndo ? 'Orang' : 'People';
    final String unitReq = isIndo ? 'Permintaan' : 'Request(s)';
    final String unitInv = isIndo ? 'Undangan' : 'Invitation(s)';
    final String unitAlarm = isIndo ? 'Notifikasi' : 'Notification(s)';

    // Compute dynamic breakdown stats for Tab 1
    final invitationController = _getInvitationController();
    final date = invitationController.selectedDashboardDate.value;

    final todayVisitorsList = invitationController.getTodayVisitors();
    final int checkedOutCount = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkout').length;

    final dateInvitations = invitationController.allRawVisitors.where((item) {
      if (item.flow.toLowerCase() == 'quickaccessvisit' ||
          item.visitorStatus.toLowerCase() == 'undercreated' ||
          (item.agenda.trim().isEmpty && item.visitorTypeName.trim().isEmpty) ||
          item.visitorPeriodStart.year < 2000) {
        return false;
      }
      final itemDate = item.visitorPeriodStart;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();
    final int expiredInvitationCount = dateInvitations.where((item) => item.visitorPeriodEnd.isBefore(DateTime.now())).length;
    final activeInvitationsList = dateInvitations.where((item) => !item.visitorPeriodEnd.isBefore(DateTime.now())).toList();

    final alarmCtrl = Get.isRegistered<AlarmController>()
        ? Get.find<AlarmController>()
        : Get.put(AlarmController());
    final dateAlarms = alarmCtrl.alarms.where((alarm) {
      final itemDate = alarm.createdAt;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();
    final int resolvedAlarmCount = dateAlarms.where((a) => a.isApproved || a.isDenied).length;

    final dateTickets = invitationController.approvalTickets.where((t) {
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
      final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
      final isRejected = actorStatus == 'rejected' ||
          actorStatus == 'denied' ||
          ticketStatus == 'rejected' ||
          ticketStatus == 'denied';
      final isPending = !isApproved && !isRejected;
      if (!isPending) {
        return false;
      }
      final itemDate = t.visitorPeriodStart;
      if (itemDate == null) {
        return false;
      }
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();

    final String descVisitor = isIndo ? 'Jumlah visitor yang datang hari ini' : 'Total visitors arriving today';
    final String descApproval = isIndo ? 'Permintaan akses yang menunggu persetujuan' : 'Access requests waiting for approval';
    final String descInvitation = isIndo ? 'Undangan yang masih aktif' : 'Active visitor invitations';
    final String descAlarm = isIndo ? 'Notifikasi yang sedang aktif' : 'Active notifications';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: rw(context, 20),
        right: rw(context, 20),
        top: rw(context, 20),
        bottom: rw(context, 20) + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2x2 Grid of Main Cards (Tap opens full page)
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridCard(
                  context,
                  labelVisitor,
                  '$visitorCount',
                  unitPeople,
                  Icons.people,
                  const Color(0xFF1976D2),
                  onTap: () => context.push(const NewVisitorPage()),
                ),
              ),
              hSpace(context, 12),
              Expanded(
                child: _buildSummaryGridCard(
                  context,
                  labelApproval,
                  '$approvalCount',
                  unitReq,
                  Icons.access_time,
                  const Color(0xFFF57C00),
                  onTap: () => context.push(const ApprovalPage()),
                ),
              ),
            ],
          ),
          vSpace(context, 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridCard(
                  context,
                  labelInvitation,
                  '$invitationCount',
                  unitInv,
                  Icons.mail_outline,
                  const Color(0xFF43A047),
                  onTap: () => context.push(const SendInvitationPage()),
                ),
              ),
              hSpace(context, 12),
              Expanded(
                child: _buildSummaryGridCard(
                  context,
                  labelAlarm,
                  '$notificationCount',
                  unitAlarm,
                  Icons.notifications_none,
                  const Color(0xFFE53935),
                  onTap: () => context.push(const NotificationPage()),
                ),
              ),
            ],
          ),

          vSpace(context, 24),
          Divider(color: Colors.grey.shade300, thickness: 1),
          vSpace(context, 16),

          // Flat list representation with description (Tap opens bottom sheet popup)
          _buildSummaryListTile(
            context,
            labelVisitor,
            '$visitorCount $unitPeople',
            descVisitor,
            Icons.people,
            const Color(0xFF1976D2),
            onTap: () => _showVisitorTodayPopup(context, todayVisitorsList, lang),
          ),
          _buildSummaryListTile(
            context,
            labelApproval,
            '$approvalCount $unitReq',
            descApproval,
            Icons.access_time,
            const Color(0xFFF57C00),
            onTap: () => _showWaitingApprovalPopup(context, dateTickets, lang),
          ),
          _buildSummaryListTile(
            context,
            labelInvitation,
            '$invitationCount $unitInv',
            descInvitation,
            Icons.mail_outline,
            const Color(0xFF43A047),
            onTap: () => _showActiveInvitationPopup(context, activeInvitationsList, lang),
          ),
          _buildSummaryListTile(
            context,
            labelAlarm,
            '$notificationCount $unitAlarm',
            descAlarm,
            Icons.notifications_none,
            const Color(0xFFE53935),
            onTap: () => _showActiveAlarmPopup(context, dateAlarms, isGuest, dateTickets, lang),
          ),

          vSpace(context, 24),

          // Summary Period
          Text(
            isIndo ? 'Periode Ringkasan' : 'Summary Period',
            style: TextStyle(
              fontSize: rfs(context, 14),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          vSpace(context, 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: rw(context, 16), vertical: rh(context, 14)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rw(context, 8)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Color(0xFF1976D2)),
                hSpace(context, 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: rfs(context, 14),
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          vSpace(context, 16),

          // Export Button
          SizedBox(
            width: double.infinity,
            height: rh(context, 44),
            child: ElevatedButton.icon(
              onPressed: () => _exportSummaryToExcel(context, lang, date),
              icon: const Icon(Icons.file_download_outlined, color: Colors.white),
              label: Text(
                isIndo ? 'Ekspor Ringkasan' : 'Export Summary',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 8)),
                ),
              ),
            ),
          ),

          vSpace(context, 24),

          // Breakdown Section Card
          Container(
            padding: EdgeInsets.all(rw(context, 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rw(context, 12)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBreakdownItem(context, labelVisitor, '$visitorCount $unitPeople', true),
                _buildBreakdownItem(context, isIndo ? 'Visitor Sudah Check-out' : 'Visitors Checked Out', '$checkedOutCount $unitPeople', false),
                _buildBreakdownItem(context, labelApproval, '$approvalCount $unitReq', true),
                _buildBreakdownItem(context, labelInvitation, '$invitationCount $unitInv', true),
                _buildBreakdownItem(context, isIndo ? 'Undangan Kadaluarsa' : 'Expired Invitations', '$expiredInvitationCount $unitInv', false),
                _buildBreakdownItem(context, labelAlarm, '$notificationCount $unitAlarm', true),
                _buildBreakdownItem(context, isIndo ? 'Notifikasi Selesai' : 'Resolved Notifications', '$resolvedAlarmCount $unitAlarm', false),
              ],
            ),
          ),

          vSpace(context, 24),

          // Info Alert Card
          _buildInfoBanner(
            context,
            isIndo
                ? 'Data ringkasan diperbarui secara real-time. Terakhir diperbarui pada $formattedDate, 14:42 WIB.'
                : 'Summary data is updated in real-time. Last updated on $formattedDate at 02:42 PM.',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGridCard(
    BuildContext context,
    String title,
    String count,
    String unit,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(rw(context, 16)),
        child: Ink(
          padding: EdgeInsets.all(rw(context, 16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rw(context, 16)),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(rw(context, 8)),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: rw(context, 20)),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: rfs(context, 10),
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              vSpace(context, 12),
              Text(
                count,
                style: TextStyle(
                  fontSize: rfs(context, 26),
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              vSpace(context, 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: rfs(context, 12),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryListTile(
    BuildContext context,
    String title,
    String value,
    String desc,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rw(context, 12)),
          child: Ink(
            padding: EdgeInsets.all(rw(context, 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rw(context, 12)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(rw(context, 10)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: rw(context, 20)),
                ),
                hSpace(context, 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: rfs(context, 14),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          hSpace(context, 8),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      vSpace(context, 4),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                hSpace(context, 8),
                Icon(
                  Icons.chevron_right,
                  size: rw(context, 20),
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- BOTTOM SHEET POPUPS FOR 4 LIST TILES ---

  void _showSummaryBottomSheet({
    required BuildContext context,
    required String title,
    required String countBadge,
    required IconData headerIcon,
    required Color themeColor,
    required String actionButtonText,
    required VoidCallback onActionTap,
    required Widget content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(rw(bottomSheetContext, 20)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: rw(bottomSheetContext, 40),
                height: rh(bottomSheetContext, 4),
                margin: EdgeInsets.only(
                  top: rh(bottomSheetContext, 12),
                  bottom: rh(bottomSheetContext, 8),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(bottomSheetContext, 20),
                vertical: rh(bottomSheetContext, 10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(rw(bottomSheetContext, 8)),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      headerIcon,
                      color: themeColor,
                      size: rw(bottomSheetContext, 18),
                    ),
                  ),
                  hSpace(bottomSheetContext, 10),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: rfs(bottomSheetContext, 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        hSpace(bottomSheetContext, 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(bottomSheetContext, 8),
                            vertical: rh(bottomSheetContext, 2),
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(rw(bottomSheetContext, 12)),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            countBadge,
                            style: TextStyle(
                              fontSize: rfs(bottomSheetContext, 11),
                              fontWeight: FontWeight.w700,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(bottomSheetContext).pop(),
                    child: Container(
                      width: rw(bottomSheetContext, 30),
                      height: rw(bottomSheetContext, 30),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: rw(bottomSheetContext, 16),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // Content
            Flexible(
              child: content,
            ),

            // Bottom Action Button
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(bottomSheetContext, 20),
                  rh(bottomSheetContext, 10),
                  rw(bottomSheetContext, 20),
                  rh(bottomSheetContext, 14),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: rh(bottomSheetContext, 44),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      onActionTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(bottomSheetContext, 10)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          actionButtonText,
                          style: TextStyle(
                            fontSize: rfs(bottomSheetContext, 14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        hSpace(bottomSheetContext, 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalEmptyState(BuildContext context, IconData icon, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 24),
          vertical: rh(context, 36),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: rw(context, 54),
              color: Colors.grey.shade300,
            ),
            vSpace(context, 12),
            Text(
              message,
              style: TextStyle(
                fontSize: rfs(context, 14),
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showVisitorTodayPopup(BuildContext context, List<AccessPassModel> visitors, String lang) {
    final bool isIndo = lang == 'id';
    _showSummaryBottomSheet(
      context: context,
      title: isIndo ? 'Visitor Hari Ini' : 'Visitor Today',
      countBadge: '${visitors.length} ${isIndo ? 'Orang' : 'People'}',
      headerIcon: Icons.people,
      themeColor: const Color(0xFF1976D2),
      actionButtonText: isIndo ? 'Buka Visitor Active' : 'Open Visitor Active',
      onActionTap: () => context.push(const NewVisitorPage()),
      content: visitors.isEmpty
          ? _buildModalEmptyState(
              context,
              Icons.people_outline_rounded,
              isIndo ? 'Tidak ada data visitor aktif hari ini' : 'No active visitors today',
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 20),
                vertical: rh(context, 14),
              ),
              shrinkWrap: true,
              itemCount: visitors.length,
              separatorBuilder: (_, __) => vSpace(context, 10),
              itemBuilder: (ctx, index) => _buildVisitorModalItem(ctx, visitors[index], index),
            ),
    );
  }

  Widget _buildVisitorModalItem(BuildContext context, AccessPassModel visitor, int index) {
    final initials = visitor.visitorName.trim().isNotEmpty
        ? visitor.visitorName.trim()[0].toUpperCase()
        : 'V';
    final colors = [
      const Color(0xFF1976D2), // Blue
      const Color(0xFF388E3C), // Green
      const Color(0xFFD32F2F), // Red
      const Color(0xFFF57C00), // Orange
      const Color(0xFF7B1FA2), // Purple
    ];
    final color = colors[index % colors.length];

    final status = visitor.visitorStatus.toLowerCase().trim();
    Color bg;
    Color fg;
    String displayStatus;
    if (status == 'checkin') {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
      displayStatus = 'Checked In';
    } else if (status == 'checkout') {
      bg = const Color(0xFFE8EAF6);
      fg = const Color(0xFF283593);
      displayStatus = 'Checked Out';
    } else if (status == 'pending' || status == 'waiting') {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFEF6C00);
      displayStatus = 'Pending';
    } else if (status == 'reject' || status == 'rejected' || status == 'denied') {
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFC62828);
      displayStatus = 'Rejected';
    } else {
      bg = const Color(0xFFE0F7FA);
      fg = const Color(0xFF006064);
      displayStatus = visitor.visitorStatus.isNotEmpty
          ? (visitor.visitorStatus[0].toUpperCase() + visitor.visitorStatus.substring(1))
          : 'Active';
    }

    final timeStr = DateFormat('HH:mm').format(visitor.invitationCreatedAt ?? visitor.visitorPeriodStart);
    final org = visitor.visitorOrganizationName.isNotEmpty
        ? visitor.visitorOrganizationName
        : (visitor.hostName.isNotEmpty ? 'Host: ${visitor.hostName}' : '-');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: rw(context, 40),
            height: rw(context, 40),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 15),
                ),
              ),
            ),
          ),
          hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.visitorName.isNotEmpty ? visitor.visitorName : 'Visitor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13),
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 3),
                Text(
                  org,
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          hSpace(context, 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 8),
                  vertical: rh(context, 3),
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
              ),
              vSpace(context, 4),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: rfs(context, 10.5),
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWaitingApprovalPopup(BuildContext context, List<ApprovalTicketModel> tickets, String lang) {
    final bool isIndo = lang == 'id';
    _showSummaryBottomSheet(
      context: context,
      title: isIndo ? 'Menunggu Persetujuan' : 'Waiting Approval',
      countBadge: '${tickets.length} ${isIndo ? 'Permintaan' : 'Request(s)'}',
      headerIcon: Icons.access_time,
      themeColor: const Color(0xFFF57C00),
      actionButtonText: isIndo ? 'Buka Halaman Persetujuan' : 'Open Approval Page',
      onActionTap: () => context.push(const ApprovalPage()),
      content: tickets.isEmpty
          ? _buildModalEmptyState(
              context,
              Icons.fact_check_outlined,
              isIndo ? 'Tidak ada permintaan menunggu persetujuan' : 'No requests waiting for approval',
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 20),
                vertical: rh(context, 14),
              ),
              shrinkWrap: true,
              itemCount: tickets.length,
              separatorBuilder: (_, __) => vSpace(context, 10),
              itemBuilder: (ctx, index) => _buildApprovalModalItem(ctx, tickets[index], index),
            ),
    );
  }

  Widget _buildApprovalModalItem(BuildContext context, ApprovalTicketModel ticket, int index) {
    final title = (ticket.agenda != null && ticket.agenda!.trim().isNotEmpty)
        ? ticket.agenda!
        : (ticket.visitorTypeName != null && ticket.visitorTypeName!.trim().isNotEmpty)
            ? ticket.visitorTypeName!
            : 'Access Request #${index + 1}';
    final host = (ticket.hostName != null && ticket.hostName!.trim().isNotEmpty)
        ? ticket.hostName!
        : (ticket.hostOrganizationName != null && ticket.hostOrganizationName!.trim().isNotEmpty)
            ? ticket.hostOrganizationName!
            : '-';
    final start = ticket.visitorPeriodStart;
    final timeStr = start != null ? DateFormat('dd MMM yyyy, HH:mm').format(start) : '-';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(context, 40),
            height: rw(context, 40),
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fact_check_outlined,
              color: const Color(0xFFF57C00),
              size: rw(context, 20),
            ),
          ),
          hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13),
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 3),
                Text(
                  'Host: $host',
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 2),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          hSpace(context, 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 8),
              vertical: rh(context, 3),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(rw(context, 12)),
              border: Border.all(color: const Color(0xFFFFB74D), width: 1),
            ),
            child: Text(
              'Pending',
              style: TextStyle(
                fontSize: rfs(context, 10.5),
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActiveInvitationPopup(BuildContext context, List<AccessPassModel> invitations, String lang) {
    final bool isIndo = lang == 'id';
    _showSummaryBottomSheet(
      context: context,
      title: isIndo ? 'Undangan Aktif' : 'Active Invitation',
      countBadge: '${invitations.length} ${isIndo ? 'Undangan' : 'Invitation(s)'}',
      headerIcon: Icons.mail_outline,
      themeColor: const Color(0xFF43A047),
      actionButtonText: isIndo ? 'Buka Halaman Undangan' : 'Open Invitation Page',
      onActionTap: () => context.push(const SendInvitationPage()),
      content: invitations.isEmpty
          ? _buildModalEmptyState(
              context,
              Icons.mail_outline,
              isIndo ? 'Tidak ada undangan aktif saat ini' : 'No active invitations currently',
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 20),
                vertical: rh(context, 14),
              ),
              shrinkWrap: true,
              itemCount: invitations.length,
              separatorBuilder: (_, __) => vSpace(context, 10),
              itemBuilder: (ctx, index) => _buildInvitationModalItem(ctx, invitations[index], index),
            ),
    );
  }

  Widget _buildInvitationModalItem(BuildContext context, AccessPassModel invitation, int index) {
    final title = invitation.agenda.trim().isNotEmpty
        ? invitation.agenda
        : (invitation.visitorTypeName.trim().isNotEmpty
            ? invitation.visitorTypeName
            : 'Invitation #${index + 1}');
    final host = invitation.hostName.trim().isNotEmpty
        ? invitation.hostName
        : (invitation.invitedByName.trim().isNotEmpty
            ? invitation.invitedByName
            : (invitation.host.trim().isNotEmpty ? invitation.host : '-'));
    final startStr = DateFormat('dd MMM, HH:mm').format(invitation.visitorPeriodStart);
    final endStr = DateFormat('HH:mm').format(invitation.visitorPeriodEnd);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(context, 40),
            height: rw(context, 40),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mail_outline,
              color: const Color(0xFF43A047),
              size: rw(context, 20),
            ),
          ),
          hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13),
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 3),
                Text(
                  'Host: $host',
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 2),
                Text(
                  '$startStr - $endStr',
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          hSpace(context, 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 8),
              vertical: rh(context, 3),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(rw(context, 12)),
              border: Border.all(color: const Color(0xFF81C784), width: 1),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                fontSize: rfs(context, 10.5),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActiveAlarmPopup(
    BuildContext context,
    List<AlarmModel> alarms,
    bool isGuest,
    List<ApprovalTicketModel> tickets,
    String lang,
  ) {
    final bool isIndo = lang == 'id';
    final int count = isGuest ? alarms.length : (alarms.isNotEmpty ? alarms.length : tickets.length);
    _showSummaryBottomSheet(
      context: context,
      title: isIndo ? 'Notifikasi Aktif' : 'Active Notification',
      countBadge: '$count ${isIndo ? 'Notifikasi' : 'Notification(s)'}',
      headerIcon: Icons.notifications_none,
      themeColor: const Color(0xFFE53935),
      actionButtonText: isIndo ? 'Buka Halaman Notifikasi' : 'Open Notification Page',
      onActionTap: () => context.push(const NotificationPage()),
      content: count == 0
          ? _buildModalEmptyState(
              context,
              Icons.notifications_none,
              isIndo ? 'Tidak ada notifikasi aktif' : 'No active notifications',
            )
          : (alarms.isNotEmpty
              ? ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 20),
                    vertical: rh(context, 14),
                  ),
                  shrinkWrap: true,
                  itemCount: alarms.length,
                  separatorBuilder: (_, __) => vSpace(context, 10),
                  itemBuilder: (ctx, index) => _buildAlarmModalItem(ctx, alarms[index], index),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 20),
                    vertical: rh(context, 14),
                  ),
                  shrinkWrap: true,
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => vSpace(context, 10),
                  itemBuilder: (ctx, index) => _buildApprovalModalItem(ctx, tickets[index], index),
                )),
    );
  }

  Widget _buildAlarmModalItem(BuildContext context, AlarmModel alarm, int index) {
    final title = alarm.alarmDescription.trim().isNotEmpty
        ? alarm.alarmDescription
        : (alarm.visitorName.trim().isNotEmpty ? alarm.visitorName : 'Notification #${index + 1}');
    final loc = alarm.location.trim().isNotEmpty ? alarm.location : 'Site Area';
    final timeStr = '${alarm.date} ${alarm.timeRange}';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(context, 40),
            height: rw(context, 40),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: const Color(0xFFE53935),
              size: rw(context, 20),
            ),
          ),
          hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13),
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 3),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        loc,
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                vSpace(context, 2),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          hSpace(context, 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 8),
              vertical: rh(context, 3),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(rw(context, 12)),
              border: Border.all(color: const Color(0xFFE57373), width: 1),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                fontSize: rfs(context, 10.5),
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(BuildContext context, String title, String value, bool isHeader) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(context, 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: DETAIL BREAKDOWN ---
  Widget _buildDetailTab(
    BuildContext context,
    int visitorCount,
    int approvalCount,
    int invitationCount,
    int notificationCount,
    bool isGuest,
    String lang,
  ) {
    final bool isIndo = lang == 'id';

    // Compute approval ticket details dynamically
    final invitationController = _getInvitationController();
    final date = invitationController.selectedDashboardDate.value;
    final dateTickets = invitationController.approvalTickets.where((t) {
      final itemDate = t.visitorPeriodStart;
      if (itemDate == null) {
        return false;
      }
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();

    final int totalRequests = dateTickets.length;
    final int awaitingApproval = dateTickets.where((t) =>
        (t.approvalActorStatus ?? '').toLowerCase() == 'pending' ||
        (t.approvalStatus ?? '').toLowerCase() == 'pending').length;
    final int approved = dateTickets.where((t) {
      final status = (t.approvalStatus ?? '').toLowerCase();
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      return status == 'approved' || status == 'success' || actorStatus == 'approved' || actorStatus == 'success';
    }).length;
    final int rejected = dateTickets.where((t) {
      final status = (t.approvalStatus ?? '').toLowerCase();
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      return status == 'rejected' || status == 'reject' || actorStatus == 'rejected' || actorStatus == 'reject';
    }).length;

    // Compute visitor stats dynamically
    final todayVisitorsList = invitationController.getTodayVisitors();
    final int totalTodayVisitors = todayVisitorsList.length;
    final int checkedInToday = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkin' || v.visitorStatus.toLowerCase() == 'checkout').length;
    final int checkedOutToday = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkout').length;
    final int notCheckedInToday = totalTodayVisitors - checkedInToday;
    final int stillOnSiteToday = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkin').length;

    // Compute active invitation details dynamically
    final dateInvitations = invitationController.allRawVisitors.where((item) {
      if (item.flow.toLowerCase() == 'quickaccessvisit' ||
          item.visitorStatus.toLowerCase() == 'undercreated' ||
          (item.agenda.trim().isEmpty && item.visitorTypeName.trim().isEmpty) ||
          item.visitorPeriodStart.year < 2000) {
        return false;
      }
      final itemDate = item.visitorPeriodStart;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();

    final int activeInvitations = dateInvitations.where((item) => !item.visitorPeriodEnd.isBefore(DateTime.now())).length;
    final int expiredInvitations = dateInvitations.where((item) => item.visitorPeriodEnd.isBefore(DateTime.now())).length;
    final int expiringSoonInvitations = dateInvitations.where((item) {
      final now = DateTime.now();
      if (item.visitorPeriodEnd.isBefore(now)) {
        return false;
      }
      final diff = item.visitorPeriodEnd.difference(now);
      return diff.inDays <= 3;
    }).length;

    // Compute alarm counts dynamically
    final alarmCtrl = Get.isRegistered<AlarmController>()
        ? Get.find<AlarmController>()
        : Get.put(AlarmController());
    final dateAlarms = alarmCtrl.alarms.where((alarm) {
      final itemDate = alarm.createdAt;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();

    final int totalActiveAlarms = dateAlarms.length;
    final int highPriorityAlarms = dateAlarms.where((a) => a.status == AlarmStatus.high).length;
    final int mediumPriorityAlarms = dateAlarms.where((a) => a.status == AlarmStatus.medium).length;
    final int lowPriorityAlarms = dateAlarms.where((a) => a.status == AlarmStatus.low).length;

    final String labelVisitor = isIndo ? 'Visitor Hari Ini' : 'Visitor Today';
    final String labelApproval = isIndo ? 'Menunggu Persetujuan' : 'Waiting Approval';
    final String labelInvitation = isIndo ? 'Undangan Aktif' : 'Active Invitation';
    final String labelAlarm = isIndo ? 'Notifikasi Aktif' : 'Active Notification';

    final String unitPeople = isIndo ? 'Orang' : 'People';
    final String unitReq = isIndo ? 'Permintaan' : 'Request(s)';
    final String unitInv = isIndo ? 'Undangan' : 'Invitation(s)';
    final String unitAlarm = isIndo ? 'Notifikasi' : 'Notification(s)';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: rw(context, 20),
        right: rw(context, 20),
        top: rw(context, 20),
        bottom: rw(context, 20) + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // 1. Visitor Breakdown
          _buildDetailCategoryCard(
            context,
            icon: Icons.people,
            title: labelVisitor,
            color: const Color(0xFF1976D2),
            rows: [
              _buildDetailRow(context, isIndo ? 'Total Visitor' : 'Total Visitors', '$totalTodayVisitors $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Sudah Check-in' : 'Checked In', '$checkedInToday $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Belum Check-in' : 'Not Checked In', '$notCheckedInToday $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Sudah Check-out' : 'Checked Out', '$checkedOutToday $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Masih Berada Di Lokasi' : 'Still In Location', '$stillOnSiteToday $unitPeople'),
            ],
          ),

          // 2. Waiting Approval Breakdown
          _buildDetailCategoryCard(
            context,
            icon: Icons.access_time,
            title: labelApproval,
            color: const Color(0xFFF57C00),
            rows: [
              _buildDetailRow(context, isIndo ? 'Total Permintaan' : 'Total Requests', '$totalRequests $unitReq'),
              _buildDetailRow(context, isIndo ? 'Menunggu Persetujuan' : 'Awaiting Approval', '$awaitingApproval $unitReq'),
              _buildDetailRow(context, isIndo ? 'Disetujui' : 'Approved', '$approved $unitReq'),
              _buildDetailRow(context, isIndo ? 'Ditolak' : 'Rejected', '$rejected $unitReq'),
            ],
          ),

          // 3. Active Invitation Breakdown
          _buildDetailCategoryCard(
            context,
            icon: Icons.mail_outline,
            title: labelInvitation,
            color: const Color(0xFF43A047),
            rows: [
              _buildDetailRow(context, isIndo ? 'Total Undangan Aktif' : 'Total Active Invitations', '$activeInvitations $unitInv'),
              _buildDetailRow(context, isIndo ? 'Akan Kadaluarsa (≤ 3 hari)' : 'Expiring Soon (≤ 3 days)', '$expiringSoonInvitations $unitInv'),
              _buildDetailRow(context, isIndo ? 'Kadaluarsa' : 'Expired', '$expiredInvitations $unitInv'),
            ],
          ),

          // 4. Alarm Breakdown
          _buildDetailCategoryCard(
            context,
            icon: Icons.notifications_none,
            title: labelAlarm,
            color: const Color(0xFFE53935),
            rows: [
              _buildDetailRow(context, isIndo ? 'Total Notifikasi Aktif' : 'Total Active Notifications', '$totalActiveAlarms $unitAlarm'),
              _buildDetailRow(context, isIndo ? 'Prioritas Tinggi' : 'High Priority', '$highPriorityAlarms $unitAlarm'),
              _buildDetailRow(context, isIndo ? 'Prioritas Sedang' : 'Medium Priority', '$mediumPriorityAlarms $unitAlarm'),
              _buildDetailRow(context, isIndo ? 'Prioritas Rendah' : 'Low Priority', '$lowPriorityAlarms $unitAlarm'),
            ],
          ),

          vSpace(context, 16),

          // Info Alert Card
          _buildInfoBanner(
            context,
            isIndo
                ? 'Data detail diperbarui secara real-time. Terakhir diperbarui beberapa saat yang lalu.'
                : 'Detailed data is updated in real-time. Last updated moments ago.',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> rows,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: EdgeInsets.all(rw(context, 16)),
            child: Row(
              children: [
                Icon(icon, color: color, size: rw(context, 20)),
                hSpace(context, 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: rfs(context, 15),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade200, height: 1),
          // Details list
          Padding(
            padding: EdgeInsets.all(rw(context, 16)),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(context, 6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: rfs(context, 13), 
              color: Colors.grey.shade700,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: ACTIVITY HISTORY (RIWAYAT AKTIFITAS) ---
  Widget _buildRiwayatAktifitasTab(
    BuildContext context,
    String lang,
    String todayStr,
    String yesterdayStr,
  ) {
    final bool isIndo = lang == 'id';
    final String labelFilter = isIndo ? 'Semua Aktivitas' : 'All Activities';

    final invitationController = _getInvitationController();
    final date = invitationController.selectedDashboardDate.value;

    final List<_ActivityItem> activities = [];

    // 1. Visitors Check-in / Check-out
    final todayVisitorsList = invitationController.getTodayVisitors();
    for (final v in todayVisitorsList) {
      final statusLower = v.visitorStatus.toLowerCase();
      if (statusLower == 'checkin' || statusLower == 'checkout') {
        activities.add(_ActivityItem(
          icon: Icons.login,
          titleIndo: 'Visitor Check-in',
          titleEng: 'Visitor Check-in',
          time: DateFormat('HH:mm').format(v.visitorPeriodStart),
          subtitle: v.visitorName,
          timestamp: v.visitorPeriodStart,
        ));
      }
      if (statusLower == 'checkout') {
        activities.add(_ActivityItem(
          icon: Icons.logout,
          titleIndo: 'Visitor Check-out',
          titleEng: 'Visitor Check-out',
          time: DateFormat('HH:mm').format(v.visitorPeriodEnd),
          subtitle: v.visitorName,
          timestamp: v.visitorPeriodEnd,
        ));
      }
    }

    // 2. Invitations Created
    final dateInvitations = invitationController.allRawVisitors.where((item) {
      if (item.flow.toLowerCase() == 'quickaccessvisit' ||
          item.visitorStatus.toLowerCase() == 'undercreated' ||
          (item.agenda.trim().isEmpty && item.visitorTypeName.trim().isEmpty) ||
          item.visitorPeriodStart.year < 2000) {
        return false;
      }
      final itemDate = item.visitorPeriodStart;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();
    for (final inv in dateInvitations) {
      if (inv.agenda.trim().isEmpty) continue;
      final createTime = inv.invitationCreatedAt ?? inv.visitorPeriodStart;
      activities.add(_ActivityItem(
        icon: Icons.note_add_outlined,
        titleIndo: 'Undangan Dibuat',
        titleEng: 'Invitation Created',
        time: DateFormat('HH:mm').format(createTime),
        subtitle: inv.agenda,
        timestamp: createTime,
      ));
    }

    // 3. Approval Requests
    final dateTickets = invitationController.approvalTickets.where((t) {
      final itemDate = t.visitorPeriodStart;
      if (itemDate == null) {
        return false;
      }
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();
    for (final ticket in dateTickets) {
      final status = (ticket.approvalStatus ?? '').toLowerCase();
      final actorStatus = (ticket.approvalActorStatus ?? '').toLowerCase();
      final timestamp = ticket.approvedAt ?? ticket.approvalTicketAt ?? ticket.visitorPeriodStart ?? DateTime.now();
      
      if (status == 'approved' || status == 'success' || actorStatus == 'approved' || actorStatus == 'success') {
        activities.add(_ActivityItem(
          icon: Icons.check_circle_outline,
          titleIndo: 'Permintaan Disetujui',
          titleEng: 'Request Approved',
          time: DateFormat('HH:mm').format(timestamp),
          subtitle: ticket.agenda ?? 'Request',
          timestamp: timestamp,
        ));
      } else if (status == 'rejected' || status == 'reject' || actorStatus == 'rejected' || actorStatus == 'reject') {
        activities.add(_ActivityItem(
          icon: Icons.cancel_outlined,
          titleIndo: 'Permintaan Ditolak',
          titleEng: 'Request Rejected',
          time: DateFormat('HH:mm').format(timestamp),
          subtitle: ticket.agenda ?? 'Request',
          timestamp: timestamp,
        ));
      } else {
        activities.add(_ActivityItem(
          icon: Icons.access_time,
          titleIndo: 'Menunggu Persetujuan',
          titleEng: 'Awaiting Approval',
          time: DateFormat('HH:mm').format(timestamp),
          subtitle: ticket.agenda ?? 'Request',
          timestamp: timestamp,
        ));
      }
    }

    // 4. Alarms
    final alarmCtrl = Get.isRegistered<AlarmController>()
        ? Get.find<AlarmController>()
        : Get.put(AlarmController());
    final dateAlarms = alarmCtrl.alarms.where((alarm) {
      final itemDate = alarm.createdAt;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();
    for (final alarm in dateAlarms) {
      final String badgeIndo = alarm.status == AlarmStatus.high
          ? 'Tinggi'
          : alarm.status == AlarmStatus.medium
              ? 'Sedang'
              : 'Rendah';
      final String badgeEng = alarm.status == AlarmStatus.high
          ? 'High'
          : alarm.status == AlarmStatus.medium
              ? 'Medium'
              : 'Low';

      activities.add(_ActivityItem(
        icon: Icons.warning_amber_rounded,
        titleIndo: 'Alarm Aktif',
        titleEng: 'Active Alarm',
        time: DateFormat('HH:mm').format(alarm.createdAt),
        subtitle: '${alarm.alarmDescription} - ${alarm.location}',
        badgeIndo: badgeIndo,
        badgeEng: badgeEng,
        timestamp: alarm.createdAt,
      ));

      if (alarm.isApproved || alarm.isDenied) {
        activities.add(_ActivityItem(
          icon: Icons.check_circle,
          titleIndo: 'Alarm Selesai',
          titleEng: 'Alarm Cleared',
          time: DateFormat('HH:mm').format(alarm.createdAt.add(const Duration(minutes: 5))),
          subtitle: '${alarm.alarmDescription} - ${alarm.location}',
          timestamp: alarm.createdAt.add(const Duration(minutes: 5)),
        ));
      }
    }

    // Sort descending by timestamp
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: rw(context, 20),
        right: rw(context, 20),
        top: rw(context, 20),
        bottom: rw(context, 20) + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: rw(context, 16), vertical: rh(context, 10)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rw(context, 8)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  labelFilter,
                  style: TextStyle(
                    fontSize: rfs(context, 14),
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          vSpace(context, 24),

          // Group 1: Selected Date
          _buildActivityGroupHeader(context, '${isIndo ? 'Daftar Aktivitas' : 'Activity Log'} - $todayStr'),
          if (activities.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rh(context, 40)),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade400),
                    vSpace(context, 8),
                    Text(
                      isIndo ? 'Tidak ada riwayat aktivitas' : 'No activity logs found',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: rfs(context, 14)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activities.map((act) => _buildActivityTile(
                  context,
                  act.icon,
                  isIndo ? act.titleIndo : act.titleEng,
                  act.time,
                  act.subtitle,
                  isIndo ? act.badgeIndo : act.badgeEng,
                )),

          vSpace(context, 24),

          // Info Alert Card
          _buildInfoBanner(
            context,
            isIndo
                ? 'Riwayat aktivitas menampilkan aktivitas real-time hari ini.'
                : 'Activity log shows real-time events for today.',
          ),
        ],
      ),
    );
  }



  Widget _buildActivityGroupHeader(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 12)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: rfs(context, 14),
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildActivityTile(
    BuildContext context,
    IconData icon,
    String title,
    String time,
    String subtitle,
    String? badgeLabel,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(context, 12)),
      padding: EdgeInsets.all(rw(context, 14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(rw(context, 8)),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8FD),
              borderRadius: BorderRadius.circular(rw(context, 8)),
            ),
            child: Icon(icon, color: const Color(0xFF1976D2), size: rw(context, 18)),
          ),
          hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                vSpace(context, 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeLabel != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: rw(context, 8), vertical: rh(context, 2)),
                        decoration: BoxDecoration(
                          color: badgeLabel == 'Tinggi' || badgeLabel == 'High'
                              ? Colors.red.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(rw(context, 4)),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: rfs(context, 9),
                            fontWeight: FontWeight.bold,
                            color: badgeLabel == 'Tinggi' || badgeLabel == 'High'
                                ? Colors.red.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSummaryToExcel(
    BuildContext context,
    String lang,
    DateTime date,
  ) async {
    final bool isIndo = lang == 'id';
    final invitationController = _getInvitationController();
    final alarmCtrl = Get.isRegistered<AlarmController>()
        ? Get.find<AlarmController>()
        : Get.put(AlarmController());

    final formatDate = DateFormat('yyyy-MM-dd').format(date);
    final String filename = 'summary_report_$formatDate.xlsx';

    try {
      // 1. Show exporting SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(isIndo ? "Mengekspor data ke Excel..." : "Exporting summary to Excel..."),
            ],
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      // 2. Gather Stats (similar to what's inside Tab 1 / Tab 2)
      final todayVisitorsList = invitationController.getTodayVisitors();
      final int totalTodayVisitors = todayVisitorsList.length;
      final int checkedInToday = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkin' || v.visitorStatus.toLowerCase() == 'checkout').length;
      final int checkedOutToday = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkout').length;
      final int notCheckedInToday = totalTodayVisitors - checkedInToday;
      final int stillOnSiteToday = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkin').length;

      final dateTickets = invitationController.approvalTickets.where((t) {
        final itemDate = t.visitorPeriodStart;
        if (itemDate == null) {
          return false;
        }
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      }).toList();
      final int totalRequests = dateTickets.length;
      final int awaitingApproval = dateTickets.where((t) {
        return (t.approvalActorStatus ?? '').toLowerCase() == 'pending' ||
            (t.approvalStatus ?? '').toLowerCase() == 'pending';
      }).length;
      final int approved = dateTickets.where((t) {
        final status = (t.approvalStatus ?? '').toLowerCase();
        final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
        return status == 'approved' || status == 'success' || actorStatus == 'approved' || actorStatus == 'success';
      }).toList().length;
      final int rejected = dateTickets.where((t) {
        final status = (t.approvalStatus ?? '').toLowerCase();
        final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
        return status == 'rejected' || status == 'reject' || actorStatus == 'rejected' || actorStatus == 'reject';
      }).toList().length;

      final dateInvitations = invitationController.allRawVisitors.where((item) {
        if (item.flow.toLowerCase() == 'quickaccessvisit' ||
            item.visitorStatus.toLowerCase() == 'undercreated' ||
            (item.agenda.trim().isEmpty && item.visitorTypeName.trim().isEmpty) ||
            item.visitorPeriodStart.year < 2000) {
          return false;
        }
        final itemDate = item.visitorPeriodStart;
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      }).toList();
      final int activeInvitations = dateInvitations.where((item) {
        return !item.visitorPeriodEnd.isBefore(DateTime.now());
      }).length;
      final int expiredInvitations = dateInvitations.where((item) {
        return item.visitorPeriodEnd.isBefore(DateTime.now());
      }).length;
      final int expiringSoonInvitations = dateInvitations.where((item) {
        final now = DateTime.now();
        if (item.visitorPeriodEnd.isBefore(now)) {
          return false;
        }
        final diff = item.visitorPeriodEnd.difference(now);
        return diff.inDays <= 3;
      }).length;

      final dateAlarms = alarmCtrl.alarms.where((alarm) {
        final itemDate = alarm.createdAt;
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      }).toList();
      final int totalActiveAlarms = dateAlarms.length;
      final int highPriorityAlarms = dateAlarms.where((a) => a.status == AlarmStatus.high).length;
      final int mediumPriorityAlarms = dateAlarms.where((a) => a.status == AlarmStatus.medium).length;
      final int lowPriorityAlarms = dateAlarms.where((a) => a.status == AlarmStatus.low).length;

      // 3. Compile Activities (similar to Tab 3)
      final List<_ActivityItem> activities = [];

      // 3.1. Visitors Check-in / Check-out
      for (final v in todayVisitorsList) {
        final statusLower = v.visitorStatus.toLowerCase();
        if (statusLower == 'checkin' || statusLower == 'checkout') {
          activities.add(_ActivityItem(
            icon: Icons.login,
            titleIndo: 'Visitor Check-in',
            titleEng: 'Visitor Check-in',
            time: DateFormat('HH:mm').format(v.visitorPeriodStart),
            subtitle: v.visitorName,
            timestamp: v.visitorPeriodStart,
          ));
        }
        if (statusLower == 'checkout') {
          activities.add(_ActivityItem(
            icon: Icons.logout,
            titleIndo: 'Visitor Check-out',
            titleEng: 'Visitor Check-out',
            time: DateFormat('HH:mm').format(v.visitorPeriodEnd),
            subtitle: v.visitorName,
            timestamp: v.visitorPeriodEnd,
          ));
        }
      }

      // 3.2. Invitations Created
      for (final inv in dateInvitations) {
        if (inv.agenda.trim().isEmpty) continue;
        final createTime = inv.invitationCreatedAt ?? inv.visitorPeriodStart;
        activities.add(_ActivityItem(
          icon: Icons.note_add_outlined,
          titleIndo: 'Undangan Dibuat',
          titleEng: 'Invitation Created',
          time: DateFormat('HH:mm').format(createTime),
          subtitle: inv.agenda,
          timestamp: createTime,
        ));
      }

      // 3.3. Approval Requests
      for (final ticket in dateTickets) {
        final status = (ticket.approvalStatus ?? '').toLowerCase();
        final actorStatus = (ticket.approvalActorStatus ?? '').toLowerCase();
        final timestamp = ticket.approvedAt ?? ticket.approvalTicketAt ?? ticket.visitorPeriodStart ?? DateTime.now();
        
        if (status == 'approved' || status == 'success' || actorStatus == 'approved' || actorStatus == 'success') {
          activities.add(_ActivityItem(
            icon: Icons.check_circle_outline,
            titleIndo: 'Permintaan Disetujui',
            titleEng: 'Request Approved',
            time: DateFormat('HH:mm').format(timestamp),
            subtitle: ticket.agenda ?? 'Request',
            timestamp: timestamp,
          ));
        } else if (status == 'rejected' || status == 'reject' || actorStatus == 'rejected' || actorStatus == 'reject') {
          activities.add(_ActivityItem(
            icon: Icons.cancel_outlined,
            titleIndo: 'Permintaan Ditolak',
            titleEng: 'Request Rejected',
            time: DateFormat('HH:mm').format(timestamp),
            subtitle: ticket.agenda ?? 'Request',
            timestamp: timestamp,
          ));
        } else {
          activities.add(_ActivityItem(
            icon: Icons.access_time,
            titleIndo: 'Menunggu Persetujuan',
            titleEng: 'Awaiting Approval',
            time: DateFormat('HH:mm').format(timestamp),
            subtitle: ticket.agenda ?? 'Request',
            timestamp: timestamp,
          ));
        }
      }

      // 3.4. Alarms
      for (final alarm in dateAlarms) {
        final String badgeIndo = alarm.status == AlarmStatus.high
            ? 'Tinggi'
            : alarm.status == AlarmStatus.medium
                ? 'Sedang'
                : 'Rendah';
        final String badgeEng = alarm.status == AlarmStatus.high
            ? 'High'
            : alarm.status == AlarmStatus.medium
                ? 'Medium'
                : 'Low';

        activities.add(_ActivityItem(
          icon: Icons.warning_amber_rounded,
          titleIndo: 'Alarm Aktif',
          titleEng: 'Active Alarm',
          time: DateFormat('HH:mm').format(alarm.createdAt),
          subtitle: '${alarm.alarmDescription} - ${alarm.location}',
          badgeIndo: badgeIndo,
          badgeEng: badgeEng,
          timestamp: alarm.createdAt,
        ));

        if (alarm.isApproved || alarm.isDenied) {
          activities.add(_ActivityItem(
            icon: Icons.check_circle,
            titleIndo: 'Alarm Selesai',
            titleEng: 'Alarm Cleared',
            time: DateFormat('HH:mm').format(alarm.createdAt.add(const Duration(minutes: 5))),
            subtitle: '${alarm.alarmDescription} - ${alarm.location}',
            timestamp: alarm.createdAt.add(const Duration(minutes: 5)),
          ));
        }
      }

      // Sort descending by timestamp
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 4. Build Excel Object
      final xl.Excel excelObj = xl.Excel.createExcel();

      // Rename default sheet to 'Today Visitor List'
      final String defaultSheet = excelObj.getDefaultSheet() ?? 'Sheet1';
      final String sheet1Name = isIndo ? 'Today Visitor List' : 'Today Visitor List';
      final String sheet2Name = isIndo ? 'Today Approval List' : 'Today Approval List';
      final String sheet3Name = isIndo ? 'Today Invitation List' : 'Today Invitation List';
      final String sheet4Name = isIndo ? 'Today Notification List' : 'Today Notification List';

      excelObj.rename(defaultSheet, sheet1Name);

      final xl.Sheet sheet1 = excelObj[sheet1Name];
      final xl.Sheet sheet2 = excelObj[sheet2Name];
      final xl.Sheet sheet3 = excelObj[sheet3Name];
      final xl.Sheet sheet4 = excelObj[sheet4Name];

      // Custom Styles
      final visitorBannerStyle = xl.CellStyle(
        bold: true,
        fontSize: 13,
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: xl.ExcelColor.fromHexString('#1976D2'), // Blue
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final approvalBannerStyle = xl.CellStyle(
        bold: true,
        fontSize: 13,
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: xl.ExcelColor.fromHexString('#F57C00'), // Orange
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final invitationBannerStyle = xl.CellStyle(
        bold: true,
        fontSize: 13,
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: xl.ExcelColor.fromHexString('#2E7D32'), // Green
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final alarmBannerStyle = xl.CellStyle(
        bold: true,
        fontSize: 13,
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: xl.ExcelColor.fromHexString('#D32F2F'), // Red
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final tableHeaderStyle = xl.CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: xl.ExcelColor.fromHexString('#37474F'), // Blue Grey Dark
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final metaLabelStyle = xl.CellStyle(
        bold: true,
        fontSize: 10,
        fontColorHex: xl.ExcelColor.fromHexString('#333333'),
        backgroundColorHex: xl.ExcelColor.fromHexString('#EEEEEE'),
        horizontalAlign: xl.HorizontalAlign.Left,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final metaValueStyle = xl.CellStyle(
        fontSize: 10,
        fontColorHex: xl.ExcelColor.fromHexString('#111111'),
        horizontalAlign: xl.HorizontalAlign.Left,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final normalCenter = xl.CellStyle(
        fontSize: 10,
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      );

      final normalLeft = xl.CellStyle(
        fontSize: 10,
        horizontalAlign: xl.HorizontalAlign.Left,
        verticalAlign: xl.VerticalAlign.Center,
      );

      void writeCell(xl.Sheet sheet, int col, int row, xl.CellValue value, xl.CellStyle style) {
        final cell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
        cell.value = value;
        cell.cellStyle = style;
      }

      // ==========================================
      // SHEET 1: TODAY VISITOR LIST
      // ==========================================
      sheet1.setColumnWidth(0, 8.0);
      sheet1.setColumnWidth(1, 28.0);
      sheet1.setColumnWidth(2, 28.0);
      sheet1.setColumnWidth(3, 20.0);
      sheet1.setColumnWidth(4, 25.0);
      sheet1.setColumnWidth(5, 20.0);
      sheet1.setColumnWidth(6, 30.0);
      sheet1.setColumnWidth(7, 20.0);
      sheet1.setColumnWidth(8, 20.0);
      sheet1.setColumnWidth(9, 18.0);

      // Title Banner A1:J1
      sheet1.merge(
        xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        xl.CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0),
      );
      for (int i = 0; i <= 9; i++) {
        final cell = sheet1.cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        if (i == 0) {
          cell.value = xl.TextCellValue(isIndo ? 'LAPORAN VISITOR HARI INI (TODAY VISITOR LIST)' : 'TODAY VISITOR LIST REPORT');
        }
        cell.cellStyle = visitorBannerStyle;
      }

      // KPI Metadata
      writeCell(sheet1, 0, 2, xl.TextCellValue(isIndo ? 'Tanggal Laporan:' : 'Report Date:'), metaLabelStyle);
      writeCell(sheet1, 1, 2, xl.TextCellValue(formatDate), metaValueStyle);
      writeCell(sheet1, 3, 2, xl.TextCellValue(isIndo ? 'Total Visitor:' : 'Total Visitors:'), metaLabelStyle);
      writeCell(sheet1, 4, 2, xl.IntCellValue(totalTodayVisitors), metaValueStyle);

      writeCell(sheet1, 0, 3, xl.TextCellValue(isIndo ? 'Sudah Check-In:' : 'Checked In:'), metaLabelStyle);
      writeCell(sheet1, 1, 3, xl.IntCellValue(checkedInToday), metaValueStyle);
      writeCell(sheet1, 3, 3, xl.TextCellValue(isIndo ? 'Sudah Check-Out:' : 'Checked Out:'), metaLabelStyle);
      writeCell(sheet1, 4, 3, xl.IntCellValue(checkedOutToday), metaValueStyle);

      writeCell(sheet1, 0, 4, xl.TextCellValue(isIndo ? 'Belum Check-In:' : 'Waiting:'), metaLabelStyle);
      writeCell(sheet1, 1, 4, xl.IntCellValue(notCheckedInToday), metaValueStyle);
      writeCell(sheet1, 3, 4, xl.TextCellValue(isIndo ? 'Di Dalam Gedung:' : 'Still On Site:'), metaLabelStyle);
      writeCell(sheet1, 4, 4, xl.IntCellValue(stillOnSiteToday), metaValueStyle);

      // Table Header Row 6
      final visitorHeaders = [
        'No',
        isIndo ? 'Nama Visitor' : 'Visitor Name',
        isIndo ? 'Instansi / Organisasi' : 'Organization',
        isIndo ? 'Tipe Visitor' : 'Visitor Type',
        isIndo ? 'Host (PIC BI)' : 'Host PIC',
        isIndo ? 'Satker Host' : 'Host Dept',
        isIndo ? 'Agenda / Keperluan' : 'Agenda',
        isIndo ? 'Mulai Kunjungan' : 'Period Start',
        isIndo ? 'Selesai Kunjungan' : 'Period End',
        'Status',
      ];
      for (int i = 0; i < visitorHeaders.length; i++) {
        writeCell(sheet1, i, 6, xl.TextCellValue(visitorHeaders[i]), tableHeaderStyle);
      }

      int s1Row = 7;
      if (todayVisitorsList.isEmpty) {
        sheet1.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: s1Row),
          xl.CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: s1Row),
          customValue: xl.TextCellValue(isIndo ? 'Tidak ada data visitor hari ini' : 'No visitors today'),
        );
        writeCell(sheet1, 0, s1Row, xl.TextCellValue(isIndo ? 'Tidak ada data visitor hari ini' : 'No visitors today'), normalCenter);
      } else {
        int no = 1;
        for (final v in todayVisitorsList) {
          final start = DateFormat('yyyy-MM-dd HH:mm').format(v.visitorPeriodStart);
          final end = DateFormat('yyyy-MM-dd HH:mm').format(v.visitorPeriodEnd);
          final org = v.visitorOrganizationName.isNotEmpty ? v.visitorOrganizationName : '-';
          final hostDept = v.hostOrganizationName.isNotEmpty ? v.hostOrganizationName : '-';
          final agenda = v.agenda.isNotEmpty ? v.agenda : '-';

          writeCell(sheet1, 0, s1Row, xl.IntCellValue(no++), normalCenter);
          writeCell(sheet1, 1, s1Row, xl.TextCellValue(v.visitorName.isNotEmpty ? v.visitorName : '-'), normalLeft);
          writeCell(sheet1, 2, s1Row, xl.TextCellValue(org), normalLeft);
          writeCell(sheet1, 3, s1Row, xl.TextCellValue(v.visitorTypeName.isNotEmpty ? v.visitorTypeName : '-'), normalCenter);
          writeCell(sheet1, 4, s1Row, xl.TextCellValue(v.hostName.isNotEmpty ? v.hostName : '-'), normalLeft);
          writeCell(sheet1, 5, s1Row, xl.TextCellValue(hostDept), normalCenter);
          writeCell(sheet1, 6, s1Row, xl.TextCellValue(agenda), normalLeft);
          writeCell(sheet1, 7, s1Row, xl.TextCellValue(start), normalCenter);
          writeCell(sheet1, 8, s1Row, xl.TextCellValue(end), normalCenter);
          writeCell(sheet1, 9, s1Row, xl.TextCellValue(v.visitorStatus.isNotEmpty ? v.visitorStatus : '-'), normalCenter);
          s1Row++;
        }
      }

      // ==========================================
      // SHEET 2: TODAY APPROVAL LIST
      // ==========================================
      sheet2.setColumnWidth(0, 8.0);
      sheet2.setColumnWidth(1, 25.0);
      sheet2.setColumnWidth(2, 28.0);
      sheet2.setColumnWidth(3, 25.0);
      sheet2.setColumnWidth(4, 20.0);
      sheet2.setColumnWidth(5, 20.0);
      sheet2.setColumnWidth(6, 20.0);
      sheet2.setColumnWidth(7, 18.0);

      // Title Banner A1:H1
      sheet2.merge(
        xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        xl.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0),
      );
      for (int i = 0; i <= 7; i++) {
        final cell = sheet2.cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        if (i == 0) {
          cell.value = xl.TextCellValue(isIndo ? 'DAFTAR PERSETUJUAN HARI INI (TODAY APPROVAL LIST)' : 'TODAY APPROVAL LIST REPORT');
        }
        cell.cellStyle = approvalBannerStyle;
      }

      // KPI Metadata
      writeCell(sheet2, 0, 2, xl.TextCellValue(isIndo ? 'Tanggal Laporan:' : 'Report Date:'), metaLabelStyle);
      writeCell(sheet2, 1, 2, xl.TextCellValue(formatDate), metaValueStyle);
      writeCell(sheet2, 3, 2, xl.TextCellValue(isIndo ? 'Total Permintaan:' : 'Total Requests:'), metaLabelStyle);
      writeCell(sheet2, 4, 2, xl.IntCellValue(totalRequests), metaValueStyle);

      writeCell(sheet2, 0, 3, xl.TextCellValue(isIndo ? 'Menunggu Approval:' : 'Pending:'), metaLabelStyle);
      writeCell(sheet2, 1, 3, xl.IntCellValue(awaitingApproval), metaValueStyle);
      writeCell(sheet2, 3, 3, xl.TextCellValue(isIndo ? 'Disetujui:' : 'Approved:'), metaLabelStyle);
      writeCell(sheet2, 4, 3, xl.IntCellValue(approved), metaValueStyle);

      writeCell(sheet2, 0, 4, xl.TextCellValue(isIndo ? 'Ditolak:' : 'Rejected:'), metaLabelStyle);
      writeCell(sheet2, 1, 4, xl.IntCellValue(rejected), metaValueStyle);

      // Table Header Row 6
      final approvalHeaders = [
        'No',
        'Agenda',
        isIndo ? 'Nama Pengaju / Tamu' : 'Applicant / Visitor',
        isIndo ? 'Host (PIC BI)' : 'Host PIC',
        isIndo ? 'Satuan Kerja' : 'Department',
        isIndo ? 'Mulai Kunjungan' : 'Period Start',
        isIndo ? 'Selesai Kunjungan' : 'Period End',
        isIndo ? 'Status Approval' : 'Approval Status',
      ];
      for (int i = 0; i < approvalHeaders.length; i++) {
        writeCell(sheet2, i, 6, xl.TextCellValue(approvalHeaders[i]), tableHeaderStyle);
      }

      int s2Row = 7;
      if (dateTickets.isEmpty) {
        sheet2.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: s2Row),
          xl.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: s2Row),
          customValue: xl.TextCellValue(isIndo ? 'Tidak ada data persetujuan hari ini' : 'No approval requests today'),
        );
        writeCell(sheet2, 0, s2Row, xl.TextCellValue(isIndo ? 'Tidak ada data persetujuan hari ini' : 'No approval requests today'), normalCenter);
      } else {
        int no = 1;
        for (final t in dateTickets) {
          final ticketId = t.ticketId ?? '';
          final String visName = invitationController.ticketVisitorNames[ticketId] ?? t.hostName ?? '-';
          final start = t.visitorPeriodStart != null ? DateFormat('yyyy-MM-dd HH:mm').format(t.visitorPeriodStart!) : '-';
          final end = t.visitorPeriodEnd != null ? DateFormat('yyyy-MM-dd HH:mm').format(t.visitorPeriodEnd!) : '-';
          final hostDept = t.hostOrganizationName ?? '-';
          final status = t.approvalActorStatus ?? t.approvalStatus ?? 'Pending';

          writeCell(sheet2, 0, s2Row, xl.IntCellValue(no++), normalCenter);
          writeCell(sheet2, 1, s2Row, xl.TextCellValue(t.agenda ?? '-'), normalLeft);
          writeCell(sheet2, 2, s2Row, xl.TextCellValue(visName), normalLeft);
          writeCell(sheet2, 3, s2Row, xl.TextCellValue(t.hostName ?? '-'), normalLeft);
          writeCell(sheet2, 4, s2Row, xl.TextCellValue(hostDept), normalCenter);
          writeCell(sheet2, 5, s2Row, xl.TextCellValue(start), normalCenter);
          writeCell(sheet2, 6, s2Row, xl.TextCellValue(end), normalCenter);
          writeCell(sheet2, 7, s2Row, xl.TextCellValue(status), normalCenter);
          s2Row++;
        }
      }

      // ==========================================
      // SHEET 3: TODAY INVITATION LIST
      // ==========================================
      sheet3.setColumnWidth(0, 8.0);
      sheet3.setColumnWidth(1, 30.0);
      sheet3.setColumnWidth(2, 22.0);
      sheet3.setColumnWidth(3, 25.0);
      sheet3.setColumnWidth(4, 20.0);
      sheet3.setColumnWidth(5, 20.0);
      sheet3.setColumnWidth(6, 18.0);

      // Title Banner A1:G1
      sheet3.merge(
        xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        xl.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0),
      );
      for (int i = 0; i <= 6; i++) {
        final cell = sheet3.cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        if (i == 0) {
          cell.value = xl.TextCellValue(isIndo ? 'DAFTAR UNDANGAN HARI INI (TODAY INVITATION LIST)' : 'TODAY INVITATION LIST REPORT');
        }
        cell.cellStyle = invitationBannerStyle;
      }

      // KPI Metadata
      writeCell(sheet3, 0, 2, xl.TextCellValue(isIndo ? 'Tanggal Laporan:' : 'Report Date:'), metaLabelStyle);
      writeCell(sheet3, 1, 2, xl.TextCellValue(formatDate), metaValueStyle);
      writeCell(sheet3, 3, 2, xl.TextCellValue(isIndo ? 'Total Undangan:' : 'Total Invitations:'), metaLabelStyle);
      writeCell(sheet3, 4, 2, xl.IntCellValue(dateInvitations.length), metaValueStyle);

      writeCell(sheet3, 0, 3, xl.TextCellValue(isIndo ? 'Undangan Aktif:' : 'Active:'), metaLabelStyle);
      writeCell(sheet3, 1, 3, xl.IntCellValue(activeInvitations), metaValueStyle);
      writeCell(sheet3, 3, 3, xl.TextCellValue(isIndo ? 'Segera Kadaluarsa:' : 'Expiring Soon:'), metaLabelStyle);
      writeCell(sheet3, 4, 3, xl.IntCellValue(expiringSoonInvitations), metaValueStyle);

      writeCell(sheet3, 0, 4, xl.TextCellValue(isIndo ? 'Kadaluarsa:' : 'Expired:'), metaLabelStyle);
      writeCell(sheet3, 1, 4, xl.IntCellValue(expiredInvitations), metaValueStyle);

      // Table Header Row 6
      final invitationHeaders = [
        'No',
        'Agenda',
        isIndo ? 'Tipe Visitor' : 'Visitor Type',
        isIndo ? 'Host / Pembuat' : 'Host / Creator',
        isIndo ? 'Mulai Berlaku' : 'Period Start',
        isIndo ? 'Selesai Berlaku' : 'Period End',
        'Status',
      ];
      for (int i = 0; i < invitationHeaders.length; i++) {
        writeCell(sheet3, i, 6, xl.TextCellValue(invitationHeaders[i]), tableHeaderStyle);
      }

      int s3Row = 7;
      if (dateInvitations.isEmpty) {
        sheet3.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: s3Row),
          xl.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: s3Row),
          customValue: xl.TextCellValue(isIndo ? 'Tidak ada data undangan hari ini' : 'No invitations today'),
        );
        writeCell(sheet3, 0, s3Row, xl.TextCellValue(isIndo ? 'Tidak ada data undangan hari ini' : 'No invitations today'), normalCenter);
      } else {
        int no = 1;
        for (final inv in dateInvitations) {
          final start = DateFormat('yyyy-MM-dd HH:mm').format(inv.visitorPeriodStart);
          final end = DateFormat('yyyy-MM-dd HH:mm').format(inv.visitorPeriodEnd);
          final status = inv.visitorPeriodEnd.isBefore(DateTime.now()) ? 'Expired' : 'Active';

          writeCell(sheet3, 0, s3Row, xl.IntCellValue(no++), normalCenter);
          writeCell(sheet3, 1, s3Row, xl.TextCellValue(inv.agenda.isNotEmpty ? inv.agenda : '-'), normalLeft);
          writeCell(sheet3, 2, s3Row, xl.TextCellValue(inv.visitorTypeName.isNotEmpty ? inv.visitorTypeName : '-'), normalCenter);
          writeCell(sheet3, 3, s3Row, xl.TextCellValue(inv.hostName.isNotEmpty ? inv.hostName : '-'), normalLeft);
          writeCell(sheet3, 4, s3Row, xl.TextCellValue(start), normalCenter);
          writeCell(sheet3, 5, s3Row, xl.TextCellValue(end), normalCenter);
          writeCell(sheet3, 6, s3Row, xl.TextCellValue(status), normalCenter);
          s3Row++;
        }
      }

      // ==========================================
      // SHEET 4: TODAY ALARM LIST
      // ==========================================
      sheet4.setColumnWidth(0, 8.0);
      sheet4.setColumnWidth(1, 35.0);
      sheet4.setColumnWidth(2, 28.0);
      sheet4.setColumnWidth(3, 18.0);
      sheet4.setColumnWidth(4, 20.0);
      sheet4.setColumnWidth(5, 18.0);

      // Title Banner A1:F1
      sheet4.merge(
        xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
      );
      for (int i = 0; i <= 5; i++) {
        final cell = sheet4.cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        if (i == 0) {
          cell.value = xl.TextCellValue(isIndo ? 'DAFTAR NOTIFIKASI HARI INI (TODAY NOTIFICATION LIST)' : 'TODAY NOTIFICATION LIST REPORT');
        }
        cell.cellStyle = alarmBannerStyle;
      }

      // KPI Metadata
      writeCell(sheet4, 0, 2, xl.TextCellValue(isIndo ? 'Tanggal Laporan:' : 'Report Date:'), metaLabelStyle);
      writeCell(sheet4, 1, 2, xl.TextCellValue(formatDate), metaValueStyle);
      writeCell(sheet4, 3, 2, xl.TextCellValue(isIndo ? 'Total Notifikasi:' : 'Total Notifications:'), metaLabelStyle);
      writeCell(sheet4, 4, 2, xl.IntCellValue(totalActiveAlarms), metaValueStyle);

      writeCell(sheet4, 0, 3, xl.TextCellValue(isIndo ? 'Prioritas Tinggi:' : 'High Priority:'), metaLabelStyle);
      writeCell(sheet4, 1, 3, xl.IntCellValue(highPriorityAlarms), metaValueStyle);
      writeCell(sheet4, 3, 3, xl.TextCellValue(isIndo ? 'Prioritas Sedang:' : 'Medium Priority:'), metaLabelStyle);
      writeCell(sheet4, 4, 3, xl.IntCellValue(mediumPriorityAlarms), metaValueStyle);

      writeCell(sheet4, 0, 4, xl.TextCellValue(isIndo ? 'Prioritas Rendah:' : 'Low Priority:'), metaLabelStyle);
      writeCell(sheet4, 1, 4, xl.IntCellValue(lowPriorityAlarms), metaValueStyle);

      // Table Header Row 6
      final alarmHeaders = [
        'No',
        isIndo ? 'Deskripsi Notifikasi' : 'Description',
        isIndo ? 'Lokasi / Pintu' : 'Location',
        isIndo ? 'Tingkat Prioritas' : 'Priority',
        isIndo ? 'Waktu Terdeteksi' : 'Detected At',
        isIndo ? 'Status Penanganan' : 'Status',
      ];
      for (int i = 0; i < alarmHeaders.length; i++) {
        writeCell(sheet4, i, 6, xl.TextCellValue(alarmHeaders[i]), tableHeaderStyle);
      }

      int s4Row = 7;
      if (dateAlarms.isEmpty) {
        sheet4.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: s4Row),
          xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: s4Row),
          customValue: xl.TextCellValue(isIndo ? 'Tidak ada data notifikasi hari ini' : 'No notifications today'),
        );
        writeCell(sheet4, 0, s4Row, xl.TextCellValue(isIndo ? 'Tidak ada data notifikasi hari ini' : 'No notifications today'), normalCenter);
      } else {
        int no = 1;
        for (final a in dateAlarms) {
          final priority = a.status == AlarmStatus.high ? 'High' : a.status == AlarmStatus.medium ? 'Medium' : 'Low';
          final start = DateFormat('yyyy-MM-dd HH:mm').format(a.createdAt);
          final status = a.isApproved ? 'Approved' : a.isDenied ? 'Denied' : 'Active';

          writeCell(sheet4, 0, s4Row, xl.IntCellValue(no++), normalCenter);
          writeCell(sheet4, 1, s4Row, xl.TextCellValue(a.alarmDescription), normalLeft);
          writeCell(sheet4, 2, s4Row, xl.TextCellValue(a.location), normalLeft);
          writeCell(sheet4, 3, s4Row, xl.TextCellValue(priority), normalCenter);
          writeCell(sheet4, 4, s4Row, xl.TextCellValue(start), normalCenter);
          writeCell(sheet4, 5, s4Row, xl.TextCellValue(status), normalCenter);
          s4Row++;
        }
      }

      // 5. Save and Write Excel Bytes
      final List<int>? fileBytes = excelObj.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file bytes');
      }

      String? path;
      bool saveSuccess = false;

      if (Platform.isAndroid) {
        try {
          final dir = Directory('/storage/emulated/0/Download');
          if (await dir.exists()) {
            final testPath = '${dir.path}/$filename';
            final file = File(testPath);
            await file.writeAsBytes(fileBytes);
            path = testPath;
            saveSuccess = true;
          }
        } catch (e) {
          debugPrint('Failed to save Excel to public Download folder: $e');
        }
      }

      if (!saveSuccess) {
        final dir = await getApplicationDocumentsDirectory();
        path = '${dir.path}/$filename';
        final file = File(path);
        await file.writeAsBytes(fileBytes);
      }

      // 6. Show Get.snackbar with OPEN button
      Get.snackbar(
        'Success',
        isIndo ? 'Laporan ringkasan berhasil diunduh!' : 'Summary report downloaded successfully!',
        messageText: Text(
          isIndo ? 'Laporan ringkasan berhasil diunduh!' : 'Summary report downloaded successfully!',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleText: const SizedBox.shrink(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () {
            OpenFilex.open(path!);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isIndo ? 'BUKA' : 'OPEN',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      // Auto open
      OpenFilex.open(path!);

    } catch (e) {
      debugPrint("Unexpected error while exporting summary Excel: $e");
      Get.snackbar(
        'Error',
        isIndo ? 'Gagal mengunduh laporan ringkasan' : 'Failed to download summary report',
        messageText: Text(
          isIndo ? 'Gagal mengunduh laporan ringkasan' : 'Failed to download summary report',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleText: const SizedBox.shrink(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- REUSABLE WIDGETS ---
  Widget _buildInfoBanner(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.all(rw(context, 12)),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(rw(context, 8)),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 18),
          hSpace(context, 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: rfs(context, 11),
                color: const Color(0xFF0D47A1),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String titleIndo;
  final String titleEng;
  final String time;
  final String subtitle;
  final String? badgeIndo;
  final String? badgeEng;
  final DateTime timestamp;

  _ActivityItem({
    required this.icon,
    required this.titleIndo,
    required this.titleEng,
    required this.time,
    required this.subtitle,
    this.badgeIndo,
    this.badgeEng,
    required this.timestamp,
  });
}
