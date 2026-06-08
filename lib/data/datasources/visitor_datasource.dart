import 'package:flutter/foundation.dart';
import '../../core/core.dart';
import '../models/visitor_model.dart';

/// Simulasi fetch semua visitors
Future<List<VisitorListModel>> dummyGetAllVisitors() async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return dummyVisitors;
}

/// Simulasi fetch visitor by ID
Future<VisitorListModel?> dummyGetVisitorById(String id) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  try {
    return dummyVisitors.firstWhere((visitor) => visitor.id == id);
  } catch (e) {
    return null;
  }
}

/// Simulasi fetch visitors dengan filter
Future<List<VisitorListModel>> dummyGetVisitorsWithFilter({
  DateTime? startDate,
  DateTime? endDate,
  String? gedung,
  VisitorStatus? status,
}) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  List<VisitorListModel> filteredVisitors = List.from(dummyVisitors);
  
  // Filter by date range
  if (startDate != null && endDate != null) {
    filteredVisitors = filteredVisitors.where((visitor) {
      return visitor.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
             visitor.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Filter by gedung/destination
  if (gedung != null && gedung.isNotEmpty && gedung.toLowerCase() != 'all') {
    filteredVisitors = filteredVisitors.where((visitor) {
      return visitor.destination.toLowerCase().contains(gedung.toLowerCase());
    }).toList();
  }
  
  // Filter by status
  if (status != null) {
    filteredVisitors = filteredVisitors.where((visitor) {
      return visitor.statusEnum == status;
    }).toList();
  }
  
  debugPrint('Filter applied - Start: $startDate, End: $endDate, Gedung: $gedung, Status: $status');
  debugPrint('Found ${filteredVisitors.length} visitors after filtering');
  
  return filteredVisitors;
}

/// Simulasi approve visitor
Future<bool> dummyApproveVisitor(String visitorId) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  final visitorIndex = dummyVisitors.indexWhere((visitor) => visitor.id == visitorId);
  
  if (visitorIndex == -1) {
    throw Exception('Visitor dengan ID $visitorId tidak ditemukan');
  }
  
  // Update status approval dalam dummy data
  final visitor = dummyVisitors[visitorIndex];
  final updatedVisitor = visitor.visitor.copyWith(status: 'approved');
  dummyVisitors[visitorIndex] = visitor.copyWith(
    visitor: updatedVisitor,
    updatedAt: DateTime.now(),
  );
  
  // Simulasi success/fail (95% success rate)
  final success = DateTime.now().millisecond % 20 != 0;
  
  if (success) {
    debugPrint('Visitor $visitorId berhasil di-approve');
    return true;
  } else {
    // Rollback jika gagal
    dummyVisitors[visitorIndex] = visitor;
    throw Exception('Gagal meng-approve visitor. Silakan coba lagi.');
  }
}

/// Simulasi deny visitor
Future<bool> dummyDenyVisitor(String visitorId) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  final visitorIndex = dummyVisitors.indexWhere((visitor) => visitor.id == visitorId);
  
  if (visitorIndex == -1) {
    throw Exception('Visitor dengan ID $visitorId tidak ditemukan');
  }
  
  // Update status denial dalam dummy data
  final visitor = dummyVisitors[visitorIndex];
  final updatedVisitor = visitor.visitor.copyWith(status: 'deny');
  dummyVisitors[visitorIndex] = visitor.copyWith(
    visitor: updatedVisitor,
    updatedAt: DateTime.now(),
  );
  
  // Simulasi success/fail (95% success rate)
  final success = DateTime.now().millisecond % 20 != 0;
  
  if (success) {
    debugPrint('Visitor $visitorId berhasil di-deny');
    return true;
  } else {
    // Rollback jika gagal
    dummyVisitors[visitorIndex] = visitor;
    throw Exception('Gagal men-deny visitor. Silakan coba lagi.');
  }
}

/// Simulasi check-in visitor
Future<bool> dummyCheckInVisitor(String visitorId) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  final visitorIndex = dummyVisitors.indexWhere((visitor) => visitor.id == visitorId);
  
  if (visitorIndex == -1) {
    throw Exception('Visitor dengan ID $visitorId tidak ditemukan');
  }
  
  final visitor = dummyVisitors[visitorIndex];
  
  // Cek apakah visitor sudah approved
  if (visitor.statusEnum != VisitorStatus.approved) {
    throw Exception('Visitor harus di-approve terlebih dahulu sebelum check-in');
  }
  
  final updatedVisitor = visitor.visitor.copyWith(
    status: 'checkin',
    checkTime: DateTime.now().toIso8601String(),
  );
  
  dummyVisitors[visitorIndex] = visitor.copyWith(
    visitor: updatedVisitor,
    updatedAt: DateTime.now(),
  );
  
  debugPrint('Visitor ${visitor.name} berhasil check-in');
  return true;
}

/// Simulasi check-out visitor
Future<bool> dummyCheckOutVisitor(String visitorId) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  final visitorIndex = dummyVisitors.indexWhere((visitor) => visitor.id == visitorId);
  
  if (visitorIndex == -1) {
    throw Exception('Visitor dengan ID $visitorId tidak ditemukan');
  }
  
  final visitor = dummyVisitors[visitorIndex];
  
  // Cek apakah visitor sudah check-in
  if (visitor.statusEnum != VisitorStatus.checkedIn) {
    throw Exception('Visitor harus check-in terlebih dahulu sebelum check-out');
  }
  
  final updatedVisitor = visitor.visitor.copyWith(
    status: 'checkout',
    checkTime: DateTime.now().toIso8601String(),
  );
  
  dummyVisitors[visitorIndex] = visitor.copyWith(
    visitor: updatedVisitor,
    updatedAt: DateTime.now(),
  );
  
  debugPrint('Visitor ${visitor.name} berhasil check-out');
  return true;
}

/// Simulasi create visitor baru
Future<bool> dummyCreateVisitor(VisitorListModel newVisitor) async {
  await Future.delayed(const Duration(seconds: 2));
  
  // Simulasi success/fail (90% success rate)
  final success = DateTime.now().millisecond % 10 != 0;
  
  if (success) {
    // Tambahkan ke dummy data
    dummyVisitors.insert(0, newVisitor);
    debugPrint('Visitor berhasil dibuat: ${newVisitor.id}');
    return true;
  } else {
    throw Exception('Gagal membuat visitor. Silakan coba lagi.');
  }
}

/// Simulasi delete visitor
Future<bool> dummyDeleteVisitor(String visitorId) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  final visitorIndex = dummyVisitors.indexWhere((visitor) => visitor.id == visitorId);
  
  if (visitorIndex == -1) {
    throw Exception('Visitor dengan ID $visitorId tidak ditemukan');
  }
  
  // Remove dari dummy data
  dummyVisitors.removeAt(visitorIndex);
  debugPrint('Visitor $visitorId berhasil dihapus');
  return true;
}

/// Simulasi get visitors by status
Future<List<VisitorListModel>> dummyGetVisitorsByStatus(VisitorStatus status) async {
  await Future.delayed(const Duration(milliseconds: 900));
  
  return dummyVisitors.where((visitor) => visitor.statusEnum == status).toList();
}

/// Simulasi get pending visitors (belum di-approve atau deny)
Future<List<VisitorListModel>> dummyGetPendingVisitors() async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  return dummyVisitors
      .where((visitor) => visitor.statusEnum == VisitorStatus.pending)
      .toList();
}

/// Simulasi get checked-in visitors
Future<List<VisitorListModel>> dummyGetCheckedInVisitors() async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  return dummyVisitors
      .where((visitor) => visitor.statusEnum == VisitorStatus.checkedIn)
      .toList();
}

/// Simulasi search visitors by name or company
Future<List<VisitorListModel>> dummySearchVisitors(String query) async {
  await Future.delayed(const Duration(milliseconds: 600));
  
  if (query.isEmpty) return dummyVisitors;
  
  final lowercaseQuery = query.toLowerCase();
  return dummyVisitors.where((visitor) {
    return visitor.name.toLowerCase().contains(lowercaseQuery) ||
           visitor.organisation.toLowerCase().contains(lowercaseQuery) ||
           visitor.destination.toLowerCase().contains(lowercaseQuery) ||
           visitor.visitorId.toLowerCase().contains(lowercaseQuery);
  }).toList();
}



final List<VisitorListModel> dummyVisitors = []; 