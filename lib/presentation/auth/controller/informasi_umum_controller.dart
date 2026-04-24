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
    isDriving.value = rawData?['is_driving'] ?? false;
    vehicleType.value = rawData?['vehicle_type']?.toString() ?? 'Car';

    // Recreate PageController so it's never disposed/stale
    try { pageController.dispose(); } catch (_) {}
    pageController = PageController(initialPage: 0);

    // Prefill Step 1
    fullNameController.text = user.fullname ?? '';
    emailController.text = user.email ?? '';

    if (rawData != null) {
      phoneController.text = rawData?['visitor_phone']?.toString() ?? '';
      organizationController.text = rawData?['visitor_organization_name']?.toString() ?? '';
      identityIdController.text = rawData?['visitor_identity_id']?.toString() ?? '';

      // Step 2
      picHostController.text = rawData?['host_name']?.toString() ?? '';
      agendaController.text = rawData?['agenda']?.toString() ?? '';
      destinationController.text = rawData?['site_place_name']?.toString() ?? '';
      visitStartController.text = rawData?['visitor_period_start']?.toString() ?? '';
      visitEndController.text = rawData?['visitor_period_end']?.toString() ?? '';

      // Step 3 (isDriving and vehicleType already set above)
      vehiclePlateController.text = rawData?['vehicle_plate_number']?.toString() ?? '';
    }

    // Eagerly mark empty required fields so red borders show on page open
    _markStep1Errors();
  }

  /// Silently marks fieldErrors for empty required fields in Step 1
  /// (no snackbar — just sets red borders)
  void _markStep1Errors() {
    final errors = <String, String?>{};
    if (fullNameController.text.trim().isEmpty)    errors['fullname']     = 'error_required'.trParams({'field': 'fullname'.tr});
    if (emailController.text.trim().isEmpty)       errors['email']        = 'error_required'.trParams({'field': 'email'.tr});
    if (phoneController.text.trim().isEmpty)       errors['phone']        = 'error_required'.trParams({'field': 'phone'.tr});
    if (organizationController.text.trim().isEmpty) errors['organization'] = 'error_required'.trParams({'field': 'organization'.tr});
    if (identityIdController.text.trim().isEmpty)  errors['identityId']   = 'error_required'.trParams({'field': 'identity_id'.tr});
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
    if (fullNameController.text.trim().isEmpty)    emptyFields.add('fullname'.tr);
    if (emailController.text.trim().isEmpty)       emptyFields.add('email'.tr);
    if (phoneController.text.trim().isEmpty)       emptyFields.add('phone'.tr);
    if (organizationController.text.trim().isEmpty) emptyFields.add('organization'.tr);
    if (identityIdController.text.trim().isEmpty)  emptyFields.add('identity_id'.tr);

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
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  bool validateStep1() {
    final errors = <String, String?>{};
    if (fullNameController.text.trim().isEmpty)    errors['fullname']     = 'Fullname';
    if (emailController.text.trim().isEmpty)       errors['email']        = 'Email';
    if (phoneController.text.trim().isEmpty)       errors['phone']        = 'Phone';
    if (organizationController.text.trim().isEmpty) errors['organization'] = 'Instansi/Organization';
    if (identityIdController.text.trim().isEmpty)  errors['identityId']   = 'Identity Id (KTP)';

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
      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> pickSelfie(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      selfieImage.value = File(picked.path);
    }
  }

  Future<void> pickIdentity(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      identityImage.value = File(picked.path);
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

      // Helper function to update answers
      void updateAnswer(String stepName, String fieldShortName, dynamic value, {bool isFile = false}) {
        for (var page in questionPage) {
          if (page['name'] == stepName) {
            for (var formField in page['form']) {
              if (formField['short_name'] == fieldShortName) {
                if (isFile) {
                  formField['answer_file'] = value;
                } else {
                  formField['answer_text'] = value?.toString();
                }
              }
            }
          }
        }
      }

      // Map Step 1 fields
      updateAnswer('Visitor Information', 'Full Name', fullNameController.text);
      updateAnswer('Visitor Information', 'Email', emailController.text);
      updateAnswer('Visitor Information', 'Phone', phoneController.text);
      updateAnswer('Visitor Information', 'Organization', organizationController.text);
      updateAnswer('Visitor Information', 'Indentity Id', identityIdController.text);

      // Step 2 is read-only, we don't update them, we keep API defaults.

      // Map Step 3 fields
      updateAnswer('Vehicle/Parking Information', 'Is Driving/Riding', isDriving.value.toString());
      updateAnswer('Vehicle/Parking Information', 'Vehicle Type', vehicleType.value);
      updateAnswer('Vehicle/Parking Information', 'Vehicle Plate', vehiclePlateController.text);

      // Map Step 4 & 5 (We send base64 if selected, otherwise null)
      String? selfieBase64;
      if (selfieImage.value != null) {
        final bytes = await selfieImage.value!.readAsBytes();
        selfieBase64 = "data:image/jpeg;base64,${base64Encode(bytes)}";
      }
      updateAnswer('Selfie Image', 'Selfie Image', selfieBase64, isFile: true);

      String? identityBase64;
      if (identityImage.value != null) {
        final bytes = await identityImage.value!.readAsBytes();
        identityBase64 = "data:image/jpeg;base64,${base64Encode(bytes)}";
      }
      updateAnswer('Upload Identity (KTP)', 'Identity Image', identityBase64, isFile: true);

      // Build payload
      // trx_visitor_id = the 'id' field at bottom of collection (NOT transaction_visitor_id)
      final payload = {
        "trx_visitor_id": rawData!['id'],          // collection's own id (bottom field)
        "visitor_type": rawData!['visitor_type'],
        "type_registered": 0,
        "is_group": rawData!['is_group'] ?? false,
        "tz": rawData!['tz'] ?? "Asia/Jakarta",
        "flow": "SubmitPraregister",
        "data_visitor": [
          {
            "question_page": questionPage
          }
        ]
      };

      debugPrint('=== SUBMIT PRA FORM ===');
      debugPrint('trx_visitor_id (id): ${rawData!['id']}');
      debugPrint('visitor_type: ${rawData!['visitor_type']}');
      debugPrint('code: $invitationCode');

      // Submit form (no auth header needed - endpoint is public)
      final submitResponse = await apiService.submitPraForm(payload);
      // Read success msg from API response (e.g. "Submit invitation successfully")
      final submitMsg = submitResponse.data?['msg']?.toString()
          ?? 'Form berhasil dikirim';
      final submitTitle = submitResponse.data?['title']?.toString();

      // After submit success, re-check invitation code to get the token
      final (newUser, isPraregisterDone, _, error, checkTitle) =
          await authDatasource.checkVisitorCode(invitationCode);

      if (newUser != null && isPraregisterDone && newUser.token != null) {
        // checkVisitorCode already saved to Hive, just reload UserController
        final userCtrl = Get.isRegistered<UserController>() ? Get.find<UserController>() : Get.put(UserController());
        await userCtrl.loadUser();
        Get.snackbar(
          (submitTitle ?? checkTitle ?? 'success').capitalizeFirst ?? 'Success',
          submitMsg, // use msg from submit API response
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.offAll(() => const Dashboard());
      } else {
        // Submit sukses tapi token belum tersedia
        throw Exception(error ?? 'Form berhasil dikirim, namun login otomatis gagal. Coba masukkan kode undangan kembali.');
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
    try { pageController.dispose(); } catch (_) {}
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
