import '../models/visit_history_model.dart';

/// Simulasi fetch semua history
Future<List<VisitHistoryModel>> dummyGetAllHistory() async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return dummyVisitHistory;
}

/// Simulasi fetch history dengan filter date range
Future<List<VisitHistoryModel>> dummyGetHistoryByDateRange(
  DateTime? startDate,
  DateTime? endDate,
) async {
  await Future.delayed(const Duration(milliseconds: 1000));

  if (startDate == null && endDate == null) {
    return dummyVisitHistory;
  }

  return dummyVisitHistory.where((visit) {
    final visitDate = visit.visitDate;
    
    if (startDate != null && endDate != null) {
      return visitDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             visitDate.isBefore(endDate.add(const Duration(days: 1)));
    } else if (startDate != null) {
      return visitDate.isAfter(startDate.subtract(const Duration(days: 1)));
    } else if (endDate != null) {
      return visitDate.isBefore(endDate.add(const Duration(days: 1)));
    }
    
    return true;
  }).toList();
}

/// Simulasi filter by location/gedung
Future<List<VisitHistoryModel>> dummyGetHistoryByLocation(String location) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  return dummyVisitHistory.where((visit) =>
    visit.location.toLowerCase().contains(location.toLowerCase())
  ).toList();
}

/// Simulasi filter dengan kombinasi date + location
Future<List<VisitHistoryModel>> dummyGetHistoryWithFilters({
  DateTime? startDate,
  DateTime? endDate,
  String? location,
}) async {
  await Future.delayed(const Duration(milliseconds: 1100));

  var filteredHistory = dummyVisitHistory.toList();

  // Filter by date range
  if (startDate != null || endDate != null) {
    filteredHistory = filteredHistory.where((visit) {
      final visitDate = visit.visitDate;
      
      if (startDate != null && endDate != null) {
        return visitDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               visitDate.isBefore(endDate.add(const Duration(days: 1)));
      } else if (startDate != null) {
        return visitDate.isAfter(startDate.subtract(const Duration(days: 1)));
      } else if (endDate != null) {
        return visitDate.isBefore(endDate.add(const Duration(days: 1)));
      }
      
      return true;
    }).toList();
  }

  // Filter by location
  if (location != null && location.isNotEmpty) {
    filteredHistory = filteredHistory.where((visit) =>
      visit.location.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  return filteredHistory;
}

/// Simulasi search history
Future<List<VisitHistoryModel>> dummySearchHistory(String keyword) async {
  await Future.delayed(const Duration(milliseconds: 600));
  
  if (keyword.isEmpty) return dummyVisitHistory;
  
  final lowerKeyword = keyword.toLowerCase();
  
  return dummyVisitHistory.where((visit) =>
    visit.title.toLowerCase().contains(lowerKeyword) ||
    visit.subtitle.toLowerCase().contains(lowerKeyword) ||
    visit.location.toLowerCase().contains(lowerKeyword) ||
    visit.type.toLowerCase().contains(lowerKeyword)
  ).toList();
}

/// Simulasi refresh history
Future<List<VisitHistoryModel>> dummyRefreshHistory() async {
  await Future.delayed(const Duration(milliseconds: 800));
  // Simulate potential new data
  return dummyVisitHistory;
}




final dummyVisitHistory = [
  VisitHistoryModel(
    id: '1',
    title: 'Kunjungan',
    subtitle: 'Gedung HQ',
    additional: 'Mon, 14 Juli 2025',
    additionalDesc: '10.00 - 12.00',
    visitDate: DateTime(2025, 7, 14, 10, 0),
    location: 'Gedung HQ',
    status: 'completed',
    type: 'kunjungan',
  ),
  VisitHistoryModel(
    id: '2',
    title: 'Meeting',
    subtitle: 'Kantor Cabang A',
    additional: 'Tue, 15 Juli 2025',
    additionalDesc: '13.00 - 15.00',
    visitDate: DateTime(2025, 7, 15, 13, 0),
    location: 'Kantor Cabang A',
    status: 'completed',
    type: 'meeting',
  ),
  VisitHistoryModel(
    id: '3',
    title: 'Interview',
    subtitle: 'Gedung HR',
    additional: 'Wed, 16 Juli 2025',
    additionalDesc: '09.00 - 11.00',
    visitDate: DateTime(2025, 7, 16, 9, 0),
    location: 'Gedung HR',
    status: 'completed',
    type: 'interview',
  ),
  VisitHistoryModel(
    id: '4',
    title: 'Training',
    subtitle: 'Ruang Pelatihan',
    additional: 'Thu, 17 Juli 2025',
    additionalDesc: '08.00 - 10.00',
    visitDate: DateTime(2025, 7, 17, 8, 0),
    location: 'Ruang Pelatihan',
    status: 'completed',
    type: 'training',
  ),
  VisitHistoryModel(
    id: '5',
    title: 'Audit',
    subtitle: 'Gedung Keuangan',
    additional: 'Fri, 18 Juli 2025',
    additionalDesc: '14.00 - 16.00',
    visitDate: DateTime(2025, 7, 18, 14, 0),
    location: 'Gedung Keuangan',
    status: 'completed',
    type: 'audit',
  ),
  VisitHistoryModel(
    id: '6',
    title: 'Presentasi',
    subtitle: 'Gedung Marketing',
    additional: 'Sat, 19 Juli 2025',
    additionalDesc: '11.00 - 13.00',
    visitDate: DateTime(2025, 7, 19, 11, 0),
    location: 'Gedung Marketing',
    status: 'completed',
    type: 'presentasi',
  ),
  VisitHistoryModel(
    id: '7',
    title: 'Workshop',
    subtitle: 'Ruang Seminar',
    additional: 'Sun, 20 Juli 2025',
    additionalDesc: '15.00 - 17.00',
    visitDate: DateTime(2025, 7, 20, 15, 0),
    location: 'Ruang Seminar',
    status: 'completed',
    type: 'workshop',
  ),
  VisitHistoryModel(
    id: '8',
    title: 'Konsultasi',
    subtitle: 'Gedung IT',
    additional: 'Mon, 21 Juli 2025',
    additionalDesc: '09.30 - 11.30',
    visitDate: DateTime(2025, 7, 21, 9, 30),
    location: 'Gedung IT',
    status: 'completed',
    type: 'konsultasi',
  ),
];

