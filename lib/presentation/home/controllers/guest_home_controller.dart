import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/hive_service.dart';
import '../../../data/models/access_pass_model.dart';

class GuestHomeController extends GetxController {
  static GuestHomeController get to => Get.find();

  final ApiService _api = ApiService();
  final HiveService _hive = HiveService();

  final RxList<AccessPassModel> accessPasses = <AccessPassModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedPassIndex = 0.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadFromHive();
    fetchAccessPass(isSilent: true);
    _startPolling();
  }

  void selectPass(int index) {
    if (index >= 0 && index < accessPasses.length) {
      selectedPassIndex.value = index;
    }
  }

  void _loadFromHive() {
    final cached = _hive.getAccessPasses();
    if (cached.isNotEmpty) {
      accessPasses.assignAll(cached);
    }
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchAccessPass(isSilent: true);
    });
  }

  Future<void> fetchAccessPass({bool isSilent = false}) async {
    final user = _hive.getUser();
    final token = user?.token;

    if (token == null) {
      if (!isSilent) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan. Silakan login kembali.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }

    if (!isSilent) isLoading.value = true;
    try {
      final response = await _api.getAccessPass(token);
      print("===== GET ACCESS PASS RESPONSE =====");
      print(response.data);
      print("====================================");
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final newPasses = collection
            .map((e) => AccessPassModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Update Hive and UI
        accessPasses.assignAll(newPasses);
        _hive.saveAccessPasses(newPasses);

        if (newPasses.isNotEmpty) {
          // Cari pass pertama yang sudah selesai pra-register
          final int firstValidIndex = newPasses.indexWhere((p) => p.isPraregisterDone);
          
          if (firstValidIndex != -1) {
            // Jika ada yang valid, pastikan selectedPassIndex menunjuk ke sana jika sebelumnya tidak valid
            if (selectedPassIndex.value >= newPasses.length || !newPasses[selectedPassIndex.value].isPraregisterDone) {
              selectedPassIndex.value = firstValidIndex;
            }
          } else {
            // Jika tidak ada yang valid sama sekali
            selectedPassIndex.value = 0;
          }
        } else {
          selectedPassIndex.value = 0;
        }
      } else {
        if (!isSilent) {
          Get.snackbar(
            'Error',
            response.data['msg']?.toString() ?? 'Gagal memuat access pass.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('fetchAccessPass error: $e');
      if (!isSilent) {
        Get.snackbar(
          'Error',
          'Terjadi kesalahan saat memuat data.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
