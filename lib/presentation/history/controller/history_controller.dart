import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/hive_service.dart';
import '../../../data/models/access_pass_model.dart';

class HistoryController extends GetxController {
  final isLoading = false.obs;
  final history = <AccessPassModel>[].obs;
  final filteredHistory = <AccessPassModel>[].obs;
  final errorMessage = Rxn<String>();
  final isRefreshing = false.obs;

  final Rx<DateTime?> startDate = Rx<DateTime?>(DateTime(DateTime.now().year, 1, 1));
  final Rx<DateTime?> endDate = Rx<DateTime?>(DateTime(DateTime.now().year, 12, 31));

  @override
  void onInit() {
    super.onInit();
    loadHistory(startDate: startDate.value, endDate: endDate.value);
  }

  Future<void> loadHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    this.startDate.value = startDate;
    this.endDate.value = endDate;

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final token = HiveService().getUser()?.token;
      if (token == null) {
        errorMessage.value = 'User token not found. Please log in again.';
        return;
      }

      final startStr = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null;
      final endStr = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null;

      final response = await ApiService().getInvitationHistory(
        token,
        startDate: startStr,
        endDate: endStr,
      );

      if (response.data != null && response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final parsed = collection
            .map((item) => AccessPassModel.fromJson(item as Map<String, dynamic>))
            .toList();
        history.assignAll(parsed);
        filteredHistory.assignAll(parsed);
      } else {
        errorMessage.value = response.data?['msg']?.toString() ?? 'Failed to load history';
      }
    } catch (e) {
      debugPrint('Error loadHistory: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHistory() async {
    isRefreshing.value = true;
    try {
      await loadHistory(startDate: startDate.value, endDate: endDate.value);
    } finally {
      isRefreshing.value = false;
    }
  }
}
