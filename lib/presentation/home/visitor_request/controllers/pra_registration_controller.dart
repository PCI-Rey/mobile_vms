import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/visitor_type_model.dart';
import '../../../../data/models/visitor_type_detail_model.dart';

class PraRegistrationController extends GetxController {
  final _api = ApiService();
  final _hive = HiveService();

  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<VisitorTypeModel> visitorTypes = <VisitorTypeModel>[].obs;
  final Rx<VisitorTypeDetailModel?> selectedTypeDetail =
      Rx<VisitorTypeDetailModel?>(null);
  final RxBool isLoadingTypes = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxString selectedVisitorTypeId = ''.obs;
  final RxString selectedVisitorTypeName = ''.obs;
  final RxBool isGroup = false.obs;
  final RxInt currentStep = 0.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchVisitorTypes();
  }

  // ─── Token helper ─────────────────────────────────────────────────────────
  String? get _token => _hive.getUser()?.token;

  // ─── Methods ──────────────────────────────────────────────────────────────

  Future<void> fetchVisitorTypes() async {
    final token = _token;
    if (token == null) {
      Get.snackbar('Error', 'Token tidak ditemukan. Silakan login kembali.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoadingTypes.value = true;
    try {
      final response = await _api.getVisitorTypes(token);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        visitorTypes.value = collection
            .map((e) => VisitorTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final msg = response.data['msg']?.toString() ?? 'Gagal memuat tipe visitor';
        Get.snackbar('Error', msg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('fetchVisitorTypes error: $e');
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat data.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> onSelectVisitorType(String id, String name) async {
    selectedVisitorTypeId.value = id;
    selectedVisitorTypeName.value = name;
    selectedTypeDetail.value = null;
    await fetchVisitorTypeDetail();
  }

  Future<void> fetchVisitorTypeDetail() async {
    final token = _token;
    final id = selectedVisitorTypeId.value;
    if (token == null || id.isEmpty) return;

    isLoadingDetail.value = true;
    try {
      final response = await _api.getVisitorTypeById(token, id);
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as Map<String, dynamic>? ?? {};
        selectedTypeDetail.value = VisitorTypeDetailModel.fromJson(collection);
      } else {
        final msg =
            response.data['msg']?.toString() ?? 'Gagal memuat detail tipe visitor';
        Get.snackbar('Error', msg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('fetchVisitorTypeDetail error: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void nextStep() {
    if (currentStep.value < 2) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  Future<bool> submitForm() async {
    final token = _token;
    if (token == null) {
      Get.snackbar('Error', 'Token tidak ditemukan.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    final detail = selectedTypeDetail.value;
    if (detail == null) {
      Get.snackbar('Error', 'Data form tidak lengkap.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    isSubmitting.value = true;
    try {
      // Build question_page from sections
      final questionPage = detail.sectionPageVisitorTypes.map((section) {
        return {
          'id': section.id,
          'sort': section.sort,
          'name': section.name,
          'status': 1,
          'is_document': section.isDocument,
          'can_multiple_used': section.canMultipleUsed,
          'self_only': false,
          'foreign_id': section.foreignId,
          'form': section.visitForm.map((f) => f.toJson()).toList(),
        };
      }).toList();

      final body = {
        'visitor_type': selectedVisitorTypeName.value,
        'type_registered': 1,
        'is_group': isGroup.value,
        'tz': 'Asia/Jakarta',
        'registered_site': '',
        'data_visitor': [
          {'question_page': questionPage}
        ],
      };

      final response = await _api.submitPraFormOperator(
        token,
        selectedVisitorTypeId.value,
        body,
      );

      final title = response.data['title']?.toString().capitalizeFirst ?? 'Success';
      final msg = response.data['msg']?.toString() ?? '';

      if (response.data['status'] == 'success') {
        debugPrint('Submit PRA Form berhasil: ${response.data['msg']}');
        Get.snackbar(title, msg,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
        return true;
      } else {
        Get.snackbar(title, msg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
        return false;
      }
    } catch (e) {
      debugPrint('submitForm error: $e');
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetForm() {
    selectedVisitorTypeId.value = '';
    selectedVisitorTypeName.value = '';
    selectedTypeDetail.value = null;
    isGroup.value = false;
    currentStep.value = 0;
  }
}
