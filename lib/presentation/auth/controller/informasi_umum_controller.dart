import 'dart:developer';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
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
    isDriving.value = rawData?['is_driving'] ?? false;
    vehicleType.value = rawData?['vehicle_type']?.toString() ?? 'Car';

    // Recreate PageController so it's never disposed/stale
    try {
      pageController.dispose();
    } catch (_) {}
    pageController = PageController(initialPage: 0);

    // Prefill Step 1
    fullNameController.text = user.fullname ?? '';
    emailController.text = user.email ?? '';

    if (rawData != null) {
      phoneController.text = rawData?['visitor_phone']?.toString() ?? '';
      organizationController.text =
          rawData?['visitor_organization_name']?.toString() ?? '';
      identityIdController.text =
          rawData?['visitor_identity_id']?.toString() ?? '';

      // Step 2
      picHostController.text = rawData?['host_name']?.toString() ?? '';
      agendaController.text = rawData?['agenda']?.toString() ?? '';
      destinationController.text =
          rawData?['site_place_name']?.toString() ?? '';
      visitStartController.text =
          rawData?['visitor_period_start']?.toString() ?? '';
      visitEndController.text =
          rawData?['visitor_period_end']?.toString() ?? '';

      // Step 3 (isDriving and vehicleType already set above)
      vehiclePlateController.text =
          rawData?['vehicle_plate_number']?.toString() ?? '';
    }

    // Eagerly mark empty required fields so red borders show on page open
    _markStep1Errors();
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
    } on DioException catch (e) {
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

      // Copy question_page array to modify it
      List<dynamic> questionPage = [];
      if (rawData!['question_page'] != null) {
        // Deep copy via JSON encode/decode to avoid modifying original safely
        questionPage = jsonDecode(jsonEncode(rawData!['question_page']));
      }

      // Helper function to update answers (more flexible: search all pages if needed)
      void updateAnswer(
        String fieldShortName,
        dynamic value, {
        bool isFile = false,
      }) {
        bool found = false;
        for (var page in questionPage) {
          final form = page['form'] as List?;
          if (form == null) continue;
          for (var formField in form) {
            if (formField['short_name'].toString().toLowerCase().trim() ==
                fieldShortName.toLowerCase().trim()) {
              final fieldType = formField['field_type'];

              // 1. field_type 10, 11, 12 -> answer_file
              if (fieldType == 10 || fieldType == 11 || fieldType == 12) {
                formField['answer_file'] = value?.toString();
                formField.remove('answer_text');
                formField.remove('answer_datetime');
              }
              // 2. field_type 9 -> answer_datetime
              else if (fieldType == 9) {
                if (value != null && value.toString().isNotEmpty) {
                  try {
                    final dt = DateTime.parse(value.toString());
                    formField['answer_datetime'] = dt.toUtc().toIso8601String();
                    formField.remove('answer_text');
                    formField.remove('answer_file');
                  } catch (e) {
                    debugPrint('Error parsing date for $fieldShortName: $e');
                    formField['answer_text'] = value.toString();
                  }
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

              debugPrint('Updated Answer: $fieldShortName -> $value');
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
      updateAnswer('Agenda', rawData?['agenda']);
      updateAnswer('Visit Start', rawData?['visitor_period_start']);
      updateAnswer('Visit End', rawData?['visitor_period_end']);

      // ── Step 3: Vehicle fields ───────────────────────────────────────
      updateAnswer('Is Driving/Riding', isDriving.value.toString());
      updateAnswer('Vehicle Type', vehicleType.value);
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
      try {
        final siteResp = await apiService.getSites(invitationCode);
        if (siteResp.statusCode == 200 &&
            siteResp.data['status'] == 'success') {
          final collection = siteResp.data['collection'] as List?;
          if (collection != null && collection.isNotEmpty) {
            sitePlaceId = collection[0]['id']?.toString();
            debugPrint('Dynamically found site ID: $sitePlaceId');
          }
        }
      } catch (e) {
        debugPrint('Warning: Failed to fetch sites dynamically: $e');
      }

      // Fallback to null if empty, server might prefer null over "" for unknown site
      final String rootSiteId = sitePlaceId ?? "";

      void updateAnswerByRemarks(String remarks, String? value) {
        for (var page in questionPage) {
          final form = page['form'] as List?;
          if (form == null) continue;
          for (var field in form) {
            if (field['remarks'] == remarks) {
              final fieldType = field['field_type'];
              if (fieldType == 9) {
                if (value != null && value.isNotEmpty) {
                  try {
                    final dt = DateTime.parse(value);
                    field['answer_datetime'] = dt.toUtc().toIso8601String();
                    field.remove('answer_text');
                  } catch (e) {
                    field['answer_text'] = value;
                  }
                }
              } else if (fieldType == 10 || fieldType == 11 || fieldType == 12) {
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

      final String? hostId = rawData!['host']?.toString();
      updateAnswerByRemarks('host', hostId);
      updateAnswerByRemarks('site_place', sitePlaceId);

      // ── Build payload ─────────────────────────────────────────────────
      // Prefer transaction_visitor_id for the root field
      final trxVisitorId = rawData!['transaction_visitor_id'] ?? rawData!['id'];
      final visitorTypeId = rawData!['visitor_type']?.toString();

      // PraRegistrationController uses NAME for visitor_type in payload
      final visitorTypeName = rawData!['visitor_type_name']?.toString() ?? 
                             visitorTypeId;
      
      final visitorRole = rawData!['visitor_role'] ?? "Visitor";

      debugPrint(
        'trx_visitor_id: $trxVisitorId | site_place: $rootSiteId | visitor_type: $visitorTypeName',
      );

      // Final defensive check on questionPage: ensure no nulls, but respect field_type rules
      for (var page in questionPage) {
        final form = page['form'] as List?;
        if (form == null) continue;
        for (var field in form) {
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
        "visitor_type": visitorTypeName,
        "type_registered": 0,
        "is_group": rawData!['is_group'] ?? false,
        "tz": rawData!['tz'] ?? "Asia/Jakarta",
        "registered_site": rootSiteId,
        "flow": "Invitation",
        "visitor_role": visitorRole,
        "data_visitor": [
          {
            "question_page": questionPage,
          },
        ],
      };

      debugPrint('=== SUBMIT PRA FORM ===');
      log(jsonEncode(payload));

      // Submit form
      final submitResponse = await apiService.submitPraForm(
        payload,
        visitorTypeId: visitorTypeId,
      );
      log('Submit Response: ${submitResponse.data}');

      if (submitResponse.statusCode != 200 ||
          submitResponse.data['status'] == 'bad_request') {
        final errorMsg =
            submitResponse.data?['msg']?.toString() ?? 'Bad Request';
        final collection = submitResponse.data?['collection'];
        if (collection is List && collection.isNotEmpty) {
          final detail = collection.map((e) => e['message']).join(', ');
          throw Exception('$errorMsg: $detail');
        }
        throw Exception(errorMsg);
      }

      final submitMsg =
          submitResponse.data?['msg']?.toString() ?? 'Form berhasil dikirim';
      final submitTitle = submitResponse.data?['title']?.toString();

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
    super.onClose();
  }
}
