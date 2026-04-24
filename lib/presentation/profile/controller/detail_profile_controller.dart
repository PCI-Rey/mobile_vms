import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../../../core/components/gender_toggle_button.dart';
import '../../auth/controller/user_controller.dart';
import '../../../data/models/user_model.dart';

class DetailProfileController extends GetxController {
  final AuthDatasource _authDatasource = AuthDatasource();

  final isLoading = false.obs;
  final isSaving = false.obs;

  // Controllers
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final nomorHpController = TextEditingController();
  final alamatController = TextEditingController();
  final organisasiController = TextEditingController();
  final departemenController = TextEditingController();
  final districtController = TextEditingController();
  final selectedGender = Gender.male.obs;
  final roleLabel = ''.obs;
  final imageUrl = ''.obs;
  final namaHeader = ''.obs;

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
    districtController.text = data['district_name']?.toString() ?? '';
    organisasiController.text = data['organization_name']?.toString() ?? '';
    departemenController.text = data['department_name']?.toString() ?? '';
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
    organisasiController.dispose();
    departemenController.dispose();
    districtController.dispose();
    super.onClose();
  }
}
