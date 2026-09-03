import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/models/user_model.dart';
import '../../dashboard.dart';
import '../waiting_approval_page.dart';
import 'user_controller.dart';
import '../../home/controllers/guest_home_controller.dart';
import '../../../core/services/notification_service.dart';

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

  // Step 0: Who Fill This Form
  final isSelfRegistered = Rxn<bool>();
  final filledByNameController = TextEditingController();
  final filledByEmailController = TextEditingController();
  final filledByPhoneController = TextEditingController();
  final filledByRelationship = Rxn<String>();
  final filledByRelationshipOtherController = TextEditingController();
  final relationshipOptions = [
    'Secretary',
    'Assistant',
    'VendorPIC',
    'EventOrganizer',
    'Family',
    'Colleague',
    'Admin',
    'HR',
    'Receptionist',
    'Host',
    'Invented',
    'Other',
  ];

  // Step 1: Visitor Information
  final selectedVisitorRole = 'Visitor'.obs;
  final visitorRolesList = <String>[].obs;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final organizationController = TextEditingController();
  final identityIdController = TextEditingController();

  // Step 2: Purpose Visit
  final picHostController = TextEditingController();
  final agendaController = TextEditingController();
  final destinationController = TextEditingController();
  final visitStartController = TextEditingController();
  final visitEndController = TextEditingController();
  final Rx<DateTime?> visitStartDateTime = Rx<DateTime?>(null);
  final Rx<DateTime?> visitEndDateTime = Rx<DateTime?>(null);

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

  final isCurrentStepValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    fullNameController.addListener(updateStepValidity);
    emailController.addListener(updateStepValidity);
    phoneController.addListener(updateStepValidity);
    organizationController.addListener(updateStepValidity);
    identityIdController.addListener(updateStepValidity);
    vehiclePlateController.addListener(updateStepValidity);
    filledByNameController.addListener(updateStepValidity);
    filledByEmailController.addListener(updateStepValidity);
    filledByPhoneController.addListener(updateStepValidity);
    filledByRelationshipOtherController.addListener(updateStepValidity);

    ever(currentPage, (_) => updateStepValidity());
    ever(isSelfRegistered, (_) => updateStepValidity());
    ever(isDriving, (_) => updateStepValidity());
    ever(filledByRelationship, (_) => updateStepValidity());

    updateStepValidity();
  }

  void updateStepValidity() {
    isCurrentStepValid.value = _checkStepValidity();
  }

  bool _checkStepValidity() {
    if (currentPage.value == 0) {
      return isSelfRegistered.value != null;
    }
    if (isSelfRegistered.value == true) {
      if (currentPage.value == 1) {
        return fullNameController.text.trim().isNotEmpty &&
            emailController.text.trim().isNotEmpty &&
            phoneController.text.trim().isNotEmpty &&
            organizationController.text.trim().isNotEmpty &&
            identityIdController.text.trim().isNotEmpty;
      }
      if (currentPage.value == 3) {
        if (isDriving.value) {
          return vehiclePlateController.text.trim().isNotEmpty;
        }
        return true;
      }
    } else if (isSelfRegistered.value == false) {
      if (currentPage.value == 1) {
        final isOtherValid =
            filledByNameController.text.trim().isNotEmpty &&
            filledByEmailController.text.trim().isNotEmpty &&
            filledByPhoneController.text.trim().isNotEmpty;
        if (!isOtherValid) return false;
        if (filledByRelationship.value == null) return false;
        if (filledByRelationship.value == 'Other') {
          return filledByRelationshipOtherController.text.trim().isNotEmpty;
        }
        return true;
      }
      if (currentPage.value == 2) {
        return fullNameController.text.trim().isNotEmpty &&
            emailController.text.trim().isNotEmpty &&
            phoneController.text.trim().isNotEmpty &&
            organizationController.text.trim().isNotEmpty &&
            identityIdController.text.trim().isNotEmpty;
      }
      if (currentPage.value == 4) {
        if (isDriving.value) {
          return vehiclePlateController.text.trim().isNotEmpty;
        }
        return true;
      }
    }
    return true;
  }

  void initializeData(UserModel user, String code, Map<String, dynamic>? data) {
    userModel = user;
    invitationCode = code;
    rawData = data;

    // Reset navigation state — ensures fresh start every time page is opened
    currentPage.value = 0;
    isSelfRegistered.value = null;
    filledByNameController.clear();
    filledByEmailController.clear();
    filledByPhoneController.clear();
    filledByRelationship.value = null;
    filledByRelationshipOtherController.clear();
    fieldErrors.clear();
    selfieImage.value = null;
    identityImage.value = null;
    selfieUrl.value = null;
    identityUrl.value = null;
    isUploadingSelfie.value = false;
    isUploadingIdentity.value = false;
    final collection =
        rawData?['collection'] as Map<String, dynamic>? ?? rawData;

    // Prefill selectedVisitorRole and visitorRolesList
    selectedVisitorRole.value =
        collection?['visitor_role']?.toString() ?? 'Visitor';

    final typeData = collection?['visitor_type_data'] as Map<String, dynamic>?;
    final rolesRaw = typeData?['visitor_roles'];
    final List<String> extractedRoles = [];
    if (rolesRaw is List) {
      for (var r in rolesRaw) {
        if (r is Map && r['role'] != null) {
          extractedRoles.add(r['role'].toString());
        }
      }
    }
    // Fallback if empty
    if (extractedRoles.isEmpty) {
      extractedRoles.addAll(['Visitor', 'Driver']);
    }
    visitorRolesList.assignAll(extractedRoles);

    // If current selected role is not in the list, set it to the default active role or first role
    if (!visitorRolesList.contains(selectedVisitorRole.value)) {
      if (visitorRolesList.isNotEmpty) {
        selectedVisitorRole.value = visitorRolesList.first;
      }
    }

    isDriving.value = collection?['is_driving'] ?? false;
    final rawType = collection?['vehicle_type']?.toString() ?? 'Car';
    if (rawType == 'vehicle_other' || rawType == 'Other') {
      vehicleType.value = 'Car';
    } else {
      vehicleType.value = rawType;
    }

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
      final rawStart = collection['visitor_period_start']?.toString();
      final rawEnd = collection['visitor_period_end']?.toString();
      if (rawStart != null && rawStart.isNotEmpty) {
        try {
          String s = rawStart;
          if (!s.endsWith('Z') && !s.contains('+')) s = '${s}Z';
          visitStartDateTime.value = DateTime.parse(s).toLocal();
        } catch (_) {
          try {
            visitStartDateTime.value = DateTime.parse(rawStart);
          } catch (_) {}
        }
      }
      if (rawEnd != null && rawEnd.isNotEmpty) {
        try {
          String s = rawEnd;
          if (!s.endsWith('Z') && !s.contains('+')) s = '${s}Z';
          visitEndDateTime.value = DateTime.parse(s).toLocal();
        } catch (_) {
          try {
            visitEndDateTime.value = DateTime.parse(rawEnd);
          } catch (_) {}
        }
      }
      visitStartController.text = _formatUtcToLocal(rawStart);
      visitEndController.text = _formatUtcToLocal(rawEnd);

      // Step 3 (isDriving and vehicleType already set above)
      vehiclePlateController.text =
          collection['vehicle_plate_number']?.toString() ?? '';
    }

    // Eagerly mark empty required fields so red borders show on page open
    _markStep1Errors();
    updateStepValidity();
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
      return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'en').format(utcDt);
    } catch (_) {
      return utcString; // fallback: tampilkan raw jika parse gagal
    }
  }

  Future<void> pickDateTime(BuildContext context, {required bool isStart}) async {
    final initialDt = (isStart
            ? visitStartDateTime.value
            : visitEndDateTime.value) ??
        DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDt),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null) return;

    final finalDt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (isStart) {
      visitStartDateTime.value = finalDt;
      visitStartController.text =
          DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'en').format(finalDt);
      // If visit end is before visit start, adjust end to start + 3 hours
      if (visitEndDateTime.value != null &&
          visitEndDateTime.value!.isBefore(finalDt)) {
        final newEnd = finalDt.add(const Duration(hours: 3));
        visitEndDateTime.value = newEnd;
        visitEndController.text =
            DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'en').format(newEnd);
      }
    } else {
      if (visitStartDateTime.value != null &&
          finalDt.isBefore(visitStartDateTime.value!)) {
        Get.snackbar(
          'Waktu Tidak Valid',
          'Visit End tidak boleh lebih awal dari Visit Start',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      visitEndDateTime.value = finalDt;
      visitEndController.text =
          DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'en').format(finalDt);
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
    if (isSelfRegistered.value == true) {
      if (currentPage.value == 1 && !validateStep1()) return;
      if (currentPage.value == 3 && !validateStep3()) return;

      if (currentPage.value < 5) {
        final targetPage = currentPage.value + 1;
        currentPage.value = targetPage;
        pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (isSelfRegistered.value == false) {
      if (currentPage.value == 1 && !validateStepOther()) return;
      if (currentPage.value == 2 && !validateStep1()) return;
      if (currentPage.value == 4 && !validateStep3()) return;

      if (currentPage.value < 6) {
        final targetPage = currentPage.value + 1;
        currentPage.value = targetPage;
        pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool validateStepOther() {
    final errors = <String, String?>{};
    if (filledByNameController.text.trim().isEmpty) {
      errors['filledByName'] = 'fullname'.tr;
    }
    if (filledByEmailController.text.trim().isEmpty) {
      errors['filledByEmail'] = 'email'.tr;
    }
    if (filledByPhoneController.text.trim().isEmpty) {
      errors['filledByPhone'] = 'phone'.tr;
    }
    if (filledByRelationship.value == 'Other' &&
        filledByRelationshipOtherController.text.trim().isEmpty) {
      errors['filledByRelationshipOther'] = 'relationship'.tr;
    }

    // Set red borders on all empty fields
    fieldErrors.assignAll(
      errors.map(
        (k, v) => MapEntry(k, 'error_required'.trParams({'field': v ?? ''})),
      ),
    );

    if (errors.isNotEmpty) {
      return false;
    }
    return true;
  }

  bool validateStep1() {
    final errors = <String, String?>{};
    if (fullNameController.text.trim().isEmpty) {
      errors['fullname'] = 'fullname'.tr;
    }
    if (emailController.text.trim().isEmpty) {
      errors['email'] = 'email'.tr;
    }
    if (phoneController.text.trim().isEmpty) {
      errors['phone'] = 'phone'.tr;
    }
    if (organizationController.text.trim().isEmpty) {
      errors['organization'] = 'organization'.tr;
    }
    if (identityIdController.text.trim().isEmpty) {
      errors['identityId'] = 'identity_id'.tr;
    }

    // Set red borders on all empty fields
    fieldErrors.assignAll(
      errors.map(
        (k, v) => MapEntry(k, 'error_required'.trParams({'field': v ?? ''})),
      ),
    );

    if (errors.isNotEmpty) {
      return false;
    }
    return true;
  }

  bool validateStep3() {
    final errors = <String, String?>{};
    if (isDriving.value && vehiclePlateController.text.trim().isEmpty) {
      errors['vehiclePlate'] = 'error_required'.trParams({
        'field': 'vehicle_plate'.tr,
      });
    }

    fieldErrors.assignAll(errors);

    if (errors.isNotEmpty) {
      return false;
    }
    return true;
  }

  void previousPage() {
    if (currentPage.value > 0) {
      final targetPage = currentPage.value - 1;
      currentPage.value = targetPage;
      pageController.animateToPage(
        targetPage,
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

      // enumVehicleType: 3 valid enum values backend database accepts at data_visitor[0].vehicle_type.
      // 'Other' maps to 'Car' since backend has no 'Other' enum.
      final String enumVehicleType;
      if (vehicleType.value == 'vehicle_bus') {
        enumVehicleType = 'Bus';
      } else if (vehicleType.value == 'vehicle_motor') {
        enumVehicleType = 'Motor';
      } else {
        // vehicle_car, vehicle_other, or any unknown → Car
        enumVehicleType = 'Car';
      }

      // Helper to generate dynamic UUID v4
      String generateUuid() {
        final random = Random();
        const hexDigits = '0123456789abcdef';
        String randomHex(int length) {
          return List.generate(
            length,
            (_) => hexDigits[random.nextInt(16)],
          ).join();
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
                    field['answer_text'] = isDriving.value
                        ? formattedVehicleType
                        : '';
                  } else if (field['remarks'] == 'vehicle_plate') {
                    field['answer_text'] = isDriving.value
                        ? vehiclePlateController.text
                        : '';
                  }
                }
              }
            } else {
              // Page exists but form is empty — inject our fields into it
              debugPrint(
                'Vehicle page found with empty form, filling in fields...',
              );
              page['form'] = vehicleFormFields;
            }
            vehiclePageFilled = true;
            break;
          }
        }
      }

      if (!vehiclePageFilled) {
        // No vehicle page found at all — add a new one
        debugPrint(
          'No vehicle page found in questionPage, injecting new Vehicle/Parking Information page...',
        );
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
      updateAnswer('visitor_role', selectedVisitorRole.value);
      updateAnswer('Full Name', fullNameController.text);
      updateAnswer('Email', emailController.text);
      updateAnswer('Phone', phoneController.text);
      updateAnswer('Organization', organizationController.text);
      updateAnswer('Indentity Id', identityIdController.text);

      // ── Step 2 (Purpose of Visit) ──────────────────────────────────
      updateAnswer('Agenda', collection['agenda']);

      final String startIso = visitStartDateTime.value != null
          ? visitStartDateTime.value!.toUtc().toIso8601String().substring(0, 19)
          : (collection['visitor_period_start']?.toString() ?? '');
      final String endIso = visitEndDateTime.value != null
          ? visitEndDateTime.value!.toUtc().toIso8601String().substring(0, 19)
          : (collection['visitor_period_end']?.toString() ?? '');

      debugPrint('Visit Start (Local): ${visitStartDateTime.value} -> (GMT/UTC): $startIso');
      debugPrint('Visit End (Local): ${visitEndDateTime.value} -> (GMT/UTC): $endIso');

      collection['visitor_period_start'] = startIso;
      collection['visitor_period_end'] = endIso;

      updateAnswer('Visit Start', startIso);
      updateAnswer('Visit End', endIso);

      // ── Step 3: Vehicle fields ───────────────────────────────────────
      updateAnswer('Is Driving/Riding', isDriving.value.toString());
      updateAnswer('Vehicle Type', isDriving.value ? formattedVehicleType : "");
      updateAnswer(
        'Vehicle Plate',
        isDriving.value ? vehiclePlateController.text : "",
      );

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
      updateAnswerByRemarks('visitor_period_start', startIso);
      updateAnswerByRemarks('visitor_period_end', endIso);

      // ── Build payload ─────────────────────────────────────────────────
      // Always use 'id' field for trx_visitor_id
      final trxVisitorId = collection['id']?.toString();
      final visitorTypeId = collection['visitor_type']?.toString();
      final visitorRole = selectedVisitorRole.value;
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
        "is_self_registered": isSelfRegistered.value ?? true,
        "filled_by_name": isSelfRegistered.value == true
            ? null
            : filledByNameController.text.trim(),
        "filled_by_email": isSelfRegistered.value == true
            ? null
            : filledByEmailController.text.trim(),
        "filled_by_phone": isSelfRegistered.value == true
            ? null
            : filledByPhoneController.text.trim(),
        "trx_visitor_id": trxVisitorId,
        "visitor_id": visitorId,
        "application_id": applicationId,
        "visitor_type": visitorTypeId,
        "type_registered": 0,
        "is_group": collection['is_group'] ?? false,
        "tz": collection['tz'] ?? "Asia/Jakarta",
        "registered_site": rootSiteId,
        "visitor_period_start": startIso,
        "visitor_period_end": endIso,
        "flow": "SubmitPraregister",
        "visitor_role": visitorRole,
        "is_driving": isDriving.value,
        // Use enumVehicleType (Car/Bus/Motor) at root level — backend validates against its enum
        "vehicle_type": isDriving.value ? enumVehicleType : null,
        "vehicle_plate_number": isDriving.value
            ? vehiclePlateController.text
            : null,
        "vehicle_plate": isDriving.value ? vehiclePlateController.text : null,
        "data_visitor": [
          {
            "visitor_period_start": startIso,
            "visitor_period_end": endIso,
            // vehicle_type at data_visitor level also uses enum-safe value
            "vehicle_type": isDriving.value ? enumVehicleType : null,
            "vehicle_plate": isDriving.value
                ? vehiclePlateController.text
                : null,
            "question_page": questionPage,
          },
        ],
      };

      debugPrint('=== SUBMIT PRA FORM ===');
      final payloadJson = jsonEncode(payload);
      // Chunk the payload since debugPrint has a character limit
      const chunkSize = 800;
      for (int i = 0; i < payloadJson.length; i += chunkSize) {
        debugPrint(
          payloadJson.substring(
            i,
            i + chunkSize > payloadJson.length
                ? payloadJson.length
                : i + chunkSize,
          ),
        );
      }

      // Submit form — retry sampai 2x karena backend kadang butuh percobaan kedua
      dio.Response? submitResponse;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          submitResponse = await apiService.submitPraForm(
            payload,
            visitorTypeId: visitorTypeId,
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
      final submitTitle = responseData is Map
          ? responseData['title']?.toString()
          : null;

      // After submit success, re-check invitation code to get the token
      final (newUser, isPraregisterDone, checkRawData, error, checkTitle) =
          await authDatasource.checkVisitorCode(invitationCode);

      if (newUser != null && isPraregisterDone && newUser.token != null) {
        // Fallback to locally uploaded selfie if the API check didn't return a faceUrl immediately
        final String? finalFaceUrl = (newUser.faceUrl != null && newUser.faceUrl!.isNotEmpty)
            ? newUser.faceUrl
            : selfieUrl.value;

        if (finalFaceUrl != null && finalFaceUrl.isNotEmpty) {
          final updatedUser = UserModel(
            id: newUser.id,
            fullname: newUser.fullname,
            username: newUser.username,
            email: newUser.email,
            roleAccess: newUser.roleAccess,
            token: newUser.token,
            applicationId: newUser.applicationId,
            description: newUser.description,
            phone: newUser.phone,
            visitorCode: newUser.visitorCode,
            invitationCode: newUser.invitationCode,
            hostName: newUser.hostName,
            sitePlaceName: newUser.sitePlaceName,
            visitorStatus: newUser.visitorStatus,
            faceUrl: finalFaceUrl,
            extraData: newUser.extraData,
          );
          await authDatasource.saveAuthData(updatedUser);
        }

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

        // Subscribe to user-specific FCM topic (non-fatal)
        if (newUser.id.isNotEmpty) {
          NotificationService.instance.subscribeToUserTopic(newUser.id);
        }
      } else if (checkRawData != null && checkRawData['status'] == 'process') {
        Get.offAll(
          () => WaitingApprovalPage(
            invitationCode: invitationCode,
            message: submitMsg,
          ),
        );
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
    filledByNameController.dispose();
    filledByEmailController.dispose();
    filledByPhoneController.dispose();
    filledByRelationshipOtherController.dispose();
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
