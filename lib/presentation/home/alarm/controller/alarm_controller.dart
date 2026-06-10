import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/alarm_datasource.dart';
import '../../../../data/models/alarm_model.dart';

class AlarmController extends GetxController {
  final isLoading = false.obs;
  final alarms = <AlarmModel>[].obs;
  final filteredAlarms = <AlarmModel>[].obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAlarms();
    });
  }

  Future<void> loadAlarms() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await dummyGetAllAlarms();
      alarms.assignAll(result);
      filteredAlarms.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAlarmsWithFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? gedung,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await dummyGetAlarmsWithFilter(
        startDate: startDate,
        endDate: endDate,
        gedung: gedung,
      );
      filteredAlarms.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveAlarm(String id) async {
    try {
      await dummyApproveAlarm(id);
      await loadAlarms();
      Get.snackbar('Success', 'Alarm approved');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> denyAlarm(String id) async {
    try {
      await dummyDenyAlarm(id);
      await loadAlarms();
      Get.snackbar('Success', 'Alarm denied');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> trackVisitor(String id) async {
    try {
      await dummyTrackVisitor(id);
      Get.snackbar('Success', 'Tracking visitor enabled');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
