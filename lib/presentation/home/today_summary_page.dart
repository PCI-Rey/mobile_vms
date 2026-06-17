import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/core.dart';
import '../../core/helper/responsive_helper.dart';
import '../auth/controller/language_controller.dart';
import '../auth/controller/user_controller.dart';
import 'alarm/controller/alarm_controller.dart';
import 'invitation/controller/invitation_controller.dart';

class TodaySummaryPage extends StatelessWidget {
  const TodaySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final invitationController = Get.find<InvitationController>();
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
      final isPending =
          (t.approvalActorStatus ?? '').toLowerCase() == 'pending' ||
          (t.approvalStatus ?? '').toLowerCase() == 'pending';
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
      if (item.flow.toLowerCase() == 'quickaccessvisit') {
        return false;
      }
      if (item.agenda.isEmpty &&
          item.hostName.isEmpty &&
          item.visitorTypeName.isEmpty) {
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
        final isPending =
            (t.approvalActorStatus ?? '').toLowerCase() == 'pending' ||
            (t.approvalStatus ?? '').toLowerCase() == 'pending';
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
    final String labelAlarm = isIndo ? 'Alarm Aktif' : 'Active Alarm';

    final String unitPeople = isIndo ? 'Orang' : 'People';
    final String unitReq = isIndo ? 'Permintaan' : 'Request(s)';
    final String unitInv = isIndo ? 'Undangan' : 'Invitation(s)';
    final String unitAlarm = isIndo ? 'Alarm' : 'Alarm(s)';

    // Compute dynamic breakdown stats for Tab 1
    final invitationController = Get.find<InvitationController>();
    final date = invitationController.selectedDashboardDate.value;

    final todayVisitorsList = invitationController.getTodayVisitors();
    final int checkedOutCount = todayVisitorsList.where((v) => v.visitorStatus.toLowerCase() == 'checkout').length;

    final dateInvitations = invitationController.allRawVisitors.where((item) {
      if (item.flow.toLowerCase() == 'quickaccessvisit') {
        return false;
      }
      if (item.agenda.isEmpty &&
          item.hostName.isEmpty &&
          item.visitorTypeName.isEmpty) {
        return false;
      }
      final itemDate = item.visitorPeriodStart;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();
    final int expiredInvitationCount = dateInvitations.where((item) => item.visitorPeriodEnd.isBefore(DateTime.now())).length;

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

    final String descVisitor = isIndo ? 'Jumlah visitor yang datang hari ini' : 'Total visitors arriving today';
    final String descApproval = isIndo ? 'Permintaan akses yang menunggu persetujuan' : 'Access requests waiting for approval';
    final String descInvitation = isIndo ? 'Undangan yang masih aktif' : 'Active visitor invitations';
    final String descAlarm = isIndo ? 'Alarm yang sedang aktif' : 'Alarms currently triggered and active';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(rw(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2x2 Grid of Main Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridCard(context, labelVisitor, '$visitorCount', unitPeople, Icons.people, const Color(0xFF1976D2)),
              ),
              hSpace(context, 12),
              Expanded(
                child: _buildSummaryGridCard(context, labelApproval, '$approvalCount', unitReq, Icons.access_time, const Color(0xFFF57C00)),
              ),
            ],
          ),
          vSpace(context, 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridCard(context, labelInvitation, '$invitationCount', unitInv, Icons.mail_outline, const Color(0xFF43A047)),
              ),
              hSpace(context, 12),
              Expanded(
                child: _buildSummaryGridCard(context, labelAlarm, '$notificationCount', unitAlarm, Icons.notifications_none, const Color(0xFFE53935)),
              ),
            ],
          ),

          vSpace(context, 24),
          Divider(color: Colors.grey.shade300, thickness: 1),
          vSpace(context, 16),

          // Flat list representation with description
          _buildSummaryListTile(context, labelVisitor, '$visitorCount $unitPeople', descVisitor, Icons.people, const Color(0xFF1976D2)),
          _buildSummaryListTile(context, labelApproval, '$approvalCount $unitReq', descApproval, Icons.access_time, const Color(0xFFF57C00)),
          _buildSummaryListTile(context, labelInvitation, '$invitationCount $unitInv', descInvitation, Icons.mail_outline, const Color(0xFF43A047)),
          _buildSummaryListTile(context, labelAlarm, '$notificationCount $unitAlarm', descAlarm, Icons.notifications_none, const Color(0xFFE53935)),

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
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
                _buildBreakdownItem(context, isIndo ? 'Alarm Selesai' : 'Resolved Alarms', '$resolvedAlarmCount $unitAlarm', false),
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
    Color color,
  ) {
    return Container(
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
    );
  }

  Widget _buildSummaryListTile(
    BuildContext context,
    String title,
    String value,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(context, 12)),
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
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: rfs(context, 14),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
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
                ),
              ],
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
    final invitationController = Get.find<InvitationController>();
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
      if (item.flow.toLowerCase() == 'quickaccessvisit') {
        return false;
      }
      if (item.agenda.isEmpty &&
          item.hostName.isEmpty &&
          item.visitorTypeName.isEmpty) {
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
    final String labelAlarm = isIndo ? 'Alarm Aktif' : 'Active Alarm';

    final String unitPeople = isIndo ? 'Orang' : 'People';
    final String unitReq = isIndo ? 'Permintaan' : 'Request(s)';
    final String unitInv = isIndo ? 'Undangan' : 'Invitation(s)';
    final String unitAlarm = isIndo ? 'Alarm' : 'Alarm(s)';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(rw(context, 20)),
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
              _buildDetailRow(context, isIndo ? 'Total Alarm Aktif' : 'Total Active Alarms', '$totalActiveAlarms $unitAlarm'),
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

    final invitationController = Get.find<InvitationController>();
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
      if (item.flow.toLowerCase() == 'quickaccessvisit') {
        return false;
      }
      if (item.agenda.isEmpty &&
          item.hostName.isEmpty &&
          item.visitorTypeName.isEmpty) {
        return false;
      }
      final itemDate = item.visitorPeriodStart;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).toList();
    for (final inv in dateInvitations) {
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
      padding: EdgeInsets.all(rw(context, 20)),
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
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.grey, size: 18),
                    hSpace(context, 4),
                  ],
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
    final invitationController = Get.find<InvitationController>();
    final alarmCtrl = Get.isRegistered<AlarmController>()
        ? Get.find<AlarmController>()
        : Get.put(AlarmController());

    final formatDate = DateFormat('yyyy-MM-dd').format(date);
    final String filename = 'summary_report_$formatDate.csv';

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
        if (item.flow.toLowerCase() == 'quickaccessvisit') {
          return false;
        }
        if (item.agenda.isEmpty &&
            item.hostName.isEmpty &&
            item.visitorTypeName.isEmpty) {
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

      // 3. Build CSV string content
      final StringBuffer csv = StringBuffer();
      
      // Header Section
      csv.writeln('=========================================');
      csv.writeln(isIndo ? 'LAPORAN RINGKASAN HARIAN' : 'DAILY SUMMARY REPORT');
      csv.writeln('=========================================');
      csv.writeln('${isIndo ? "Tanggal Laporan" : "Report Date"}: $formatDate');
      csv.writeln('${isIndo ? "Waktu Dibuat" : "Generated At"}: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
      csv.writeln('');

      // Statistics Section
      csv.writeln(isIndo ? '1. STATISTIK RINGKASAN' : '1. SUMMARY STATISTICS');
      csv.writeln('${isIndo ? "Kategori" : "Category"},${isIndo ? "Metrik" : "Metric"},${isIndo ? "Nilai" : "Value"}');
      csv.writeln('Visitor Today,${isIndo ? "Total Visitor" : "Total Visitors"},$totalTodayVisitors');
      csv.writeln('Visitor Today,${isIndo ? "Sudah Check-in" : "Checked In"},$checkedInToday');
      csv.writeln('Visitor Today,${isIndo ? "Belum Check-in" : "Not Checked In"},$notCheckedInToday');
      csv.writeln('Visitor Today,${isIndo ? "Sudah Check-out" : "Checked Out"},$checkedOutToday');
      csv.writeln('Visitor Today,${isIndo ? "Masih Berada Di Lokasi" : "Still In Location"},$stillOnSiteToday');
      
      csv.writeln('Waiting Approval,${isIndo ? "Total Permintaan" : "Total Requests"},$totalRequests');
      csv.writeln('Waiting Approval,${isIndo ? "Menunggu Persetujuan" : "Awaiting Approval"},$awaitingApproval');
      csv.writeln('Waiting Approval,${isIndo ? "Disetujui" : "Approved"},$approved');
      csv.writeln('Waiting Approval,${isIndo ? "Ditolak" : "Rejected"},$rejected');
      
      csv.writeln('Active Invitation,${isIndo ? "Total Undangan Aktif" : "Total Active Invitations"},$activeInvitations');
      csv.writeln('Active Invitation,${isIndo ? "Akan Kadaluarsa (<= 3 hari)" : "Expiring Soon (<= 3 days)"},$expiringSoonInvitations');
      csv.writeln('Active Invitation,${isIndo ? "Kadaluarsa" : "Expired"},$expiredInvitations');
      
      csv.writeln('Active Alarm,${isIndo ? "Total Alarm Aktif" : "Total Active Alarms"},$totalActiveAlarms');
      csv.writeln('Active Alarm,${isIndo ? "Prioritas Tinggi" : "High Priority"},$highPriorityAlarms');
      csv.writeln('Active Alarm,${isIndo ? "Prioritas Sedang" : "Medium Priority"},$mediumPriorityAlarms');
      csv.writeln('Active Alarm,${isIndo ? "Prioritas Rendah" : "Low Priority"},$lowPriorityAlarms');
      csv.writeln('');

      // Detail Visitors Section
      csv.writeln(isIndo ? '2. DAFTAR VISITOR HARI INI' : '2. TODAY VISITOR LIST');
      csv.writeln('${isIndo ? "Nama Visitor" : "Visitor Name"},${isIndo ? "Tipe Visitor" : "Visitor Type"},${isIndo ? "Nama Host" : "Host Name"},${isIndo ? "Mulai Kunjungan" : "Period Start"},${isIndo ? "Selesai Kunjungan" : "Period End"},Status');
      for (final v in todayVisitorsList) {
        final name = v.visitorName.replaceAll(',', ' ');
        final type = v.visitorTypeName.replaceAll(',', ' ');
        final host = v.hostName.replaceAll(',', ' ');
        final start = DateFormat('yyyy-MM-dd HH:mm').format(v.visitorPeriodStart);
        final end = DateFormat('yyyy-MM-dd HH:mm').format(v.visitorPeriodEnd);
        csv.writeln('$name,$type,$host,$start,$end,${v.visitorStatus}');
      }
      csv.writeln('');

      // Detail Approval Tickets Section
      csv.writeln(isIndo ? '3. DAFTAR PERSETUJUAN HARI INI' : '3. TODAY APPROVAL LIST');
      csv.writeln('Agenda,${isIndo ? "Nama Pengaju" : "Visitor Name"},${isIndo ? "Mulai Kunjungan" : "Period Start"},${isIndo ? "Selesai Kunjungan" : "Period End"},Status Approval');
      for (final t in dateTickets) {
        final agenda = (t.agenda ?? '-').replaceAll(',', ' ');
        final String ticketId = t.ticketId ?? '';
        final String visName = invitationController.ticketVisitorNames[ticketId] ?? t.hostName ?? '-';
        final name = visName.replaceAll(',', ' ');
        final start = t.visitorPeriodStart != null ? DateFormat('yyyy-MM-dd HH:mm').format(t.visitorPeriodStart!) : '-';
        final end = t.visitorPeriodEnd != null ? DateFormat('yyyy-MM-dd HH:mm').format(t.visitorPeriodEnd!) : '-';
        csv.writeln('$agenda,$name,$start,$end,${t.approvalActorStatus}');
      }
      csv.writeln('');

      // Detail Alarms Section
      csv.writeln(isIndo ? '4. DAFTAR ALARM HARI INI' : '4. TODAY ALARM LIST');
      csv.writeln('${isIndo ? "Deskripsi" : "Description"},${isIndo ? "Lokasi" : "Location"},${isIndo ? "Status/Prioritas" : "Priority/Status"},${isIndo ? "Waktu Muncul" : "Created At"},Status');
      for (final a in dateAlarms) {
        final desc = a.alarmDescription.replaceAll(',', ' ');
        final loc = a.location.replaceAll(',', ' ');
        final priority = a.status == AlarmStatus.high ? 'High' : a.status == AlarmStatus.medium ? 'Medium' : 'Low';
        final start = DateFormat('yyyy-MM-dd HH:mm').format(a.createdAt);
        final status = a.isApproved ? 'Approved' : a.isDenied ? 'Denied' : 'Active';
        csv.writeln('$desc,$loc,$priority,$start,$status');
      }

      // 4. Save to file
      String? path;
      bool saveSuccess = false;
      final bytes = utf8.encode(csv.toString());

      if (Platform.isAndroid) {
        try {
          final dir = Directory('/storage/emulated/0/Download');
          if (await dir.exists()) {
            final testPath = '${dir.path}/$filename';
            final file = File(testPath);
            await file.writeAsBytes(bytes);
            path = testPath;
            saveSuccess = true;
          }
        } catch (e) {
          debugPrint('Failed to save CSV to public Download folder: $e');
        }
      }

      if (!saveSuccess) {
        final dir = await getApplicationDocumentsDirectory();
        path = '${dir.path}/$filename';
        final file = File(path);
        await file.writeAsBytes(bytes);
      }

      // 5. Show Get.snackbar with OPEN button
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
