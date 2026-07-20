import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/hive_service.dart';

class HistoryController extends GetxController {
  static HistoryController get to => Get.find();

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = Rxn<String>();
  final todayActivities = <dynamic>[].obs;

  final Rx<DateTime> selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivities();
  }

  /// Parse timestamp string from API to local DateTime.
  /// Handles sub-second precision > 6 digits and missing timezone suffix.
  static DateTime parseTimestamp(String dateStr) {
    try {
      String normalized = dateStr;
      final dotIndex = normalized.indexOf('.');
      if (dotIndex != -1) {
        final zIndex = normalized.indexOf('Z', dotIndex);
        final plusIndex = normalized.indexOf('+', dotIndex);
        int endSubSeconds = normalized.length;
        if (zIndex != -1) {
          endSubSeconds = zIndex;
        } else if (plusIndex != -1) {
          endSubSeconds = plusIndex;
        }

        final subSecondsStr = normalized.substring(dotIndex + 1, endSubSeconds);
        if (subSecondsStr.length > 6) {
          final trimmed = subSecondsStr.substring(0, 6);
          final suffix = endSubSeconds < normalized.length
              ? normalized.substring(endSubSeconds)
              : '';
          normalized =
              '${normalized.substring(0, dotIndex)}.$trimmed$suffix';
        }
      }
      if (!normalized.endsWith('Z') && !normalized.contains('+')) {
        normalized = '${normalized}Z';
      }
      return DateTime.parse(normalized).toLocal();
    } catch (e) {
      debugPrint('HistoryController: Error parsing timestamp "$dateStr": $e');
      return DateTime.now();
    }
  }

  Future<void> fetchActivities({DateTime? date}) async {
    final targetDate = date ?? selectedDate.value;
    selectedDate.value = targetDate;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final token = HiveService().getUser()?.token;
      if (token == null) {
        errorMessage.value = 'User token not found. Please log in again.';
        return;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(targetDate);
      final response = await ApiService().getTodayActivities(
        token,
        startDate: formattedDate,
        endDate: formattedDate,
        length: 1000,
      );

      if (response.data is Map &&
          (response.data['status'] == 'success' ||
              response.data['status_code'] == 200)) {
        final collection =
            response.data['collection'] as List<dynamic>? ?? [];
        todayActivities.assignAll(collection);
      } else {
        // 404 / not_found / 500 = no data for this date — just show empty state,
        // do NOT set errorMessage (same pattern as InvitationController).
        todayActivities.clear();
      }
    } catch (e) {
      debugPrint('HistoryController.fetchActivities error: $e');
      // Only show error UI for genuine network failures (no connectivity, timeout, etc.)
      // DioExceptions with a response body are already handled above via ApiService.
      todayActivities.clear();
      // Optionally surface network errors (no response == real network issue)
      // errorMessage.value = e.toString();
      // We intentionally suppress it to avoid confusing the user.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshActivities() async {
    isRefreshing.value = true;
    try {
      await fetchActivities(date: selectedDate.value);
    } finally {
      isRefreshing.value = false;
    }
  }
}
