import 'package:get/get.dart';
import '../../../../data/datasources/visit_history_datasource.dart';
import '../../../../data/models/visit_history_model.dart';
// import '../../../../core/core.dart'; // Removed unused import

class HistoryController extends GetxController {
  final isLoading = false.obs;
  final history = <VisitHistoryModel>[].obs;
  final filteredHistory = <VisitHistoryModel>[].obs;
  final errorMessage = Rxn<String>();
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await dummyGetAllHistory();
      history.assignAll(result);
      filteredHistory.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHistory() async {
    isRefreshing.value = true;
    try {
      await loadHistory();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? location,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await dummyGetHistoryWithFilters(
        startDate: startDate,
        endDate: endDate,
        location: location,
      );
      filteredHistory.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
