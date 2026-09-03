import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../../../core/services/notification_service.dart';
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
    final stopwatch = Stopwatch()..start();

    final (userModel, title, message) = await authDatasource.login(
      email,
      password,
    );
    stopwatch.stop();
    debugPrint(
      '[Auth] Login API round-trip took: ${stopwatch.elapsedMilliseconds} ms',
    );

    isLoading.value = false;

    if (userModel != null) {
      final userCtrl = Get.isRegistered<UserController>()
          ? Get.find<UserController>()
          : Get.put(UserController());
      userCtrl.user.value = userModel;
      Get.snackbar(
        (title ?? 'success').capitalizeFirst ?? 'Success',
        message ?? 'Berhasil masuk',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      Get.offAll(() => const Dashboard());

      // Subscribe to user-specific FCM topic (non-fatal)
      if (userModel.id.isNotEmpty) {
        NotificationService.instance.subscribeToUserTopic(userModel.id);
      }
    } else {
      final errorMessage = message ?? 'Gagal Login';
      final errorTitle = (title ?? 'Error').capitalizeFirst ?? 'Error';

      if (errorMessage.toLowerCase().contains('username') ||
          errorMessage.toLowerCase().contains('user') ||
          errorMessage.toLowerCase().contains('not found') ||
          errorMessage.toLowerCase().contains('sandi') ||
          errorMessage.toLowerCase().contains('password')) {
        usernameError.value = errorMessage;
        passwordError.value = errorMessage;
      }

      // Always show snackbar for all login errors for consistency
      Get.snackbar(
        errorTitle,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
