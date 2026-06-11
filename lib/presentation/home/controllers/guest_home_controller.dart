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
  final RxList<AccessPassModel> activeVisits = <AccessPassModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedPassIndex = 0.obs;
  final RxInt selectedVisitIndex = 0.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadFromHive();
    fetchAccessPass(isSilent: true);
    fetchActiveVisits(isSilent: true);
    _startPolling();
  }

  void selectPass(int index) {
    if (index >= 0 && index < accessPasses.length) {
      selectedPassIndex.value = index;
    }
  }

  void selectVisit(int index) {
    if (index >= 0 && index < activeVisits.length) {
      selectedVisitIndex.value = index;
      
      // Sync selected access pass if matching invitationCode is found
      final matchCode = activeVisits[index].invitationCode;
      final passIdx = accessPasses.indexWhere((p) => p.invitationCode == matchCode);
      if (passIdx != -1) {
        selectedPassIndex.value = passIdx;
      }
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
      fetchActiveVisits(isSilent: true);
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
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final now = DateTime.now();
        final newPasses = collection
            .map((e) => AccessPassModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final filteredPasses = newPasses.where((item) {
          final isExpired = item.visitorPeriodEnd.isBefore(now);
          final isInactiveStatus =
              item.visitorStatus.toLowerCase() == 'expired' ||
              item.visitorStatus.toLowerCase() == 'completed' ||
              item.visitorStatus.toLowerCase() == 'cancelled' ||
              item.visitorStatus.toLowerCase() == 'rejected';
          return !isExpired && !isInactiveStatus;
        }).toList();

        // Update Hive and UI
        accessPasses.assignAll(filteredPasses);
        _hive.saveAccessPasses(filteredPasses);

        if (filteredPasses.isNotEmpty) {
          // Cari pass pertama yang sudah selesai pra-register
          final int firstValidIndex =
              filteredPasses.indexWhere((p) => p.isPraregisterDone);

          if (firstValidIndex != -1) {
            // Jika ada yang valid, pastikan selectedPassIndex menunjuk ke sana jika sebelumnya tidak valid
            if (selectedPassIndex.value >= filteredPasses.length ||
                !filteredPasses[selectedPassIndex.value].isPraregisterDone) {
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

  Future<void> fetchActiveVisits({bool isSilent = false}) async {
    final user = _hive.getUser();
    final token = user?.token;

    if (token == null) return;

    try {
      final response = await _api.getActiveVisits(token);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final now = DateTime.now();
        final newPasses = collection
            .map((e) => AccessPassModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final filteredPasses = newPasses.where((item) {
          final isExpired = item.visitorPeriodEnd.isBefore(now);
          final isInactiveStatus =
              item.visitorStatus.toLowerCase() == 'expired' ||
              item.visitorStatus.toLowerCase() == 'completed' ||
              item.visitorStatus.toLowerCase() == 'cancelled' ||
              item.visitorStatus.toLowerCase() == 'rejected';
          return !isExpired && !isInactiveStatus;
        }).toList();

        activeVisits.assignAll(filteredPasses);

        if (filteredPasses.isNotEmpty) {
          if (selectedVisitIndex.value >= filteredPasses.length) {
            selectedVisitIndex.value = 0;
          }
        } else {
          selectedVisitIndex.value = 0;
        }
      }
    } catch (e) {
      debugPrint('fetchActiveVisits error: $e');
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
