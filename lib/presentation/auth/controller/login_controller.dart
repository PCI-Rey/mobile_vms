import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../../dashboard.dart';

class LoginController extends GetxController {
  final AuthDatasource authDatasource = AuthDatasource();

  // Reactive state
  final isLoading = false.obs;
  final usernameError = Rxn<String>();
  final passwordError = Rxn<String>();
  final obscurePassword = true.obs;

  // Text Controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Listen to text changes to clear errors
    usernameController.addListener(() {
      if (usernameError.value != null) usernameError.value = null;
    });
    passwordController.addListener(() {
      if (passwordError.value != null) passwordError.value = null;
    });
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = usernameController.text;
    final password = passwordController.text;

    isLoading.value = true;

    try {
      final userModel = await authDatasource.login(email, password);
      isLoading.value = false;

      await authDatasource.saveAuthData(userModel);
      Get.offAll(() => const Dashboard());
    } catch (e) {
      isLoading.value = false;
      final error = e.toString().replaceAll('Exception: ', '');

      if (error.toLowerCase().contains('username') ||
          error.toLowerCase().contains('sandi')) {
        usernameError.value = error;
        passwordError.value = error;
      } else {
        Get.snackbar(
          'Gagal Login',
          error,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
