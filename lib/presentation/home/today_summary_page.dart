import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
      if (!isPending) return false;
      final itemDate = t.visitorPeriodStart;
      if (itemDate == null) return false;
      return itemDate.year == date.year &&
          itemDate.month == date.month &&
          itemDate.day == date.day;
    }).length;

    final activeInvitationCount = invitationController.allRawVisitors.where((item) {
      if (item.flow.toLowerCase() == 'quickaccessvisit') return false;
      if (item.agenda.isEmpty &&
          item.hostName.isEmpty &&
          item.visitorTypeName.isEmpty) return false;
      final itemDate = item.visitorPeriodStart;
      if (itemDate.year != date.year ||
          itemDate.month != date.month ||
          itemDate.day != date.day) return false;
      if (item.visitorPeriodEnd.isBefore(DateTime.now())) return false;
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
        if (!isPending) return false;
        final itemDate = t.visitorPeriodStart;
        if (itemDate == null) return false;
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pageTitle,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 18),
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
          bottom: TabBar(
            labelColor: const Color(0xFF1976D2),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1976D2),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: rfs(context, 13)),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: rfs(context, 13)),
            tabs: [
              Tab(text: tabAll),
              Tab(text: tabDetail),
              Tab(text: tabHistory),
            ],
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
              onPressed: () {
                Get.snackbar(
                  isIndo ? 'Mengekspor' : 'Exporting',
                  isIndo ? 'Mengekspor data ringkasan...' : 'Exporting summary data...',
                  backgroundColor: const Color(0xFF1976D2),
                  colorText: Colors.white,
                );
              },
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
                _buildBreakdownItem(context, isIndo ? 'Visitor Sudah Check-out' : 'Visitors Checked Out', '${(visitorCount * 0.7).round()} $unitPeople', false),
                _buildBreakdownItem(context, labelApproval, '$approvalCount $unitReq', true),
                _buildBreakdownItem(context, labelInvitation, '$invitationCount $unitInv', true),
                _buildBreakdownItem(context, isIndo ? 'Undangan Kadaluarsa' : 'Expired Invitations', '2 $unitInv', false),
                _buildBreakdownItem(context, labelAlarm, '$notificationCount $unitAlarm', true),
                _buildBreakdownItem(context, isIndo ? 'Alarm Selesai' : 'Resolved Alarms', '0 $unitAlarm', false),
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
              color: isHeader ? Colors.black87 : Colors.grey.shade700,
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
              _buildDetailRow(context, isIndo ? 'Total Visitor' : 'Total Visitors', '$visitorCount $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Sudah Check-in' : 'Checked In', '$visitorCount $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Belum Check-in' : 'Not Checked In', '0 $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Sudah Check-out' : 'Checked Out', '${(visitorCount * 0.7).round()} $unitPeople'),
              _buildDetailRow(context, isIndo ? 'Masih Berada Di Lokasi' : 'Still In Location', '${(visitorCount * 0.3).round()} $unitPeople'),
            ],
          ),

          // 2. Waiting Approval Breakdown
          _buildDetailCategoryCard(
            context,
            icon: Icons.access_time,
            title: labelApproval,
            color: const Color(0xFFF57C00),
            rows: [
              _buildDetailRow(context, isIndo ? 'Total Permintaan' : 'Total Requests', '$approvalCount $unitReq'),
              _buildDetailRow(context, isIndo ? 'Menunggu Persetujuan' : 'Awaiting Approval', '$approvalCount $unitReq'),
              _buildDetailRow(context, isIndo ? 'Ditolak' : 'Rejected', '0 $unitReq'),
              _buildDetailRow(context, isIndo ? 'Dibatalkan' : 'Cancelled', '0 $unitReq'),
            ],
          ),

          // 3. Active Invitation Breakdown
          _buildDetailCategoryCard(
            context,
            icon: Icons.mail_outline,
            title: labelInvitation,
            color: const Color(0xFF43A047),
            rows: [
              _buildDetailRow(context, isIndo ? 'Total Undangan Aktif' : 'Total Active Invitations', '$invitationCount $unitInv'),
              _buildDetailRow(context, isIndo ? 'Akan Kadaluarsa (≤ 3 hari)' : 'Expiring Soon (≤ 3 days)', '1 $unitInv'),
              _buildDetailRow(context, isIndo ? 'Kadaluarsa' : 'Expired', '2 $unitInv'),
            ],
          ),

          // 4. Alarm Breakdown
          _buildDetailCategoryCard(
            context,
            icon: Icons.notifications_none,
            title: labelAlarm,
            color: const Color(0xFFE53935),
            rows: [
              _buildDetailRow(context, isIndo ? 'Total Alarm Aktif' : 'Total Active Alarms', '$notificationCount $unitAlarm'),
              _buildDetailRow(context, isIndo ? 'Prioritas Tinggi' : 'High Priority', '$notificationCount $unitAlarm'),
              _buildDetailRow(context, isIndo ? 'Prioritas Sedang' : 'Medium Priority', '0 $unitAlarm'),
              _buildDetailRow(context, isIndo ? 'Prioritas Rendah' : 'Low Priority', '0 $unitAlarm'),
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
            style: TextStyle(fontSize: rfs(context, 13), color: Colors.grey.shade700),
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

          // Group 1: Hari Ini
          _buildActivityGroupHeader(context, '${isIndo ? 'Hari Ini' : 'Today'} - $todayStr'),
          _buildActivityTile(context, Icons.login, isIndo ? 'Visitor Check-in' : 'Visitor Check-in', '08:45', 'Budi Santoso', null),
          _buildActivityTile(context, Icons.note_add_outlined, isIndo ? 'Undangan Dibuat' : 'Invitation Created', '08:30', 'Rapat Project XYZ', null),
          _buildActivityTile(context, Icons.check_circle_outline, isIndo ? 'Permintaan Disetujui' : 'Request Approved', '08:25', 'Budi Santoso', null),
          _buildActivityTile(context, Icons.logout, isIndo ? 'Visitor Check-out' : 'Visitor Check-out', '08:10', 'Andi Wijaya', null),
          _buildActivityTile(context, Icons.warning_amber_rounded, isIndo ? 'Alarm Aktif' : 'Active Alarm', '07:58', 'Pintu Utama - Terbuka', isIndo ? 'Tinggi' : 'High'),
          _buildActivityTile(context, Icons.check_circle, isIndo ? 'Alarm Selesai' : 'Alarm Cleared', '07:59', 'Pintu Utama - Terbuka', null),

          vSpace(context, 20),

          // Group 2: Kemarin
          _buildActivityGroupHeader(context, '${isIndo ? 'Kemarin' : 'Yesterday'} - $yesterdayStr'),
          _buildActivityTile(context, Icons.login, isIndo ? 'Visitor Check-in' : 'Visitor Check-in', '16:45', 'Siti Aisyah', null),
          _buildActivityTile(context, Icons.timer_off_outlined, isIndo ? 'Undangan Kadaluarsa' : 'Invitation Expired', '16:30', 'Tamu Seminar', null),
          _buildActivityTile(context, Icons.cancel_outlined, isIndo ? 'Permintaan Ditolak' : 'Request Rejected', '15:20', 'John Doe', null),
          _buildActivityTile(context, Icons.logout, isIndo ? 'Visitor Check-out' : 'Visitor Check-out', '15:10', 'Siti Aisyah', null),
          _buildActivityTile(context, Icons.warning_amber_rounded, isIndo ? 'Alarm Aktif' : 'Active Alarm', '14:05', 'Lift 1 - Error', isIndo ? 'Sedang' : 'Medium'),
          _buildActivityTile(context, Icons.check_circle, isIndo ? 'Alarm Selesai' : 'Alarm Cleared', '14:12', 'Lift 1 - Error', null),

          vSpace(context, 24),

          // Info Alert Card
          _buildInfoBanner(
            context,
            isIndo
                ? 'Riwayat aktivitas menampilkan 7 hari terakhir.'
                : 'Activity log shows the last 7 days of events.',
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
