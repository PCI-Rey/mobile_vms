import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../../../data/datasources/visitor_datasource.dart';
import '../../../../data/models/visitor_model.dart';

class VisitorController extends GetxController {
  final isLoading = false.obs;
  final visitors = <VisitorListModel>[].obs;
  final filteredVisitors = <VisitorListModel>[].obs;
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
      final result = await dummyGetAllVisitors();
      visitors.assignAll(result);
      filteredVisitors.assignAll(result);
      _calculateStats();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    // Dummy logic for stats - replace with actual logic if available from backend
    todayVisitCount.value = visitors.length;
    checkInCount.value = visitors
        .where((v) => v.visitor.statusEnum == VisitorStatus.checkedIn)
        .length;
    denyCount.value = visitors
        .where((v) => v.visitor.statusEnum == VisitorStatus.denied)
        .length;
    blockCount.value = 0; // No block status in dummy data
  }

  Future<void> searchVisitors(String query) async {
    if (query.isEmpty) {
      filteredVisitors.assignAll(visitors);
      return;
    }

    isLoading.value = true;
    try {
      final result = await dummySearchVisitors(query);
      filteredVisitors.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveVisitor(String id) async {
    try {
      await dummyApproveVisitor(id);
      await loadVisitors(); // Refresh list
      Get.snackbar('Success', 'Visitor approved');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> denyVisitor(String id) async {
    try {
      await dummyDenyVisitor(id);
      await loadVisitors();
      Get.snackbar('Success', 'Visitor denied');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> checkInVisitor(String id) async {
    try {
      await dummyCheckInVisitor(id);
      await loadVisitors();
      Get.snackbar('Success', 'Visitor checked in');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> checkOutVisitor(String id) async {
    try {
      await dummyCheckOutVisitor(id);
      await loadVisitors();
      Get.snackbar('Success', 'Visitor checked out');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
