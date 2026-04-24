import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../../../core/components/gender_toggle_button.dart';

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



  @override
  void onInit() {
    super.onInit();
    fetchProfile();
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
    emailController.text = data['email']?.toString() ?? '';
    nomorHpController.text = data['phone']?.toString() ?? '';
    alamatController.text = data['address']?.toString() ?? '';
    districtController.text = data['district_name']?.toString() ?? '';
    organisasiController.text = data['organization_name']?.toString() ?? '';
    departemenController.text = data['department_name']?.toString() ?? '';

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
