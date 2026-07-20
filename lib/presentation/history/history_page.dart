// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import '../auth/controller/language_controller.dart';
import '../home/invitation/controller/invitation_controller.dart';
import 'controller/history_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryController controller;

  /// One-way sync worker: Home selectedDashboardDate → History.
  /// Cancelled in dispose so it never affects the home date.
  Worker? _dateWorker;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<HistoryController>()) {
      controller = Get.find<HistoryController>();
    } else {
      controller = Get.put(HistoryController());
    }

    // One-way sync: whenever Home changes its dashboard date,
    // History follows automatically.
    // The reverse (History date picker) does NOT touch InvitationController.
    if (Get.isRegistered<InvitationController>()) {
      final invCtrl = Get.find<InvitationController>();
      _dateWorker = ever(
        invCtrl.selectedDashboardDate,
        (date) => controller.fetchActivities(date: date),
      );
    }
  }

  @override
  void dispose() {
    _dateWorker?.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'US'),
    );
    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      controller.fetchActivities(date: normalized);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          final lang = Get.isRegistered<LanguageController>()
              ? LanguageController.to.selectedLang.value
              : 'id';
          final isId = lang == 'id';
          final date = controller.selectedDate.value;

          String dateLabel;
          try {
            dateLabel = DateFormat(
              'd MMMM yyyy',
              isId ? 'id_ID' : 'en_US',
            ).format(date);
          } catch (_) {
            dateLabel = DateFormat('d MMMM yyyy').format(date);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: rfs(context, 22),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              vSpace(context, 4),
              Text(
                '${isId ? 'Tanggal' : 'Date'}: $dateLabel',
                style: TextStyle(
                  fontSize: rfs(context, 12),
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          );
        }),
        centerTitle: true,
        actions: [
          Obx(() {
            // Show refresh spinner inline if refreshing
            if (controller.isRefreshing.value) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
                child: SizedBox(
                  width: rw(context, 20),
                  height: rw(context, 20),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return IconButton(
              onPressed: _pickDate,
              icon: Icon(
                Icons.calendar_today_outlined,
                color: Colors.black87,
                size: rw(context, 22),
              ),
              tooltip: 'Pick date',
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Obx(() => _buildBody(context)),
    );
  }

  // ── Body states ───────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value && !controller.isRefreshing.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value != null) {
      return _buildError(context);
    }

    final activities = _parseActivities(context);

    if (activities.isEmpty) {
      return _buildEmpty(context);
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshActivities(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: rw(context, 16),
          right: rw(context, 16),
          top: rh(context, 16),
          bottom: rh(context, 16) + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: activities.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey.shade100,
          indent: rw(context, 76),
        ),
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          final isLast = index == activities.length - 1;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
                topRight: isFirst ? const Radius.circular(16) : Radius.zero,
                bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
                bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
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
      ),
    );
  }

  // ── Parse raw API data → _ActivityItem list ───────────────────────────────

  List<_ActivityItem> _parseActivities(BuildContext context) {
    final lang = Get.isRegistered<LanguageController>()
        ? LanguageController.to.selectedLang.value
        : 'id';
    final isId = lang == 'id';

    final List<_ActivityItem> activities = [];

    for (final item in controller.todayActivities) {
      final dateStr =
          item['actionAt']?.toString() ?? item['createdAt']?.toString();
      final DateTime timestamp = dateStr != null
          ? HistoryController.parseTimestamp(dateStr)
          : DateTime.now();

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
      } else if (action.contains('checkin')) {
        title = isId ? 'Visitor Check-In' : 'Visitor Check-In';
        icon = Icons.login_outlined;
        iconColor = const Color(0xFF1976D2);
        bgColor = const Color(0xFFE8F1FD);
      } else if (action.contains('checkout')) {
        title = isId ? 'Visitor Check-Out' : 'Visitor Check-Out';
        icon = Icons.logout_outlined;
        iconColor = const Color(0xFF0288D1);
        bgColor = const Color(0xFFE1F5FE);
      } else if (action.contains('password')) {
        title = isId ? 'Ubah Kata Sandi' : 'Change Password';
        icon = Icons.lock_outline;
        iconColor = const Color(0xFF534AB7);
        bgColor = const Color(0xFFF3EEFE);
      } else if (action.contains('invitation') || action.contains('invite')) {
        title = isId ? 'Undangan Dibuat' : 'Invitation Created';
        icon = Icons.mail_outline_rounded;
        iconColor = const Color(0xFF0F6E56);
        bgColor = const Color(0xFFE1F5EE);
      } else {
        // Fallback: capitalise the raw action string
        final raw = item['action']?.toString() ?? 'Activity';
        title = raw.isNotEmpty
            ? raw[0].toUpperCase() + raw.substring(1)
            : 'Activity';
        icon = Icons.info_outline;
        iconColor = const Color(0xFF1976D2);
        bgColor = const Color(0xFFE8F1FD);
      }

      final description = item['description']?.toString() ?? '';

      activities.add(
        _ActivityItem(
          title: title,
          description: description,
          timestamp: timestamp,
          icon: icon,
          iconColor: iconColor,
          bgColor: bgColor,
        ),
      );
    }

    // Newest first
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }

  // ── Activity row card ─────────────────────────────────────────────────────

  Widget _buildActivityRow(BuildContext context, _ActivityItem activity) {
    final timeStr = DateFormat('HH:mm').format(activity.timestamp);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon circle
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
          // Title + description
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
                if (activity.description.isNotEmpty) ...[
                  vSpace(context, 4),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          hSpace(context, 12),
          // Time
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

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    final lang = Get.isRegistered<LanguageController>()
        ? LanguageController.to.selectedLang.value
        : 'id';
    final isId = lang == 'id';

    return RefreshIndicator(
      onRefresh: () => controller.refreshActivities(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(rw(context, 24)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_toggle_off_rounded,
                    size: rw(context, 48),
                    color: Colors.grey.shade400,
                  ),
                ),
                vSpace(context, 20),
                Text(
                  isId
                      ? 'Tidak ada aktivitas pada tanggal ini'
                      : 'No activity found for this date',
                  style: TextStyle(
                    fontSize: rfs(context, 15),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                vSpace(context, 8),
                Text(
                  isId
                      ? 'Coba pilih tanggal yang lain'
                      : 'Try selecting a different date',
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    color: Colors.grey.shade400,
                  ),
                ),
                vSpace(context, 20),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    size: rw(context, 16),
                  ),
                  label: Text(
                    isId ? 'Pilih Tanggal Lain' : 'Pick Another Date',
                    style: TextStyle(fontSize: rfs(context, 13)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary500,
                    side: BorderSide(color: AppColors.primary500),
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 20),
                      vertical: rh(context, 10),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rw(context, 10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: rw(context, 52),
              color: Colors.red.shade300,
            ),
            vSpace(context, 16),
            Text(
              controller.errorMessage.value!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: rfs(context, 14),
              ),
              textAlign: TextAlign.center,
            ),
            vSpace(context, 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 24),
                  vertical: rh(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 10)),
                ),
              ),
              onPressed: () => controller.refreshActivities(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _ActivityItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _ActivityItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
