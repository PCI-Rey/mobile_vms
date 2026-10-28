import 'dart:math';
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

  // Captcha state (Backend API integration with fallback)
  final captchaError = Rxn<String>();
  final captchaId = ''.obs;
  final captchaSvg = ''.obs;
  final captchaCode = ''.obs;
  final isRefreshingCaptcha = false.obs;

  // Text Controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCaptcha();

    // Listen to text changes to clear errors
    usernameController.addListener(() {
      if (usernameError.value != null) usernameError.value = null;
    });
    passwordController.addListener(() {
      if (passwordError.value != null) passwordError.value = null;
    });
    captchaController.addListener(() {
      if (captchaError.value != null) captchaError.value = null;
    });
  }

  Future<void> fetchCaptcha() async {
    isRefreshingCaptcha.value = true;
    captchaController.clear();
    captchaError.value = null;

    try {
      final res = await authDatasource.getCaptcha();
      if (res != null && res.captchaId.isNotEmpty) {
        captchaId.value = res.captchaId;
        captchaSvg.value = res.svgBackground;
        captchaCode.value = res.captchaCode;
        debugPrint(
          '🔥 [CMS CAPTCHA LIVE] ID: ${res.captchaId} | CODE: ${res.captchaCode}',
        );
      } else {
        debugPrint(
          '⚠️ [CMS CAPTCHA] Backend response empty, using local fallback',
        );
        generateDummyCaptcha();
      }
    } catch (e) {
      debugPrint('⚠️ [CMS CAPTCHA ERROR] $e, using local fallback');
      generateDummyCaptcha();
    } finally {
      isRefreshingCaptcha.value = false;
    }
  }

  void generateDummyCaptcha() {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final random = Random();
    final newCode =
        List.generate(5, (_) => chars[random.nextInt(chars.length)]).join();
    captchaCode.value = newCode;
    captchaSvg.value = '';
    captchaId.value = '';
  }

  Future<void> refreshCaptcha() async {
    await fetchCaptcha();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = usernameController.text.trim();
    final password = passwordController.text;
    final captcha = captchaController.text.trim();

    // Client-side validations
    if (email.isEmpty) {
      usernameError.value = 'login_username_hint'.tr;
      return;
    }
    if (password.isEmpty) {
      passwordError.value = 'login_password_hint'.tr;
      return;
    }
    if (captcha.isEmpty) {
      captchaError.value = 'captcha_required'.tr;
      return;
    }

    // Local fallback check if dummy was generated
    if (captchaSvg.value.isEmpty && captchaCode.value.isNotEmpty) {
      if (captcha.toUpperCase() != captchaCode.value.toUpperCase()) {
        captchaError.value = 'captcha_invalid'.tr;
        refreshCaptcha();
        return;
      }
    }

    isLoading.value = true;
    final stopwatch = Stopwatch()..start();

    final (userModel, title, message) = await authDatasource.login(
      email,
      password,
      captchaId: captchaId.value.isNotEmpty ? captchaId.value : null,
      captchaAnswer: captcha,
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

      if (errorMessage.toLowerCase().contains('captcha')) {
        captchaError.value = errorMessage;
      } else if (errorMessage.toLowerCase().contains('username') ||
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

      // Refresh captcha automatically on failed attempt
      fetchCaptcha();
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.onClose();
  }
}
