import 'package:get/get.dart';
import '../../../../data/datasources/approval_datasource.dart';
import '../../../../data/models/approval_model.dart';
import '../../../../core/core.dart';

class ApprovalController extends GetxController {
  final isLoading = false.obs;
  final approvals = <ApprovalModel>[].obs;
  final filteredApprovals = <ApprovalModel>[].obs;
  final errorMessage = Rxn<String>();
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadApprovals();
  }

  Future<void> loadApprovals() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await dummyGetAllApprovals();
      approvals.assignAll(result);
      filteredApprovals.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshApprovals() async {
    isRefreshing.value = true;
    try {
      await loadApprovals();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadApprovalsWithFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? gedung,
    VisitorStatus? status,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await dummyGetApprovalsWithFilter(
        startDate: startDate,
        endDate: endDate,
        gedung: gedung,
        status: status,
      );
      filteredApprovals.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveVisitor(String id) async {
    // Show loading indicator or handle optimistic update if needed
    // For now, let's just reload or update locally
    try {
      await dummyApproveApproval(id);
      // Refresh list
      await loadApprovals(); // Or specific filter if active
      Get.snackbar(
        'Berhasil',
        'Visitor berhasil disetujui',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> denyVisitor(String id) async {
    try {
      await dummyDenyApproval(id);
      await loadApprovals();
      Get.snackbar(
        'Berhasil',
        'Visitor ditolak',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }
}
