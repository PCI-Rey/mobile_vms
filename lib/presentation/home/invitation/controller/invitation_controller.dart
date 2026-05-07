import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/access_pass_model.dart';

class InvitationController extends GetxController {
  final ApiService _api = ApiService();
  final HiveService _hive = HiveService();

  final RxList<AccessPassModel> allInvitations = <AccessPassModel>[].obs;
  final RxList<AccessPassModel> ongoingInvitations = <AccessPassModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isNewestFirst = true.obs; // Default: Terbaru di atas

  // Filter states
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString selectedSiteId = ''.obs;
  final RxString selectedSiteName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOngoingInvitations();
  }

  void setFilters({DateTime? start, DateTime? end, String? siteId, String? siteName}) {
    startDate.value = start;
    endDate.value = end;
    selectedSiteId.value = siteId ?? '';
    selectedSiteName.value = siteName ?? '';
    _applyFilters();
  }

  void toggleSort() {
    isNewestFirst.value = !isNewestFirst.value;
    _applyFilters();
  }

  void _applyFilters() {
    List<AccessPassModel> filtered = List.from(allInvitations);

    // 1. Filter Berdasarkan Tanggal (Lokal)
    if (startDate.value != null) {
      filtered = filtered.where((item) {
        final itemDate = item.visitorPeriodStart;
        final start = DateTime(startDate.value!.year, startDate.value!.month, startDate.value!.day);
        final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
        return date.isAtSameMomentAs(start) || date.isAfter(start);
      }).toList();
    }
    
    if (endDate.value != null) {
      filtered = filtered.where((item) {
        final itemDate = item.visitorPeriodStart;
        final end = DateTime(endDate.value!.year, endDate.value!.month, endDate.value!.day);
        final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
        return date.isAtSameMomentAs(end) || date.isBefore(end);
      }).toList();
    }

    // 2. Filter Berdasarkan Gedung (Lokal)
    if (selectedSiteId.value.isNotEmpty || selectedSiteName.value.isNotEmpty) {
      filtered = filtered.where((item) {
        // Cek ID cocok ATAU Nama Gedung cocok
        return (selectedSiteId.value.isNotEmpty && item.siteId == selectedSiteId.value) || 
               (selectedSiteName.value.isNotEmpty && item.sitePlaceName == selectedSiteName.value);
      }).toList();
    }

    // 3. Sorting
    if (isNewestFirst.value) {
      filtered.sort((a, b) => b.visitorPeriodStart.compareTo(a.visitorPeriodStart));
    } else {
      filtered.sort((a, b) => a.visitorPeriodStart.compareTo(b.visitorPeriodStart));
    }

    ongoingInvitations.assignAll(filtered);
  }

  Future<void> fetchOngoingInvitations({bool isSilent = false}) async {
    final user = _hive.getUser();
    final token = user?.token;

    if (token == null) return;

    if (!isSilent) isLoading.value = true;
    try {
      final response = await _api.getOngoingInvitation(token);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final newPasses = collection
            .map((e) => AccessPassModel.fromJson(e as Map<String, dynamic>))
            .toList();

        allInvitations.assignAll(newPasses);
        _applyFilters();
      }
    } catch (e) {
      debugPrint('fetchOngoingInvitations error: $e');
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }
}
