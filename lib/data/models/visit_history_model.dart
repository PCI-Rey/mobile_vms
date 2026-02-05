class VisitHistoryModel {
  final String id;
  final String title;
  final String subtitle;
  final String additional;
  final String additionalDesc;
  final DateTime visitDate;
  final String location;
  final String status; // completed, cancelled, pending
  final String type; // kunjungan, meeting, interview, etc.

  VisitHistoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.additional,
    required this.additionalDesc,
    required this.visitDate,
    required this.location,
    required this.status,
    required this.type,
  });
}