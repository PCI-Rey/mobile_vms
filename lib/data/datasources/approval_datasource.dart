import '../../core/core.dart';
import '../models/approval_model.dart';

// Dummy data approval visitors
List<ApprovalModel> dummyApprovals = [
  ApprovalModel(
    id: 'visitor_001',
    visitorName: 'Tommy Anderson',
    companyName: 'PT. Lorem Ipsum Tech',
    destination: 'Gedung HQ',
    date: 'Mon, 26 June 2025',
    timeRange: '10:00 - 13:00',
    status: VisitorStatus.pending,
    avatarUrl: 'assets/images/ava_person1.png',
    phoneNumber: '+62 812 3456 7890',
    email: 'tommy.anderson@loremipsum.com',
    purpose: 'Meeting with IT Department',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isApproved: false,
    isDenied: false,
  ),
  ApprovalModel(
    id: 'visitor_002',
    visitorName: 'Sarah Johnson',
    companyName: 'PT. Digital Solutions',
    destination: 'Gedung B',
    date: 'Tue, 27 June 2025',
    timeRange: '09:00 - 11:00',
    status: VisitorStatus.approved,
    avatarUrl: 'assets/images/ava_person2.png',
    phoneNumber: '+62 813 9876 5432',
    email: 'sarah.johnson@digitalsolutions.com',
    purpose: 'Product Presentation',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    isApproved: true,
    isDenied: false,
  ),
  ApprovalModel(
    id: 'visitor_003',
    visitorName: 'Michael Chen',
    companyName: 'PT. Innovation Labs',
    destination: 'Gedung A',
    date: 'Wed, 28 June 2025',
    timeRange: '14:00 - 16:00',
    status: VisitorStatus.denied,
    avatarUrl: 'assets/images/ava_person3.png',
    phoneNumber: '+62 814 1122 3344',
    email: 'michael.chen@innovationlabs.com',
    purpose: 'Partnership Discussion',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    isApproved: false,
    isDenied: true,
  ),
  ApprovalModel(
    id: 'visitor_004',
    visitorName: 'Lisa Wang',
    companyName: 'PT. Creative Agency',
    destination: 'Gedung HQ',
    date: 'Thu, 29 June 2025',
    timeRange: '11:00 - 12:30',
    status: VisitorStatus.pending,
    avatarUrl: 'assets/images/ava_person3.png',
    phoneNumber: '+62 815 5566 7788',
    email: 'lisa.wang@creativeagency.com',
    purpose: 'Design Review Meeting',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    isApproved: false,
    isDenied: false,
  ),
 
];

/// Simulasi fetch semua approval visitors
Future<List<ApprovalModel>> dummyGetAllApprovals() async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return dummyApprovals;
}

/// Simulasi fetch approval visitors with filter
Future<List<ApprovalModel>> dummyGetApprovalsWithFilter({
  DateTime? startDate,
  DateTime? endDate,
  String? gedung,
  VisitorStatus? status,
}) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  List<ApprovalModel> filtered = List.from(dummyApprovals);
  
  // Filter by gedung/destination
  if (gedung != null && gedung.isNotEmpty) {
    filtered = filtered.where((approval) {
      return approval.destination.toLowerCase().contains(gedung.toLowerCase());
    }).toList();
  }
  
  // Filter by status
  if (status != null) {
    filtered = filtered.where((approval) => approval.status == status).toList();
  }
  
  // Filter by date range
  if (startDate != null || endDate != null) {
    filtered = filtered.where((approval) {
      try {
        final approvalDate = _parseApprovalDate(approval.date);
        if (approvalDate == null) return true; // Include if can't parse
        
        bool matchesStart = startDate == null || 
          approvalDate.isAfter(startDate.subtract(const Duration(days: 1)));
        bool matchesEnd = endDate == null || 
          approvalDate.isBefore(endDate.add(const Duration(days: 1)));
        
        return matchesStart && matchesEnd;
      } catch (e) {
        return true; // Include if error in parsing
      }
    }).toList();
  }
  
  print('Filter applied - Gedung: $gedung, Start: $startDate, End: $endDate, Status: $status');
  print('Results: ${filtered.length} approvals found');
  
  return filtered;
}

/// Helper function to parse approval date from string format
DateTime? _parseApprovalDate(String dateStr) {
  try {
    // Handle format "Mon, 26 June 2025"
    final parts = dateStr.split(', ');
    if (parts.length != 2) return null;
    
    final datePart = parts[1]; // "26 June 2025"
    final dateComponents = datePart.split(' ');
    if (dateComponents.length != 3) return null;
    
    final day = int.tryParse(dateComponents[0]);
    final monthStr = dateComponents[1].toLowerCase();
    final year = int.tryParse(dateComponents[2]);
    
    if (day == null || year == null) return null;
    
    // Map English month names to numbers
    final monthMap = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12,
    };
    
    final month = monthMap[monthStr] ?? 1;
    
    return DateTime(year, month, day);
  } catch (e) {
    return null;
  }
}

/// Simulasi get approvals by status
Future<List<ApprovalModel>> dummyGetApprovalsByStatus(VisitorStatus status) async {
  await Future.delayed(const Duration(milliseconds: 900));
  return dummyApprovals.where((approval) => approval.status == status).toList();
}

/// Simulasi get pending approvals (belum di-approve atau deny)
Future<List<ApprovalModel>> dummyGetPendingApprovals() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return dummyApprovals.where((approval) => approval.status == VisitorStatus.pending).toList();
}

/// Simulasi approve visitor
Future<bool> dummyApproveApproval(String approvalId) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  final approvalIndex = dummyApprovals.indexWhere((approval) => approval.id == approvalId);
  
  if (approvalIndex == -1) {
    throw Exception('Approval dengan ID $approvalId tidak ditemukan');
  }
  
  // Update status approval dalam dummy data
  final approval = dummyApprovals[approvalIndex];
  dummyApprovals[approvalIndex] = approval.copyWith(
    status: VisitorStatus.approved,
    isApproved: true,
    isDenied: false,
    updatedAt: DateTime.now(),
  );
  
  // Simulasi success/fail (95% success rate)
  final success = DateTime.now().millisecond % 20 != 0;
  
  if (success) {
    print('Approval $approvalId berhasil di-approve');
    return true;
  } else {
    // Rollback jika gagal
    dummyApprovals[approvalIndex] = approval;
    throw Exception('Gagal meng-approve visitor. Silakan coba lagi.');
  }
}

/// Simulasi deny visitor
Future<bool> dummyDenyApproval(String approvalId) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  final approvalIndex = dummyApprovals.indexWhere((approval) => approval.id == approvalId);
  
  if (approvalIndex == -1) {
    throw Exception('Approval dengan ID $approvalId tidak ditemukan');
  }
  
  // Update status denial dalam dummy data
  final approval = dummyApprovals[approvalIndex];
  dummyApprovals[approvalIndex] = approval.copyWith(
    status: VisitorStatus.denied,
    isApproved: false,
    isDenied: true,
    updatedAt: DateTime.now(),
  );
  
  // Simulasi success/fail (95% success rate)
  final success = DateTime.now().millisecond % 20 != 0;
  
  if (success) {
    print('Approval $approvalId berhasil di-deny');
    return true;
  } else {
    // Rollback jika gagal
    dummyApprovals[approvalIndex] = approval;
    throw Exception('Gagal men-deny visitor. Silakan coba lagi.');
  }
}

/// Simulasi get approval by ID
Future<ApprovalModel?> dummyGetApprovalById(String id) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  try {
    return dummyApprovals.firstWhere((approval) => approval.id == id);
  } catch (e) {
    return null;
  }
}

/// Simulasi refresh approvals
Future<List<ApprovalModel>> dummyRefreshApprovals() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return dummyApprovals;
}