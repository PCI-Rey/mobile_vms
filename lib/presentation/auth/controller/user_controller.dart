import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/datasources/auth_datasource.dart';
import 'login_controller.dart';
import 'verification_code_controller.dart';
import 'informasi_umum_controller.dart';

class UserController extends GetxController {
  static UserController get to => Get.find();

  final AuthDatasource _authDatasource = AuthDatasource();
  final Rxn<UserModel> user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    final userData = await _authDatasource.getAuthData();
    user.value = userData;
  }

  final isLoggingOut = false.obs;

  Future<void> clearUser() async {
    isLoggingOut.value = true;
    final (success, msg) = await _authDatasource.logout(); // revoke token + clear local session
    user.value = null;
    isLoggingOut.value = false;

    // Clear other controllers to prevent stale data on next login
    Get.delete<LoginController>(force: true);
    Get.delete<VerificationCodeController>(force: true);
    Get.delete<InformasiUmumController>(force: true);

    // Show dynamic message from API response
    Get.snackbar(
      success ? 'Berhasil' : 'Pemberitahuan',
      msg ?? 'Berhasil keluar',
      backgroundColor: success ? Colors.green : Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // Helper method to get fullname or default
  String get fullName => user.value?.fullname ?? 'User';
}
