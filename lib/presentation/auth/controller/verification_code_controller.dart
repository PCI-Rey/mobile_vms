import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/auth_datasource.dart';
import '../controller/informasi_umum_controller.dart';
import '../informasi_umum_page.dart';
import '../../dashboard.dart';
import 'user_controller.dart';
import '../../home/controllers/guest_home_controller.dart';

class VerificationCodeController extends GetxController {
  final AuthDatasource authDatasource = AuthDatasource();

  // Reactive state
  final isLoading = false.obs;
  final codeError = Rxn<String>();

  // Text Controllers
  final invitationCodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Listen to text changes to clear errors
    invitationCodeController.addListener(() {
      if (codeError.value != null) codeError.value = null;
    });
  }

  Future<void> verifyCode() async {
    final code = invitationCodeController.text.trim();
    if (code.isEmpty) {
      codeError.value = 'Kode undangan tidak boleh kosong';
      return;
    }

    isLoading.value = true;
    final (userModel, isPraregisterDone, rawData, message, title) = await authDatasource.checkVisitorCode(code);
    isLoading.value = false;

    if (userModel != null) {
      if (isPraregisterDone) {
        // Automatically login the user
        await authDatasource.saveAuthData(userModel);
        final userCtrl = Get.isRegistered<UserController>() ? Get.find<UserController>() : Get.put(UserController());
        await userCtrl.loadUser();
        Get.snackbar(
          (title ?? 'success').capitalizeFirst ?? 'Success',
          message ?? 'Berhasil masuk',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        
        // Ensure guest home data is fresh
        Get.delete<GuestHomeController>(force: true);
        
        Get.offAll(() => const Dashboard());
      } else {
        // Always create a fresh controller (delete old one first if exists)
        Get.delete<InformasiUmumController>(force: true);
        Get.put(InformasiUmumController()).initializeData(userModel, code, rawData);
        Get.to(() => InformasiUmumPage(userModel: userModel, invitationCode: code, rawData: rawData));
      }
    } else {
      codeError.value = message ?? 'Kode undangan tidak valid';
      Get.snackbar(
        'Gagal Verifikasi',
        codeError.value!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    invitationCodeController.dispose();
    super.onClose();
  }
}
