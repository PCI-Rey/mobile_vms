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
  
  print('Filter applied - Start: $startDate, End: $endDate, Gedung: $gedung, Status: $status');
  print('Found ${filteredVisitors.length} visitors after filtering');
  
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
    print('Visitor $visitorId berhasil di-approve');
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
    print('Visitor $visitorId berhasil di-deny');
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
  
  print('Visitor ${visitor.name} berhasil check-in');
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
  
  print('Visitor ${visitor.name} berhasil check-out');
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
    print('Visitor berhasil dibuat: ${newVisitor.id}');
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
  print('Visitor $visitorId berhasil dihapus');
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



final List<VisitorListModel> dummyVisitors = [
  VisitorListModel(
    visitor: VisitorModel(
      name: 'Tommy',
      email: 'tommy@loremipsum.com',
      phone: '+62812345678',
      organisation: 'PT. Lorem ipsum',
      gender: 'Male',
      nik: '1234567890123456',
      status: 'approved',
    ),
    id: '1',
    visitorId: '7E20A56D62B',
    destination: 'Gedung HQ',
    invitationCode: '729038',
    date: 'Mon, 26 June 2025',
    timeRange: '10:00 - 13:00',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  VisitorListModel(
    visitor: VisitorModel(
      name: 'Sarah Johnson',
      email: 'sarah.johnson@techcorp.com',
      phone: '+62823456789',
      organisation: 'PT. Tech Corporation',
      gender: 'Female',
      nik: '2345678901234567',
      status: 'checkin',
      checkTime: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    ),
    id: '2',
    visitorId: '8F31B67E73C',
    destination: 'Building B',
    invitationCode: '856497',
    date: 'Mon, 26 June 2025',
    timeRange: '09:00 - 17:00',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  VisitorListModel(
    visitor: VisitorModel(
      name: 'Michael Chen',
      email: 'michael.chen@innovate.co.id',
      phone: '+62834567890',
      organisation: 'PT. Innovate Solutions',
      gender: 'Male',
      nik: '3456789012345678',
      status: 'pending',
    ),
    id: '3',
    visitorId: '9G42C78F84D',
    destination: 'Conference Room A',
    invitationCode: '142536',
    date: 'Mon, 26 June 2025',
    timeRange: '14:00 - 16:00',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  VisitorListModel(
    visitor: VisitorModel(
      name: 'Linda Wong',
      email: 'linda.wong@globalnet.com',
      phone: '+62845678901',
      organisation: 'PT. Global Network',
      gender: 'Female',
      nik: '4567890123456789',
      status: 'checkout',
      checkTime: DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
    ),
    id: '4',
    visitorId: '0H53D89G95E',
    destination: 'Gedung HQ',
    invitationCode: '397461',
    date: 'Mon, 26 June 2025',
    timeRange: '11:00 - 15:00',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  VisitorListModel(
    visitor: VisitorModel(
      name: 'David Anderson',
      email: 'david.anderson@startup.id',
      phone: '+62856789012',
      organisation: 'PT. Startup Indonesia',
      gender: 'Male',
      nik: '5678901234567890',
      status: 'deny',
    ),
    id: '5',
    visitorId: '1I64E90H06F',
    destination: 'Main Lobby',
    invitationCode: '684275',
    date: 'Mon, 26 June 2025',
    timeRange: '13:00 - 16:00',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  VisitorListModel(
    visitor: VisitorModel(
      name: 'Jessica Martinez',
      email: 'jessica.martinez@consulting.com',
      phone: '+62867890123',
      organisation: 'PT. Business Consulting',
      gender: 'Female',
      nik: '6789012345678901',
      status: 'approved',
    ),
    id: '6',
    visitorId: '2J75F01I17G',
    destination: 'Meeting Room 1',
    invitationCode: '518394',
    date: 'Mon, 26 June 2025',
    timeRange: '10:30 - 12:30',
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  VisitorListModel(
    visitor: VisitorModel(
      name: 'Robert Kim',
      email: 'robert.kim@finance.co.id',
      phone: '+62878901234',
      organisation: 'PT. Finance Solutions',
      gender: 'Male',
      nik: '7890123456789012',
      status: 'checkin',
      checkTime: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    ),
    id: '7',
    visitorId: '3K86G12J28H',
    destination: 'Building B',
    invitationCode: '726583',
    date: 'Mon, 26 June 2025',
    timeRange: '08:30 - 18:00',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  VisitorListModel(
    visitor: VisitorModel(
      name: 'Emma Thompson',
      email: 'emma.thompson@marketing.com',
      phone: '+62889012345',
      organisation: 'PT. Marketing Agency',
      gender: 'Female',
      nik: '8901234567890123',
      status: 'pending',
    ),
    id: '8',
    visitorId: '4L97H23K39I',
    destination: 'Creative Studio',
    invitationCode: '951847',
    date: 'Mon, 26 June 2025',
    timeRange: '15:00 - 17:30',
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
]; 