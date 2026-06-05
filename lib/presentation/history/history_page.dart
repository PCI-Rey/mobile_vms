import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/components/custom_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import '../../data/models/visit_history_model.dart';
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
  String? selectedGedung;
  late final HistoryController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<HistoryController>()) {
      controller = Get.find<HistoryController>();
    } else {
      controller = Get.put(HistoryController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('History'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(),
          Container(height: 1, color: AppColors.grey200),
          Expanded(child: _buildHistoryContent()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(rw(context, 20.0)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _openFilterBottomSheet(),
              child: _buildFilterChip('Filter'),
            ),

            if (selectedGedung != null) ...[
              hSpace(context, 10),
              _buildFilterValueChip(
                selectedGedung!,
                onClear: () => _clearLocationFilter(),
              ),
            ],

            if (startDate != null || endDate != null) ...[
              hSpace(context, 10),
              _buildFilterValueChip(
                _formatDateRange(startDate, endDate),
                onClear: () => _clearDateFilter(),
              ),
            ],

            if (startDate != null ||
                endDate != null ||
                selectedGedung != null) ...[
              hSpace(context, 10),
              GestureDetector(
                onTap: () => _clearAllFilters(),
                child: Container(
                  height: rh(context, 38),
                  padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(rw(context, 50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      hSpace(context, 6),
                      Icon(
                        Icons.clear_all,
                        size: rw(context, 14),
                        color: Colors.red.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rw(context, 16))),
      ),
      builder: (context) => const FilterBottomSheet(),
    );

    if (result != null && mounted) {
      _updateFilters(
        startDate: result['startDate'],
        endDate: result['endDate'],
        selectedGedung: result['gedung'],
      );
    }
  }

  void _clearLocationFilter() {
    if (mounted) {
      _updateFilters(
        startDate: startDate,
        endDate: endDate,
        selectedGedung: null,
      );
    }
  }

  void _clearDateFilter() {
    if (mounted) {
      _updateFilters(
        startDate: null,
        endDate: null,
        selectedGedung: selectedGedung,
      );
    }
  }

  void _clearAllFilters() {
    if (mounted) {
      setState(() {
        startDate = null;
        endDate = null;
        selectedGedung = null;
      });

      controller.loadHistory();
    }
  }

  void _updateFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? selectedGedung,
  }) {
    if (!mounted) return;

    setState(() {
      this.startDate = startDate;
      this.endDate = endDate;
      this.selectedGedung = selectedGedung;
    });

    _applyCurrentFilters();
  }

  void _applyCurrentFilters() {
    if (!mounted) return;

    controller.applyFilters(
      startDate: startDate,
      endDate: endDate,
      location: selectedGedung,
    );
  }

  Widget _buildHistoryContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.history.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              vSpace(context, 16),
              const Text('Initializing...'),
            ],
          ),
        );
      }

      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.errorMessage.value != null) {
        return _buildErrorState(controller.errorMessage.value!);
      }

      final history = controller.filteredHistory;

      if (history.isEmpty) {
        return _buildEmptyState();
      }

      if (controller.isRefreshing.value) {
        return _buildRefreshingState(history);
      }

      return _buildSuccessState(history);
    });
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(rw(context, 20.0)),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: rh(context, 12.0)),
            child: Container(
              height: rh(context, 80),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 12)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessState(List<VisitHistoryModel> history) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshHistory();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(rw(context, 20.0)),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final visit = history[index];
          return Padding(
            padding: EdgeInsets.only(bottom: rh(context, 12.0)),
            child: CustomCard(
              image: Assets.icons.building.image(),
              size: rw(context, 32),
              title: visit.title,
              subtitle: visit.subtitle,
              additional: visit.additional,
              additionalDesc: visit.additionalDesc,
              backgroundIconColor: AppColors.primary500,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRefreshingState(List<VisitHistoryModel> history) {
    return ListView.builder(
      padding: EdgeInsets.all(rw(context, 20.0)),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final visit = history[index];
        return Padding(
          padding: EdgeInsets.only(bottom: rh(context, 12.0)),
          child: Opacity(
            opacity: 0.7,
            child: CustomCard(
              image: Assets.icons.building.image(),
              size: rw(context, 32),
              title: visit.title,
              subtitle: visit.subtitle,
              additional: visit.additional,
              additionalDesc: visit.additionalDesc,
              backgroundIconColor: AppColors.primary500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: rw(context, 48), color: Colors.red),
          vSpace(context, 16),
          const Text('Gagal memuat riwayat'),
          vSpace(context, 8),
          Text(
            message,
            style: TextStyle(fontSize: rfs(context, 12), color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          vSpace(context, 16),
          ElevatedButton(
            onPressed: () {
              controller.loadHistory();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: rw(context, 64), color: Colors.grey.shade400),
          vSpace(context, 16),
          Text(
            'Belum ada riwayat kunjungan',
            style: TextStyle(
              fontSize: rfs(context, 16),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          vSpace(context, 8),
          Text(
            'Riwayat kunjungan Anda akan muncul di sini',
            style: TextStyle(fontSize: rfs(context, 14), color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        mainAxisSize: MainAxisSize.min,
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
        color: AppColors.primary50,
        border: Border.all(color: AppColors.primary200),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 12),
                color: AppColors.primary700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          hSpace(context, 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: EdgeInsets.all(rw(context, 2)),
              decoration: BoxDecoration(
                color: AppColors.primary200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: rw(context, 12), color: AppColors.primary700),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final format = DateFormat('dd/MM/yy');
    if (start != null && end != null) {
      return '${format.format(start)} - ${format.format(end)}';
    } else if (start != null) {
      return 'Dari ${format.format(start)}';
    } else {
      return 'Sampai ${format.format(end!)}';
    }
  }
}
