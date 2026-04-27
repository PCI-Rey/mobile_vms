import 'dart:convert';
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
  final Rx<bool?> isGroup = Rx<bool?>(null);
  final RxInt currentStep = 0.obs;
  final RxInt formUpdateTrigger = 0.obs;

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
      Get.snackbar(
        'Error',
        'Token tidak ditemukan. Silakan login kembali.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoadingTypes.value = true;
    try {
      final response = await _api.getVisitorTypes(token);
      debugPrint('=== VISITOR TYPES RESPONSE ===');
      debugPrint('Status: ${response.data['status']}');
      debugPrint(
        'Collection length: ${(response.data['collection'] as List?)?.length}',
      );
      debugPrint('Full response: ${response.data}');
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        visitorTypes.value = collection
            .map((e) => VisitorTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final msg =
            response.data['msg']?.toString() ?? 'Gagal memuat tipe visitor';
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('fetchVisitorTypes error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      debugPrint('=== VISITOR TYPE DETAIL RESPONSE ===');
      debugPrint(jsonEncode(response.data));
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as Map<String, dynamic>? ?? {};
        selectedTypeDetail.value = VisitorTypeDetailModel.fromJson(collection);
      } else {
        final msg =
            response.data['msg']?.toString() ??
            'Gagal memuat detail tipe visitor';
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('fetchVisitorTypeDetail error: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void nextStep() {
    // Don't advance while visitor type detail is still loading
    if (isLoadingDetail.value) return;
    if (currentStep.value < 2) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void updateForm() {
    formUpdateTrigger.value++;
  }

  bool validateCurrentStep() {
    // ignore: unused_local_variable
    final _ = formUpdateTrigger.value; // ensure reactivity

    final detail = selectedTypeDetail.value;
    if (detail == null) return false;

    final sections = detail.sectionPageVisitorTypes;

    // Step 1: Visitor Information
    if (currentStep.value == 1) {
      final section = sections.firstWhereOrNull(
            (s) => s.name.toLowerCase().contains('visitor'),
          ) ??
          sections.firstOrNull;
      if (section == null) return true;
      for (var field in section.visitForm) {
        if (field.mandatory && field.answerText.trim().isEmpty) return false;
      }
      return true;
    }

    // Step 2: Purpose Visit - Force all fields to be required
    if (currentStep.value == 2) {
      final section = sections.firstWhereOrNull(
            (s) => s.name.toLowerCase().contains('purpose'),
          ) ??
          (sections.length > 1 ? sections[1] : null);
      if (section == null) return true;
      for (var field in section.visitForm) {
        // Treat every field as mandatory for Step 2
        if (field.answerText.trim().isEmpty) return false;
      }
      return true;
    }

    return true;
  }

  Future<bool> submitForm() async {
    final token = _token;
    if (token == null) {
      Get.snackbar(
        'Error',
        'Token tidak ditemukan.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    final detail = selectedTypeDetail.value;
    if (detail == null) {
      Get.snackbar(
        'Error',
        'Data form tidak lengkap.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
          'form': section.visitForm.map((f) {
            final json = f.toJson();

            // 1. For document/image fields (10, 11, 12)
            if ([10, 11, 12].contains(f.fieldType)) {
              json['answer_file'] = f.answerText;
              json.remove('answer_text');
            }

            // 2. For datetime fields (4=Date, 9=DateTime)
            final isDateTime = f.fieldType == 4 ||
                f.fieldType == 9 ||
                f.remarks == "visitor_period_start" ||
                f.remarks == "visitor_period_end";

            if (isDateTime && f.answerDatetime.isNotEmpty) {
              try {
                final dt = DateTime.parse(f.answerDatetime);
                // Endpoint wants .000Z format
                json['answer_datetime'] = dt.toUtc().toIso8601String();
                json.remove('answer_text');
              } catch (_) {}
            } else {
              // 3. Remove answer_datetime if not used or empty
              if (f.answerDatetime.isEmpty) {
                json.remove('answer_datetime');
              }
            }

            return json;
          }).toList(),
        };
      }).toList();

      final body = {
        'visitor_type': selectedVisitorTypeName.value,
        'type_registered': 1,
        'is_group': isGroup.value ?? false,
        'tz': 'Asia/Jakarta',
        'registered_site': '',
        'flow': 'Invitation',
        'visitor_role': 'Visitor',
        'data_visitor': [
          {'question_page': questionPage},
        ],
      };

      debugPrint('=== SUBMIT PAYLOAD ===');
      final payloadStr = jsonEncode(body);
      for (int i = 0; i < payloadStr.length; i += 800) {
        debugPrint(payloadStr.substring(
            i, i + 800 > payloadStr.length ? payloadStr.length : i + 800));
      }

      final response = await _api.submitNewVisit(
        token,
        body,
      );

      debugPrint('=== SUBMIT RESPONSE ===');
      debugPrint(jsonEncode(response.data));

      final title =
          response.data['title']?.toString().capitalizeFirst ?? 'Success';
      final msg = response.data['msg']?.toString() ?? '';

      if (response.data['status'] == 'success') {
        debugPrint('Submit PRA Form berhasil: ${response.data['msg']}');
        Get.snackbar(
          title,
          msg,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          title,
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      debugPrint('submitForm error: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetForm() {
    selectedVisitorTypeId.value = '';
    selectedVisitorTypeName.value = '';
    selectedTypeDetail.value = null;
    isGroup.value = null;
    currentStep.value = 0;
  }
}
