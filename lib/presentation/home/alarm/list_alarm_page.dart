import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../../data/models/alarm_model.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import 'controller/alarm_controller.dart';

class AlarmListPage extends StatefulWidget {
  final int initialTab;
  const AlarmListPage({super.key, this.initialTab = 0});

  @override
  State<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> with SingleTickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  late final AlarmController controller;
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
    // Load alarms when page initializes
    controller.loadAlarms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary600,
                unselectedLabelColor: Colors.grey.shade500,
                indicatorColor: AppColors.primary600,
                indicatorWeight: 2.5,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontSize: rfs(context, 16),
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: rfs(context, 16),
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'General'),
                  Tab(text: 'Alarm'),
                ],
              ),
            ),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent(context, 'ALL'),
                  _buildTabContent(context, 'GENERAL'),
                  _buildTabContent(context, 'ALARM'),
                ],
              ),
            ),
          ],
        ),
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
        padding: EdgeInsets.symmetric(horizontal: rw(context, 20.0), vertical: rh(context, 16.0)),
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

  Widget _buildFilterChip(String label) {
    return Container(
      height: rh(context, 38),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: rfs(context, 14))),
          hSpace(context, 8),
          Icon(FontAwesomeIcons.chevronDown, size: rw(context, 14)),
        ],
      ),
    );
  }

  Widget _buildFilterValueChip(String label, {required VoidCallback onClear}) {
    return Container(
      height: rh(context, 38),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: rfs(context, 12))),
          hSpace(context, 8),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: rw(context, 16)),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final format = DateFormat('dd/MM/yyyy');
    if (start != null && end != null) {
      return '${format.format(start)} - ${format.format(end)}';
    } else if (start != null) {
      return 'Dari ${format.format(start)}';
    } else {
      return 'Sampai ${format.format(end!)}';
    }
  }
}
