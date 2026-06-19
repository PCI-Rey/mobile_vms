import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import '../../data/models/access_pass_model.dart';
import '../auth/controller/language_controller.dart';
import 'controller/history_controller.dart';
import 'widgets/filter_bottom_sheet.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? startDate;
  DateTime? endDate;
  late final HistoryController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<HistoryController>()) {
      controller = Get.find<HistoryController>();
    } else {
      controller = Get.put(HistoryController());
    }
    // Sync local state dates with controller dates
    startDate = controller.startDate.value;
    endDate = controller.endDate.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'History',
          style: TextStyle(
            fontSize: rfs(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Obx(() => _buildHistoryContent()),
    );
  }

  Widget _buildHistoryContent() {
    if (controller.isLoading.value && !controller.isRefreshing.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(rw(context, 20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorMessage.value!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              vSpace(context, 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                ),
                onPressed: () => controller.loadHistory(
                  startDate: startDate,
                  endDate: endDate,
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: rw(context, 64), color: Colors.grey.shade400),
            vSpace(context, 16),
            Text(
              'No history found',
              style: TextStyle(
                fontSize: rfs(context, 16),
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshHistory(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(rw(context, 20.0)),
        itemCount: controller.filteredHistory.length,
        itemBuilder: (context, index) {
          final item = controller.filteredHistory[index];
          return Padding(
            padding: EdgeInsets.only(bottom: rh(context, 16.0)),
            child: _buildHistoryCard(index, item),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(int index, AccessPassModel item) {
    final String lang = Get.isRegistered<LanguageController>()
        ? LanguageController.to.selectedLang.value
        : 'id';

    String formatDate(DateTime d) {
      try {
        return DateFormat(
          'd MMMM yyyy, HH:mm',
          lang == 'id' ? 'id_ID' : 'en_US',
        ).format(d);
      } catch (_) {
        return DateFormat('d MMMM yyyy, HH:mm').format(d);
      }
    }

    final badgeColors = _getBadgeColors(item.visitorStatus);
    final displayStatus = _displayStatus(item.visitorStatus);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: rw(context, 10),
            offset: Offset(0, rh(context, 3)),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              left: rw(context, 16),
              right: rw(context, 16),
              top: rh(context, 16),
              bottom: rh(context, 12),
            ),
            child: Row(
              children: [
                Container(
                  width: rw(context, 26),
                  height: rw(context, 26),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF005596),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                hSpace(context, 10),
                Expanded(
                  child: Text(
                    item.agenda.isNotEmpty ? item.agenda : 'Visit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: rfs(context, 16),
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                hSpace(context, 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 12),
                    vertical: rh(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: badgeColors['bg'],
                    borderRadius: BorderRadius.circular(rw(context, 20)),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.w600,
                      color: badgeColors['text'],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Body
          Padding(
            padding: EdgeInsets.only(
              left: rw(context, 16),
              right: rw(context, 16),
              top: rh(context, 12),
              bottom: rh(context, 16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.badge_outlined,
                        'Visitor Type',
                        item.visitorTypeName.isNotEmpty ? item.visitorTypeName : 'Visitor',
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.person_outline,
                        'Visitor',
                        item.visitorName.isNotEmpty ? item.visitorName : '-',
                      ),
                    ),
                  ],
                ),
                vSpace(context, 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.business_outlined,
                        'Organization',
                        item.visitorOrganizationName.isNotEmpty ? item.visitorOrganizationName : '-',
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.timeline,
                        'Flow',
                        item.flow.isNotEmpty ? item.flow : 'Invitation',
                      ),
                    ),
                  ],
                ),
                vSpace(context, 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.login_outlined,
                        'Period Start',
                        formatDate(item.visitorPeriodStart),
                      ),
                    ),
                    hSpace(context, 8),
                    Expanded(
                      child: _buildCardField(
                        context,
                        Icons.logout_outlined,
                        'Period End',
                        formatDate(item.visitorPeriodEnd),
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

  Widget _buildCardField(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: rw(context, 14), color: Colors.grey.shade400),
        hSpace(context, 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 12),
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              vSpace(context, 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: rfs(context, 10),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, Color> _getBadgeColors(String status) {
    final lower = status.toLowerCase().trim();
    if (lower == 'checkin') {
      return {'bg': const Color(0xFFE8F5E9), 'text': const Color(0xFF2E7D32)};
    } else if (lower == 'checkout' || lower == 'completed') {
      return {'bg': const Color(0xFFE8EAF6), 'text': const Color(0xFF283593)};
    } else if (lower == 'pending' || lower == 'waiting') {
      return {'bg': const Color(0xFFFFF3E0), 'text': const Color(0xFFEF6C00)};
    } else if (lower == 'reject' ||
        lower == 'rejected' ||
        lower == 'denied' ||
        lower == 'deny') {
      return {'bg': const Color(0xFFFFEBEE), 'text': const Color(0xFFC62828)};
    } else {
      // Active, Available, or others
      return {'bg': const Color(0xFFE0F7FA), 'text': const Color(0xFF006064)};
    }
  }

  String _displayStatus(String status) {
    final lowerStatus = status.toLowerCase().trim();
    if (lowerStatus == 'available') {
      return 'Available';
    } else if (lowerStatus == 'pending' || lowerStatus == 'waiting') {
      return 'Pending';
    } else if (lowerStatus == 'undercreated') {
      return 'Under Created';
    } else if (lowerStatus == 'checkin') {
      return 'Checked In';
    } else if (lowerStatus == 'checkout') {
      return 'Checked Out';
    } else if (lowerStatus == 'reject' ||
        lowerStatus == 'rejected' ||
        lowerStatus == 'denied' ||
        lowerStatus == 'deny') {
      return 'Rejected';
    } else if (lowerStatus == 'preregis' ||
        lowerStatus == 'praregis' ||
        lowerStatus == 'praregister') {
      return 'Praregis';
    } else if (lowerStatus == 'quickaccess') {
      return 'Quick Access';
    } else if (lowerStatus == 'completed') {
      return 'Completed';
    } else if (status.isNotEmpty) {
      return status[0].toUpperCase() + status.substring(1);
    }
    return 'Active';
  }
}
