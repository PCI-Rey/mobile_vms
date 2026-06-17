import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../../../core/components/gender_toggle_button.dart';
import '../../auth/controller/user_controller.dart';

class DetailProfileController extends GetxController {
  final AuthDatasource _authDatasource = AuthDatasource();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isEditing = false.obs;

  // Controllers
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final nomorHpController = TextEditingController();
  final alamatController = TextEditingController();

  final selectedGender = Gender.male.obs;
  final roleLabel = ''.obs;
  final imageUrl = ''.obs;
  final namaHeader = ''.obs;

  // For backing up values when editing starts
  String _backupNama = '';
  String _backupEmail = '';
  String _backupNomorHp = '';
  String _backupAlamat = '';
  Gender _backupGender = Gender.male;

  void startEditing() {
    _backupNama = namaController.text;
    _backupEmail = emailController.text;
    _backupNomorHp = nomorHpController.text;
    _backupAlamat = alamatController.text;
    _backupGender = selectedGender.value;
    isEditing.value = true;
  }

  void cancelEditing() {
    namaController.text = _backupNama;
    emailController.text = _backupEmail;
    nomorHpController.text = _backupNomorHp;
    alamatController.text = _backupAlamat;
    selectedGender.value = _backupGender;
    isEditing.value = false;
  }

  Future<void> saveProfile() async {
    if (namaController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email cannot be empty', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSaving.value = true;
    final genderStr = selectedGender.value == Gender.female ? 'Female' : 'Male';
    final payload = {
      'fullname': namaController.text.trim(),
      'email': emailController.text.trim(),
      'phone': nomorHpController.text.trim(),
      'address': alamatController.text.trim(),
      'gender': genderStr,
      'group_name': roleLabel.value,
    };

    final (success, title, msg) = await _authDatasource.updateProfile(payload);
    isSaving.value = false;

    if (success) {
      Get.snackbar(
        (title ?? 'Success').capitalizeFirst ?? 'Success',
        msg ?? 'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      isEditing.value = false;
      await UserController.to.loadUser();
      namaHeader.value = namaController.text;
    } else {
      Get.snackbar(
        (title ?? 'Error').capitalizeFirst ?? 'Error',
        msg ?? 'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showEditInfo() {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Info',
      'Please tap the pencil icon at the top to start editing your profile.',
      backgroundColor: const Color(0xFF1976D2),
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    fetchProfile();
  }

  void _loadInitialData() {
    final user = UserController.to.user.value;
    if (user != null) {
      namaController.text = user.fullname ?? '';
      namaHeader.value = user.fullname ?? '';
      emailController.text = user.email ?? '';
      nomorHpController.text = user.phone ?? '';
      roleLabel.value = user.roleAccess ?? '';

      // Load other fields from extraData if available
      try {
        if (user.extraData != null) {
          final Map<String, dynamic> data = jsonDecode(user.extraData!);
          _mapCollectionToControllers(data);
        }
      } catch (e) {
        debugPrint('Error loading initial data: $e');
      }
    }
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    final (collection, error) = await _authDatasource.getProfile();
    isLoading.value = false;

    if (collection != null) {
      _mapCollectionToControllers(collection);
    }
    // Error is handled silently or via debug as per request to remove snackbars
  }

  void _mapCollectionToControllers(Map<String, dynamic> data) {
    namaController.text = data['fullname']?.toString() ?? '';
    namaHeader.value = data['fullname']?.toString() ?? '';
    emailController.text = data['email']?.toString() ?? '';
    nomorHpController.text = data['phone']?.toString() ?? '';
    alamatController.text = data['address']?.toString() ?? '';

    roleLabel.value = (data['group_name'] ?? '').toString();
    imageUrl.value =
        data['image']?.toString() ?? ''; // Asumsi field 'image' atau 'photo'

    final genderStr = data['Gender']?.toString().toLowerCase() ?? '';
    if (genderStr == 'female' || genderStr == 'perempuan') {
      selectedGender.value = Gender.female;
    } else {
      selectedGender.value = Gender.male;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    nomorHpController.dispose();
    alamatController.dispose();

    super.onClose();
  }
}
