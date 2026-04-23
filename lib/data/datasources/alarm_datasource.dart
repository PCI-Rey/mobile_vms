import 'package:flutter/foundation.dart';
import '../../core/core.dart';
import '../models/alarm_model.dart';

/// Simulasi fetch semua alarms
Future<List<AlarmModel>> dummyGetAllAlarms() async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return dummyAlarms;
}

/// Simulasi fetch alarm by ID
Future<AlarmModel?> dummyGetAlarmById(String id) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  try {
    return dummyAlarms.firstWhere((alarm) => alarm.id == id);
  } catch (e) {
    return null;
  }
}

/// Simulasi fetch alarms dengan filter
Future<List<AlarmModel>> dummyGetAlarmsWithFilter({
  DateTime? startDate,
  DateTime? endDate,
  String? gedung,
}) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  List<AlarmModel> filteredAlarms = List.from(dummyAlarms);
  
  // Filter by date range
  if (startDate != null && endDate != null) {
    filteredAlarms = filteredAlarms.where((alarm) {
      return alarm.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
             alarm.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Filter by gedung/location
  if (gedung != null && gedung.isNotEmpty && gedung.toLowerCase() != 'all') {
    filteredAlarms = filteredAlarms.where((alarm) {
      return alarm.location.toLowerCase().contains(gedung.toLowerCase());
    }).toList();
  }
  
  debugPrint('Filter applied - Start: $startDate, End: $endDate, Gedung: $gedung');
  debugPrint('Found ${filteredAlarms.length} alarms after filtering');
  
  return filteredAlarms;
}

/// Simulasi approve alarm
Future<bool> dummyApproveAlarm(String alarmId) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  // Cari alarm yang akan di-approve
  final alarmIndex = dummyAlarms.indexWhere((alarm) => alarm.id == alarmId);
  
  if (alarmIndex == -1) {
    throw Exception('Alarm dengan ID $alarmId tidak ditemukan');
  }
  
  // Update status approval dalam dummy data
  final alarm = dummyAlarms[alarmIndex];
  dummyAlarms[alarmIndex] = alarm.copyWith(
    isApproved: true,
    isDenied: false,
  );
  
  // Simulasi success/fail (95% success rate)
  final success = DateTime.now().millisecond % 20 != 0;
  
  if (success) {
    debugPrint('Alarm $alarmId berhasil di-approve');
    return true;
  } else {
    // Rollback jika gagal
    dummyAlarms[alarmIndex] = alarm;
    throw Exception('Gagal meng-approve alarm. Silakan coba lagi.');
  }
}

/// Simulasi deny alarm
Future<bool> dummyDenyAlarm(String alarmId) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  final alarmIndex = dummyAlarms.indexWhere((alarm) => alarm.id == alarmId);
  
  if (alarmIndex == -1) {
    throw Exception('Alarm dengan ID $alarmId tidak ditemukan');
  }
  
  // Update status denial dalam dummy data
  final alarm = dummyAlarms[alarmIndex];
  dummyAlarms[alarmIndex] = alarm.copyWith(
    isDenied: true,
    isApproved: false,
  );
  
  // Simulasi success/fail (95% success rate)
  final success = DateTime.now().millisecond % 20 != 0;
  
  if (success) {
    debugPrint('Alarm $alarmId berhasil di-deny');
    return true;
  } else {
    // Rollback jika gagal
    dummyAlarms[alarmIndex] = alarm;
    throw Exception('Gagal men-deny alarm. Silakan coba lagi.');
  }
}

/// Simulasi track visitor
Future<bool> dummyTrackVisitor(String alarmId) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  final alarm = dummyAlarms.where((alarm) => alarm.id == alarmId).firstOrNull;
  
  if (alarm == null) {
    throw Exception('Alarm dengan ID $alarmId tidak ditemukan');
  }
  
  // Simulasi tracking berhasil
  debugPrint('Melacak visitor ${alarm.visitorName} dari alarm $alarmId');
  return true;
}

/// Simulasi create alarm baru
Future<bool> dummyCreateAlarm(AlarmModel newAlarm) async {
  await Future.delayed(const Duration(seconds: 2));
  
  // Simulasi success/fail (90% success rate)
  final success = DateTime.now().millisecond % 10 != 0;
  
  if (success) {
    // Tambahkan ke dummy data
    dummyAlarms.insert(0, newAlarm);
    debugPrint('Alarm berhasil dibuat: ${newAlarm.id}');
    return true;
  } else {
    throw Exception('Gagal membuat alarm. Silakan coba lagi.');
  }
}

/// Simulasi delete alarm
Future<bool> dummyDeleteAlarm(String alarmId) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  final alarmIndex = dummyAlarms.indexWhere((alarm) => alarm.id == alarmId);
  
  if (alarmIndex == -1) {
    throw Exception('Alarm dengan ID $alarmId tidak ditemukan');
  }
  
  // Remove dari dummy data
  dummyAlarms.removeAt(alarmIndex);
  debugPrint('Alarm $alarmId berhasil dihapus');
  return true;
}

/// Simulasi get alarms by status
Future<List<AlarmModel>> dummyGetAlarmsByStatus(AlarmStatus status) async {
  await Future.delayed(const Duration(milliseconds: 900));
  
  return dummyAlarms.where((alarm) => alarm.status == status).toList();
}

/// Simulasi get pending alarms (belum di-approve atau deny)
Future<List<AlarmModel>> dummyGetPendingAlarms() async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  return dummyAlarms
      .where((alarm) => !alarm.isApproved && !alarm.isDenied)
      .toList();
}



final List<AlarmModel> dummyAlarms = [
  AlarmModel(
    id: '1',
    visitorName: 'Tommy',
    alarmDescription: 'Visitor pass restricted area',
    location: 'Gedung HQ',
    date: 'Mon, 26 June 2025',
    timeRange: '10:00 - 13:00',
    status: AlarmStatus.high,
    additionalInfo: 'Sebastian',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AlarmModel(
    id: '2',
    visitorName: 'Tommy',
    alarmDescription: 'Visitor Expired',
    location: 'Gedung HQ',
    date: 'Mon, 26 June 2025',
    timeRange: '10:00 - 13:00',
    status: AlarmStatus.medium,
    additionalInfo: 'Sebastian',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  AlarmModel(
    id: '3',
    visitorName: 'Alice',
    alarmDescription: 'Visitor entering without permission',
    location: 'Building B',
    date: 'Mon, 26 June 2025',
    timeRange: '14:00 - 16:00',
    status: AlarmStatus.high,
    additionalInfo: 'Security Team',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  AlarmModel(
    id: '4',
    visitorName: 'John Doe',
    alarmDescription: 'Late check-in notification',
    location: 'Main Lobby',
    date: 'Mon, 26 June 2025',
    timeRange: '09:00 - 12:00',
    status: AlarmStatus.low,
    additionalInfo: 'Reception',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  AlarmModel(
    id: '5',
    visitorName: 'Sarah Wilson',
    alarmDescription: 'Visitor overstay alert',
    location: 'Conference Room A',
    date: 'Mon, 26 June 2025',
    timeRange: '11:00 - 17:00',
    status: AlarmStatus.medium,
    additionalInfo: 'Management',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];