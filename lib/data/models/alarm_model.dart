import '../../core/components/components.dart'; // Import untuk AlarmStatus enum

class AlarmModel {
  final String id;
  final String visitorName;
  final String alarmDescription;
  final String location;
  final String date;
  final String timeRange;
  final AlarmStatus status;
  final String? additionalInfo;
  final DateTime createdAt;
  final bool isApproved;
  final bool isDenied;

  AlarmModel({
    required this.id,
    required this.visitorName,
    required this.alarmDescription,
    required this.location,
    required this.date,
    required this.timeRange,
    required this.status,
    this.additionalInfo,
    required this.createdAt,
    this.isApproved = false,
    this.isDenied = false,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'].toString(),
      visitorName: json['visitor_name'],
      alarmDescription: json['alarm_description'],
      location: json['location'],
      date: json['date'],
      timeRange: json['time_range'],
      status: _parseAlarmStatus(json['status']),
      additionalInfo: json['additional_info'],
      createdAt: DateTime.parse(json['created_at']),
      isApproved: json['is_approved'] ?? false,
      isDenied: json['is_denied'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'visitor_name': visitorName,
        'alarm_description': alarmDescription,
        'location': location,
        'date': date,
        'time_range': timeRange,
        'status': _alarmStatusToString(status),
        'additional_info': additionalInfo,
        'created_at': createdAt.toIso8601String(),
        'is_approved': isApproved,
        'is_denied': isDenied,
      };

  static AlarmStatus _parseAlarmStatus(String status) {
    switch (status.toLowerCase()) {
      case 'high':
        return AlarmStatus.high;
      case 'medium':
        return AlarmStatus.medium;
      case 'low':
        return AlarmStatus.low;
      default:
        return AlarmStatus.low;
    }
  }

  static String _alarmStatusToString(AlarmStatus status) {
    switch (status) {
      case AlarmStatus.high:
        return 'high';
      case AlarmStatus.medium:
        return 'medium';
      case AlarmStatus.low:
        return 'low';
    }
  }

  // Copy with method untuk update status
  AlarmModel copyWith({
    String? id,
    String? visitorName,
    String? alarmDescription,
    String? location,
    String? date,
    String? timeRange,
    AlarmStatus? status,
    String? additionalInfo,
    DateTime? createdAt,
    bool? isApproved,
    bool? isDenied,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      visitorName: visitorName ?? this.visitorName,
      alarmDescription: alarmDescription ?? this.alarmDescription,
      location: location ?? this.location,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      status: status ?? this.status,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      isDenied: isDenied ?? this.isDenied,
    );
  }
}