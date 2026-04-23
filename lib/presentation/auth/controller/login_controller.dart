import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/auth_datasource.dart';
import 'user_controller.dart';
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

    final (userModel, message) = await authDatasource.login(email, password);
    isLoading.value = false;

    if (userModel != null) {
      final userCtrl = Get.isRegistered<UserController>() ? Get.find<UserController>() : Get.put(UserController());
      await userCtrl.loadUser();
      Get.snackbar(
        'Berhasil',
        message ?? 'Berhasil masuk',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      Get.offAll(() => const Dashboard());
    } else {
      final errorMessage = message ?? 'Gagal Login';

      if (errorMessage.toLowerCase().contains('username') ||
          errorMessage.toLowerCase().contains('sandi') ||
          errorMessage.toLowerCase().contains('password')) {
        usernameError.value = errorMessage;
        passwordError.value = errorMessage;
      } else {
        Get.snackbar(
          'Gagal Login',
          errorMessage,
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
