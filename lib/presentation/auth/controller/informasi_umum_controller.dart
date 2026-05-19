import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/models/user_model.dart';
import '../../dashboard.dart';
import 'user_controller.dart';
import '../../home/controllers/guest_home_controller.dart';

class InformasiUmumController extends GetxController {
  final AuthDatasource authDatasource = AuthDatasource();
  final ApiService apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  late UserModel userModel;
  late String invitationCode;
  Map<String, dynamic>? rawData;

  // Page tracking
  late PageController pageController;
  final currentPage = 0.obs;

  // Step 1: Visitor Information
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final organizationController = TextEditingController();
  final identityIdController = TextEditingController();

  // Step 2: Purpose Visit (Read Only)
  final picHostController = TextEditingController();
  final agendaController = TextEditingController();
  final destinationController = TextEditingController();
  final visitStartController = TextEditingController();
  final visitEndController = TextEditingController();

  // Step 3: Vehicle/Parking Information
  final isDriving = true.obs;
  final vehicleType = 'Car'.obs;
  final vehiclePlateController = TextEditingController();
  // Free-text input shown when user selects 'Other' as vehicle type
  final vehicleOtherController = TextEditingController();

  // Step 4: Selfie Image
  final selfieImage = Rxn<File>();

  // Step 5: Upload Identity (KTP)
  final identityImage = Rxn<File>();

  final isLoading = false.obs;
  final isUploadingSelfie = false.obs;
  final isUploadingIdentity = false.obs;
  final selfieUrl = Rxn<String>();
  final identityUrl = Rxn<String>();
  final fieldErrors = RxMap<String, String?>();

  void initializeData(UserModel user, String code, Map<String, dynamic>? data) {
    userModel = user;
    invitationCode = code;
    rawData = data;

    // Reset navigation state — ensures fresh start every time page is opened
    currentPage.value = 0;
    fieldErrors.clear();
    selfieImage.value = null;
    identityImage.value = null;
    selfieUrl.value = null;
    identityUrl.value = null;
    isUploadingSelfie.value = false;
    isUploadingIdentity.value = false;
    final collection =
        rawData?['collection'] as Map<String, dynamic>? ?? rawData;

    isDriving.value = collection?['is_driving'] ?? false;
    vehicleType.value = collection?['vehicle_type']?.toString() ?? 'Car';

    // Recreate PageController so it's never disposed/stale
    try {
      pageController.dispose();
    } catch (_) {}
    pageController = PageController(initialPage: 0);

    // Prefill Step 1
    fullNameController.text = user.fullname ?? '';
    emailController.text = user.email ?? '';

    if (collection != null) {
      phoneController.text = collection['visitor_phone']?.toString() ?? '';
      organizationController.text =
          collection['visitor_organization_name']?.toString() ?? '';
      identityIdController.text =
          collection['visitor_identity_id']?.toString() ?? '';

      // Step 2
      picHostController.text = collection['host_name']?.toString() ?? '';
      agendaController.text = collection['agenda']?.toString() ?? '';
      destinationController.text =
          collection['site_place_name']?.toString() ?? '';
      visitStartController.text = _formatUtcToLocal(
        collection['visitor_period_start']?.toString(),
      );
      visitEndController.text = _formatUtcToLocal(
        collection['visitor_period_end']?.toString(),
      );

      // Step 3 (isDriving and vehicleType already set above)
      vehiclePlateController.text =
          collection['vehicle_plate_number']?.toString() ?? '';
    }

    // Eagerly mark empty required fields so red borders show on page open
    _markStep1Errors();
  }

  /// Konversi UTC datetime string ke local time dan format seperti web:
  /// "Rabu, 29 April 2026, 10:49"
  String _formatUtcToLocal(String? utcString) {
    if (utcString == null || utcString.isEmpty) return '';
    try {
      // Pastikan string diparse sebagai UTC
      String normalized = utcString;
      if (!normalized.endsWith('Z') && !normalized.contains('+')) {
        normalized = '${normalized}Z';
      }
      final utcDt = DateTime.parse(normalized).toLocal();
      return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(utcDt);
    } catch (_) {
      return utcString; // fallback: tampilkan raw jika parse gagal
    }
  }

  /// Silently marks fieldErrors for empty required fields in Step 1
  void _markStep1Errors() {
    final errors = <String, String?>{};
    if (fullNameController.text.trim().isEmpty) {
      errors['fullname'] = 'error_required'.trParams({'field': 'fullname'.tr});
    }
    if (emailController.text.trim().isEmpty) {
      errors['email'] = 'error_required'.trParams({'field': 'email'.tr});
    }
    if (phoneController.text.trim().isEmpty) {
      errors['phone'] = 'error_required'.trParams({'field': 'phone'.tr});
    }
    if (organizationController.text.trim().isEmpty) {
      errors['organization'] = 'error_required'.trParams({
        'field': 'organization'.tr,
      });
    }
    if (identityIdController.text.trim().isEmpty) {
      errors['identityId'] = 'error_required'.trParams({
        'field': 'identity_id'.tr,
      });
    }
    fieldErrors.assignAll(errors);
  }

  /// Validates a single field in real-time
  void validateField(String key, String value, String label) {
    if (value.trim().isEmpty) {
      fieldErrors[key] = 'error_required'.trParams({'field': label});

      // Show snackbar for the specific field that was just cleared
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      Get.snackbar(
        'Kolom Harus Diisi'.tr,
        '$label tidak boleh kosong.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
    } else {
      fieldErrors.remove(key);
    }
  }

  /// Called after first frame — marks errors AND shows snackbar if any required field is empty
  void showStep1WarningIfNeeded() {
    final emptyFields = <String>[];
    if (fullNameController.text.trim().isEmpty) {
      emptyFields.add('fullname'.tr);
    }
    if (emailController.text.trim().isEmpty) {
      emptyFields.add('email'.tr);
    }
    if (phoneController.text.trim().isEmpty) {
      emptyFields.add('phone'.tr);
    }
    if (organizationController.text.trim().isEmpty) {
      emptyFields.add('organization'.tr);
    }
    if (identityIdController.text.trim().isEmpty) {
      emptyFields.add('identity_id'.tr);
    }

    if (emptyFields.isEmpty) return;

    // Update red borders
    _markStep1Errors();

    // Show snackbar listing all empty fields
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.snackbar(
      'Mohon Lengkapi Data'.tr,
      'Kolom berikut wajib diisi: ${emptyFields.join(', ')}.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  void nextPage() {
    // Validate before proceeding
    if (currentPage.value == 0 && !validateStep1()) return;
    if (currentPage.value == 2 && !validateStep3()) return;

    if (currentPage.value < 4) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool validateStep1() {
    final errors = <String, String?>{};
    if (fullNameController.text.trim().isEmpty) {
      errors['fullname'] = 'Fullname';
    }
    if (emailController.text.trim().isEmpty) {
      errors['email'] = 'Email';
    }
    if (phoneController.text.trim().isEmpty) {
      errors['phone'] = 'Phone';
    }
    if (organizationController.text.trim().isEmpty) {
      errors['organization'] = 'Instansi/Organization';
    }
    if (identityIdController.text.trim().isEmpty) {
      errors['identityId'] = 'Identity Id (KTP)';
    }

    // Set red borders on all empty fields
    fieldErrors.assignAll(
      errors.map((k, v) => MapEntry(k, '$v belum diisi, mohon diisi')),
    );

    if (errors.isNotEmpty) {
      // Build a single message listing all missing fields
      final names = errors.values.join(', ');
      Get.snackbar(
        'Mohon Lengkapi Data',
        '$names belum diisi, mohon diisi terlebih dahulu.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return false;
    }
    return true;
  }

  bool validateStep3() {
    final errors = <String, String?>{};
    if (isDriving.value && vehiclePlateController.text.trim().isEmpty) {
      errors['vehiclePlate'] = 'Vehicle Plate Number belum diisi, mohon diisi';
    }

    fieldErrors.assignAll(errors);

    if (errors.isNotEmpty) {
      Get.snackbar(
        'Mohon Lengkapi Data',
        errors.values.first!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return false;
    }
    return true;
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> pickSelfie(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final file = File(picked.path);
      selfieImage.value = file;
      await uploadImage(file, true);
    }
  }

  Future<void> pickIdentity(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final file = File(picked.path);
      identityImage.value = file;
      await uploadImage(file, false);
    }
  }

  Future<void> uploadImage(File file, bool isSelfie) async {
    if (isSelfie) {
      isUploadingSelfie.value = true;
    } else {
      isUploadingIdentity.value = true;
    }

    try {
      final response = await apiService.uploadFile(file);
      debugPrint('Upload Response Data Type: ${response.data.runtimeType}');
      debugPrint('Upload Response Data: ${response.data}');

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          throw Exception('Format respon tidak valid (bukan JSON)');
        }
      }

      // If data is a List, take the first element (common in some APIs)
      Map<String, dynamic> responseMap;
      if (data is List && data.isNotEmpty) {
        responseMap = data[0] as Map<String, dynamic>;
      } else if (data is Map) {
        responseMap = data as Map<String, dynamic>;
      } else {
        throw Exception('Respon server tidak dikenali: $data');
      }

      if (response.statusCode == 200 && responseMap['status'] == 'success') {
        final collection = responseMap['collection'];
        String? url;

        if (collection is Map) {
          url = collection['file_url']?.toString();
        } else if (collection is List && collection.isNotEmpty) {
          url = collection[0]['file_url']?.toString();
        }

        if (url != null) {
          if (isSelfie) {
            selfieUrl.value = url;
          } else {
            identityUrl.value = url;
          }
          debugPrint('Upload Success: $url');
        } else {
          throw Exception('URL file tidak ditemukan dalam respon');
        }
      } else {
        final msg =
            responseMap['msg'] ?? responseMap['message'] ?? 'Gagal upload file';
        throw Exception(msg);
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        log('Error Response: ${e.response?.data}');
      }
      debugPrint('Dio Error uploadImage: ${e.message}');
      Get.snackbar(
        'Upload Gagal',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('Upload Error Detail: $e');
      Get.snackbar(
        'Upload Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (isSelfie) {
        isUploadingSelfie.value = false;
      } else {
        isUploadingIdentity.value = false;
      }
    }
  }

  Future<void> submit() async {
    isLoading.value = true;
    try {
      if (rawData == null) throw Exception("Data tidak lengkap (rawData null)");

      final collection =
          rawData!['collection'] as Map<String, dynamic>? ?? rawData!;

      // Copy question_page array to modify it
      List<dynamic> questionPage = [];
      dynamic raw;
      if (collection['question_page'] != null) {
        raw = collection['question_page'];
      } else if (collection['data_visitor'] is List &&
          (collection['data_visitor'] as List).isNotEmpty &&
          collection['data_visitor'][0]['question_page'] != null) {
        raw = collection['data_visitor'][0]['question_page'];
      } else if (rawData!['question_page'] != null) {
        raw = rawData!['question_page'];
      } else if (rawData!['data_visitor'] is List &&
          (rawData!['data_visitor'] as List).isNotEmpty &&
          rawData!['data_visitor'][0]['question_page'] != null) {
        raw = rawData!['data_visitor'][0]['question_page'];
      }

      if (raw != null) {
        // question_page bisa datang sebagai List atau Map (tergantung API response)
        List<dynamic> pageList;
        if (raw is List) {
          pageList = raw;
        } else if (raw is Map) {
          // Kalau Map, ambil values-nya sebagai List
          pageList = raw.values.toList();
        } else {
          pageList = [];
        }
        // Deep copy via JSON encode/decode agar tidak memodifikasi data original
        questionPage = jsonDecode(jsonEncode(pageList));
      }

      // formattedVehicleType: display name used inside question_page.form for record keeping.
      // When 'Other' is selected, use the free-text typed by the user.
      const vehicleDisplayNames = {
        'vehicle_car': 'Car',
        'vehicle_bus': 'Bus',
        'vehicle_motor': 'Motor',
        'vehicle_bicycle': 'Bicycle',
        'vehicle_truck': 'Truck',
        'vehicle_private_car': 'Private Car',
        'vehicle_other': 'Other',
      };
      final String formattedVehicleType;
      if (vehicleType.value == 'vehicle_other') {
        final typed = vehicleOtherController.text.trim();
        formattedVehicleType = typed.isNotEmpty ? typed : 'Other';
      } else {
        formattedVehicleType =
            vehicleDisplayNames[vehicleType.value] ?? vehicleType.value;
      }

      // enumVehicleType: EXACT case-sensitive values required by backend API multiple_option_fields.
      // If we don't send these exact strings, the backend rejects or silently drops the field.
      final String enumVehicleType;
      switch (vehicleType.value) {
        case 'vehicle_car':
        case 'Car':
          enumVehicleType = 'car';
          break;
        case 'vehicle_bus':
        case 'Bus':
          enumVehicleType = 'bus';
          break;
        case 'vehicle_motor':
        case 'Motor':
          enumVehicleType = 'motor';
          break;
        case 'vehicle_bicycle':
        case 'Bicycle':
          enumVehicleType = 'Bicycle'; // exact case from API
          break;
        case 'vehicle_truck':
        case 'Truck':
          enumVehicleType = 'truck';
          break;
        case 'vehicle_private_car':
        case 'Private Car':
          enumVehicleType = 'private_car';
          break;
        case 'vehicle_other':
        case 'Other':
          enumVehicleType = 'Other'; // exact case from API
          break;
        default:
          enumVehicleType = 'car';
      }

      // Helper to generate dynamic UUID v4
      String generateUuid() {
        final random = Random();
        const hexDigits = '0123456789abcdef';
        String randomHex(int length) {
          return List.generate(length, (_) => hexDigits[random.nextInt(16)]).join();
        }
        return '${randomHex(8)}-${randomHex(4)}-4${randomHex(3)}-${hexDigits[random.nextInt(4) + 8]}${randomHex(3)}-${randomHex(12)}';
      }

      // Find the vehicle page in questionPage (even if form is empty) and fill in the fields.
      // This avoids creating a duplicate page when the backend returns an empty vehicle page.
      final List<Map<String, dynamic>> vehicleFormFields = [
        {
          "sort": 0,
          "short_name": "Is Driving/Riding",
          "long_display_text": "Are you driving?",
          "field_type": 5,
          "is_primary": true,
          "is_enable": true,
          "mandatory": true,
          "remarks": "is_driving",
          "custom_field_id": generateUuid(),
          "multiple_option_fields": [],
          "visitor_form_type": 1,
          "answer_text": isDriving.value.toString(),
        },
        {
          "sort": 1,
          "short_name": "Vehicle Type",
          "long_display_text": "Vehicle Type",
          "field_type": 5,
          "is_primary": true,
          "is_enable": true,
          "mandatory": true,
          "remarks": "vehicle_type",
          "custom_field_id": generateUuid(),
          "multiple_option_fields": [],
          "visitor_form_type": 1,
          "answer_text": isDriving.value ? formattedVehicleType : "",
        },
        {
          "sort": 2,
          "short_name": "Vehicle Plate",
          "long_display_text": "Vehicle Plate Number",
          "field_type": 0,
          "is_primary": true,
          "is_enable": true,
          "mandatory": true,
          "remarks": "vehicle_plate",
          "custom_field_id": generateUuid(),
          "multiple_option_fields": [],
          "visitor_form_type": 1,
          "answer_text": isDriving.value ? vehiclePlateController.text : "",
        },
      ];

      // Check if there is already a vehicle page (with or without fields).
      bool vehiclePageFilled = false;
      for (var page in questionPage) {
        if (page is Map) {
          final pageName = (page['name'] as String? ?? '').toLowerCase();
          if (pageName.contains('vehicle') || pageName.contains('parking')) {
            // Found the vehicle page — fill/replace its form fields with our values
            final existingForm = page['form'];
            if (existingForm is List && existingForm.isNotEmpty) {
              // Page already has fields — update answer_text values dynamically
              for (var field in existingForm) {
                if (field is Map) {
                  if (field['remarks'] == 'is_driving') {
                    field['answer_text'] = isDriving.value.toString();
                  } else if (field['remarks'] == 'vehicle_type') {
                    field['answer_text'] = isDriving.value ? formattedVehicleType : '';
                  } else if (field['remarks'] == 'vehicle_plate') {
                    field['answer_text'] = isDriving.value ? vehiclePlateController.text : '';
                  }
                }
              }
            } else {
              // Page exists but form is empty — inject our fields into it
              debugPrint('Vehicle page found with empty form, filling in fields...');
              page['form'] = vehicleFormFields;
            }
            vehiclePageFilled = true;
            break;
          }
        }
      }

      if (!vehiclePageFilled) {
        // No vehicle page found at all — add a new one
        debugPrint('No vehicle page found in questionPage, injecting new Vehicle/Parking Information page...');
        questionPage.add({
          "id": generateUuid(),
          "sort": questionPage.length,
          "name": "Vehicle/Parking Information",
          "status": 0,
          "is_document": false,
          "can_multiple_used": false,
          "self_only": false,
          "foreign_id": "",
          "form": vehicleFormFields,
        });
      }

      // Log the full questionPage structure for debugging
      debugPrint('=== DEBUG: questionPage PAGES AND FIELDS ===');
      for (int i = 0; i < questionPage.length; i++) {
        final page = questionPage[i];
        if (page is Map) {
          debugPrint('Page $i: "${page['name']}" (id: ${page['id']})');
          final form = page['form'];
          if (form is List) {
            for (var formField in form) {
              if (formField is Map) {
                debugPrint(
                  '  Field: "${formField['short_name']}" | remarks: "${formField['remarks']}" | type: ${formField['field_type']}',
                );
              }
            }
          }
        }
      }
      debugPrint('============================================');

      // Helper function to update answers (more flexible: search all pages if needed)
      void updateAnswer(
        String fieldShortName,
        dynamic value, {
        bool isFile = false,
      }) {
        bool found = false;

        // Map common field short names to their machine-readable remarks fallback
        final Map<String, String> keyToRemarks = {
          'full name': 'name',
          'email': 'email',
          'phone': 'phone',
          'organization': 'organization',
          'indentity id': 'indentity_id',
          'agenda': 'agenda',
          'visit start': 'visitor_period_start',
          'visit end': 'visitor_period_end',
          'is driving/riding': 'is_driving',
          'vehicle type': 'vehicle_type',
          'vehicle plate': 'vehicle_plate',
          'vehicle plate number': 'vehicle_plate',
          'selfie image': 'selfie_image',
          'identity image': 'identity_image',
        };

        final String searchKey = fieldShortName.toLowerCase().trim();
        final String? mappedRemarks = keyToRemarks[searchKey];

        for (var page in questionPage) {
          // Guard: page harus Map, bukan String (bisa terjadi kalau iterasi Map keys)
          if (page is! Map) continue;
          final form = page['form'];
          if (form is! List) continue;
          for (var formField in form) {
            if (formField is! Map) continue;

            final String shortName = formField['short_name']
                .toString()
                .toLowerCase()
                .trim();
            final String remarks = formField['remarks']
                .toString()
                .toLowerCase()
                .trim();

            if (shortName == searchKey ||
                remarks == searchKey ||
                (mappedRemarks != null && remarks == mappedRemarks) ||
                (searchKey == 'vehicle plate' &&
                    (remarks == 'vehicle_plate' ||
                        remarks == 'vehicle_plate_number')) ||
                (remarks == 'vehicle_plate' && searchKey.contains('plate')) ||
                (remarks == 'vehicle_plate_number' &&
                    searchKey.contains('plate'))) {
              final fieldType = formField['field_type'];

              // 1. field_type 10, 11, 12 -> answer_file
              if (fieldType == 10 || fieldType == 11 || fieldType == 12) {
                formField['answer_file'] = value?.toString();
                formField.remove('answer_text');
                formField.remove('answer_datetime');
              } else if (fieldType == 9) {
                if (value != null && value.toString().isNotEmpty) {
                  // Keep clean ISO YYYY-MM-DDTHH:mm:ss format without Z suffix to prevent backend offset shifting
                  String dtVal = value.toString();
                  if (dtVal.contains('.')) {
                    dtVal = dtVal.replaceAll(RegExp(r'\.\d+'), '');
                  }
                  if (dtVal.endsWith('Z')) {
                    dtVal = dtVal.substring(0, dtVal.length - 1);
                  } else if (dtVal.contains('+')) {
                    dtVal = dtVal.split('+').first;
                  }
                  formField['answer_datetime'] = dtVal;
                  formField.remove('answer_text');
                  formField.remove('answer_file');
                } else {
                  formField.remove('answer_datetime');
                }
              }
              // 3. rest -> answer_text
              else {
                formField['answer_text'] = value?.toString();
                formField.remove('answer_datetime');
                formField.remove('answer_file');
              }

              debugPrint(
                'Updated Answer: $fieldShortName (remarks: $remarks) -> $value',
              );
              found = true;
            }
          }
        }
        if (!found) {
          debugPrint(
            'Warning: Field not found in questionPage: $fieldShortName',
          );
        }
      }

      // Log all rawData keys for debugging
      debugPrint('rawData keys: ${rawData?.keys.toList()}');

      // Log nested objects for debugging
      debugPrint('host_data: ${rawData?['host_data']}');
      debugPrint('host: ${rawData?['host']}');
      debugPrint('trx_visitor_sites: ${rawData?['trx_visitor_sites']}');

      // ── Step 1: User-editable visitor info fields ──────────────────
      updateAnswer('Full Name', fullNameController.text);
      updateAnswer('Email', emailController.text);
      updateAnswer('Phone', phoneController.text);
      updateAnswer('Organization', organizationController.text);
      updateAnswer('Indentity Id', identityIdController.text);

      // ── Step 2 (Purpose of Visit) ──────────────────────────────────
      updateAnswer('Agenda', collection['agenda']);
      updateAnswer('Visit Start', collection['visitor_period_start']);
      updateAnswer('Visit End', collection['visitor_period_end']);

      // ── Step 3: Vehicle fields ───────────────────────────────────────
      updateAnswer('Is Driving/Riding', isDriving.value.toString());
      updateAnswer('Vehicle Type', formattedVehicleType);
      updateAnswer('Vehicle Plate', vehiclePlateController.text);

      // ── Step 4 & 5: Photos ──────────────────────────────────────────
      String? selfieValue = selfieUrl.value;
      if (selfieValue == null && selfieImage.value != null) {
        final bytes = await selfieImage.value!.readAsBytes();
        selfieValue = "data:image/jpeg;base64,${base64Encode(bytes)}";
      }
      updateAnswer('Selfie Image', selfieValue, isFile: true);

      String? identityValue = identityUrl.value;
      if (identityValue == null && identityImage.value != null) {
        final bytes = await identityImage.value!.readAsBytes();
        identityValue = "data:image/jpeg;base64,${base64Encode(bytes)}";
      }
      updateAnswer('Identity Image', identityValue, isFile: true);

      // ── Dynamic Site Detection ───────────────────────────────────────
      String? sitePlaceId;
      for (var page in questionPage) {
        if (page is! Map) continue;
        final form = page['form'];
        if (form is! List) continue;
        for (var field in form) {
          if (field is! Map) continue;
          if (field['remarks'] == 'site_place') {
            sitePlaceId = field['answer_text']?.toString();
            debugPrint('site_place from question_page: $sitePlaceId');
            break;
          }
        }
        if (sitePlaceId != null) break;
      }

      final String rootSiteId = sitePlaceId ?? "";
      debugPrint('Final registered_site: $rootSiteId');

      void updateAnswerByRemarks(String remarks, String? value) {
        for (var page in questionPage) {
          if (page is! Map) continue;
          final form = page['form'];
          if (form is! List) continue;
          for (var field in form) {
            if (field is! Map) continue;
            if (field['remarks'] == remarks) {
              final fieldType = field['field_type'];
              if (fieldType == 9) {
                if (value != null && value.isNotEmpty) {
                  // Keep clean ISO YYYY-MM-DDTHH:mm:ss format without Z suffix to prevent backend offset shifting
                  String dtVal = value;
                  if (dtVal.contains('.')) {
                    dtVal = dtVal.replaceAll(RegExp(r'\.\d+'), '');
                  }
                  if (dtVal.endsWith('Z')) {
                    dtVal = dtVal.substring(0, dtVal.length - 1);
                  } else if (dtVal.contains('+')) {
                    dtVal = dtVal.split('+').first;
                  }
                  field['answer_datetime'] = dtVal;
                  field.remove('answer_text');
                }
              } else if (fieldType == 10 ||
                  fieldType == 11 ||
                  fieldType == 12) {
                field['answer_file'] = value;
                field.remove('answer_text');
              } else {
                field['answer_text'] = value;
              }
              debugPrint('Set remarks=$remarks → $value (type $fieldType)');
            }
          }
        }
      }

      final String? hostId = collection['host']?.toString();
      updateAnswerByRemarks('host', hostId);

      // ── Build payload ─────────────────────────────────────────────────
      // Always use 'id' field for trx_visitor_id
      final trxVisitorId = collection['id']?.toString();
      final visitorTypeId = collection['visitor_type']?.toString();
      final visitorRole = collection['visitor_role'] ?? "Visitor";
      final applicationId = collection['application_id']?.toString();
      final visitorId = collection['visitor_id']?.toString();

      debugPrint(
        'trx_visitor_id: $trxVisitorId | site_place: $rootSiteId | visitor_type: $visitorTypeId',
      );

      // Final defensive check on questionPage: ensure no nulls, but respect field_type rules
      for (var page in questionPage) {
        if (page is! Map) continue;
        final form = page['form'];
        if (form is! List) continue;
        for (var field in form) {
          if (field is! Map) continue;
          final fType = field['field_type'];
          if (fType == 9) {
            // Datetime: ensure answer_text is NOT present if we have datetime
            if (field['answer_datetime'] == null) {
              field['answer_datetime'] = "";
            }
            field.remove('answer_text');
          } else if (fType == 10 || fType == 11 || fType == 12) {
            // File: ensure answer_text is NOT present
            if (field['answer_file'] == null) {
              field['answer_file'] = "";
            }
            field.remove('answer_text');
          } else {
            // Text: ensure answer_text is never null
            if (field['answer_text'] == null) {
              field['answer_text'] = "";
            }
            field.remove('answer_datetime');
            field.remove('answer_file');
          }
        }
      }

      final payload = {
        "trx_visitor_id": trxVisitorId,
        "visitor_id": visitorId,
        "application_id": applicationId,
        "visitor_type": visitorTypeId,
        "type_registered": 0,
        "is_group": collection['is_group'] ?? false,
        "tz": collection['tz'] ?? "Asia/Jakarta",
        "registered_site": rootSiteId,
        "flow": "SubmitPraregister",
        "visitor_role": visitorRole,
        "is_driving": isDriving.value,
        // Use enumVehicleType (Car/Bus/Motor) at root level — backend validates against its enum
        "vehicle_type": isDriving.value ? enumVehicleType : "",
        "vehicle_plate_number": isDriving.value
            ? vehiclePlateController.text
            : "",
        "vehicle_plate": isDriving.value ? vehiclePlateController.text : "",
        "data_visitor": [
          {
            // vehicle_type at data_visitor level also uses enum-safe value
            "vehicle_type": isDriving.value ? enumVehicleType : "",
            "vehicle_plate": isDriving.value ? vehiclePlateController.text : "",
            "question_page": questionPage,
          },
        ],
      };

      debugPrint('=== SUBMIT PRA FORM ===');
      final payloadJson = jsonEncode(payload);
      // Chunk the payload since debugPrint has a character limit
      const chunkSize = 800;
      for (int i = 0; i < payloadJson.length; i += chunkSize) {
        debugPrint(payloadJson.substring(i, i + chunkSize > payloadJson.length ? payloadJson.length : i + chunkSize));
      }

      // Submit form — retry sampai 2x karena backend kadang butuh percobaan kedua
      dio.Response? submitResponse;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          submitResponse = await apiService.submitPraForm(
            payload,
            token: userModel.token,
          );
          if (submitResponse.statusCode == 200) break; // sukses, stop retry
          debugPrint(
            'Submit attempt $attempt: status ${submitResponse.statusCode}, retrying...',
          );
          // Print response body to help diagnose 400 errors
          debugPrint('Response body: ${submitResponse.data}');
        } catch (e) {
          debugPrint('Submit attempt $attempt failed: $e');
          if (attempt == 3) rethrow; // gagal semua, lempar error
        }
        await Future.delayed(const Duration(milliseconds: 800));
      }
      log('Submit Response: ${submitResponse?.data}');

      if (submitResponse == null) {
        throw Exception('Tidak ada response dari server');
      }

      final responseData = submitResponse.data;
      if (submitResponse.statusCode != 200 ||
          (responseData is Map && responseData['status'] == 'bad_request')) {
        String errorMsg = 'Bad Request';
        if (responseData is Map) {
          errorMsg = responseData['msg']?.toString() ?? 'Bad Request';
          final collection = responseData['collection'];
          if (collection is List && collection.isNotEmpty) {
            final detail = collection.map((e) => e['message']).join(', ');
            throw Exception('$errorMsg: $detail');
          }
        } else if (responseData is String) {
          errorMsg = responseData;
        }
        throw Exception(errorMsg);
      }

      final submitMsg = responseData is Map
          ? responseData['msg']?.toString() ?? 'Form berhasil dikirim'
          : 'Form berhasil dikirim';
      final submitTitle = responseData is Map ? responseData['title']?.toString() : null;

      // After submit success, re-check invitation code to get the token
      final (newUser, isPraregisterDone, _, error, checkTitle) =
          await authDatasource.checkVisitorCode(invitationCode);

      if (newUser != null && isPraregisterDone && newUser.token != null) {
        // checkVisitorCode already saved to Hive, just reload UserController
        final userCtrl = Get.isRegistered<UserController>()
            ? Get.find<UserController>()
            : Get.put(UserController());
        await userCtrl.loadUser();
        Get.snackbar(
          (submitTitle ?? checkTitle ?? 'success').capitalizeFirst ?? 'Success',
          submitMsg, // use msg from submit API response
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Ensure guest home data is fresh
        Get.delete<GuestHomeController>(force: true);

        Get.offAll(() => const Dashboard());
      } else {
        // Submit sukses tapi token belum tersedia
        throw Exception(
          error ??
              'Form berhasil dikirim, namun login otomatis gagal. Coba masukkan kode undangan kembali.',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    try {
      pageController.dispose();
    } catch (_) {}
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    identityIdController.dispose();
    picHostController.dispose();
    agendaController.dispose();
    destinationController.dispose();
    visitStartController.dispose();
    visitEndController.dispose();
    vehiclePlateController.dispose();
    vehicleOtherController.dispose();
    super.onClose();
  }
}
