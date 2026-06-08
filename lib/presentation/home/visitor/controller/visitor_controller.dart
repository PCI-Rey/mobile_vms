import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/visitor_model.dart';

class VisitorController extends GetxController {
  final ApiService _api = ApiService();
  final HiveService _hive = HiveService();

  final isLoading = false.obs;
  final visitors = <InvitationVisitorModel>[].obs;
  final filteredVisitors = <InvitationVisitorModel>[].obs;
  final errorMessage = Rxn<String>();

  // Stats
  final todayVisitCount = 0.obs;
  final checkInCount = 0.obs;
  final denyCount = 0.obs;
  final blockCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadVisitors();
  }

  Future<void> loadVisitors() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final user = _hive.getUser();
      final token = user?.token;
      if (token == null) return;

      // 1. Fetch visitor profiles
      final response = await _api.getVisitors(token);
      if (response.data != null &&
          (response.data['status'] == 'success' ||
              response.data['status_code'] == 200)) {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final list = collection
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => InvitationVisitorModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
        visitors.assignAll(list);
        filteredVisitors.assignAll(list);
      }

      // 2. Fetch visitor transactions for stats
      final dtResponse = await _api.getVisitorDt(token, length: 1000);
      if (dtResponse.data != null &&
          (dtResponse.data['status'] == 'success' ||
              dtResponse.data['status_code'] == 200)) {
        final collection = dtResponse.data['collection'] as List<dynamic>? ?? [];

        int todayVisit = 0;
        int checkIn = 0;
        int deny = 0;
        int block = 0;

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        for (var item in collection) {
          if (item is Map) {
            final status = (item['visitor_status'] ?? '').toString().toLowerCase();

            // Count if period start is today
            final periodStartStr = item['visitor_period_start']?.toString();
            if (periodStartStr != null) {
              final periodStart = DateTime.tryParse(periodStartStr);
              if (periodStart != null &&
                  periodStart.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
                  periodStart.isBefore(todayEnd)) {
                todayVisit++;
              }
            }

            if (status == 'checkin') {
              checkIn++;
            } else if (status == 'denied') {
              deny++;
            }
          }
        }

        todayVisitCount.value = todayVisit;
        checkInCount.value = checkIn;
        denyCount.value = deny;
        blockCount.value = block;
      }
    } catch (e) {
      debugPrint('VisitorController loadVisitors error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void searchVisitors(String query) {
    if (query.isEmpty) {
      filteredVisitors.assignAll(visitors);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final results = visitors.where((visitor) {
      return visitor.name.toLowerCase().contains(lowercaseQuery) ||
          visitor.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
    filteredVisitors.assignAll(results);
  }
}
