import '../../core/components/components.dart'; // Import untuk VisitorStatus enum

class ApprovalModel {
  final String id;
  final String visitorName;
  final String companyName;
  final String destination;
  final String date;
  final String timeRange;
  final VisitorStatus status;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? email;
  final String? purpose;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isApproved;
  final bool isDenied;

  ApprovalModel({
    required this.id,
    required this.visitorName,
    required this.companyName,
    required this.destination,
    required this.date,
    required this.timeRange,
    required this.status,
    this.avatarUrl,
    this.phoneNumber,
    this.email,
    this.purpose,
    required this.createdAt,
    this.updatedAt,
    this.isApproved = false,
    this.isDenied = false,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      id: json['id'].toString(),
      visitorName: json['visitor_name'],
      companyName: json['company_name'],
      destination: json['destination'],
      date: json['date'],
      timeRange: json['time_range'],
      status: _parseVisitorStatus(json['status']),
      avatarUrl: json['avatar_url'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      purpose: json['purpose'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isApproved: json['is_approved'] ?? false,
      isDenied: json['is_denied'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'visitor_name': visitorName,
        'company_name': companyName,
        'destination': destination,
        'date': date,
        'time_range': timeRange,
        'status': _visitorStatusToString(status),
        'avatar_url': avatarUrl,
        'phone_number': phoneNumber,
        'email': email,
        'purpose': purpose,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_approved': isApproved,
        'is_denied': isDenied,
      };

  static VisitorStatus _parseVisitorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return VisitorStatus.pending;
      case 'approved':
        return VisitorStatus.approved;
      case 'denied':
        return VisitorStatus.denied;
      case 'checked_in':
        return VisitorStatus.checkedIn;
      case 'checked_out':
        return VisitorStatus.checkedOut;
      default:
        return VisitorStatus.pending;
    }
  }

  static String _visitorStatusToString(VisitorStatus status) {
    switch (status) {
      case VisitorStatus.pending:
        return 'pending';
      case VisitorStatus.approved:
        return 'approved';
      case VisitorStatus.denied:
        return 'denied';
      case VisitorStatus.checkedIn:
        return 'checked_in';
      case VisitorStatus.checkedOut:
        return 'checked_out';
    }
  }

  // Copy with method untuk update status
  ApprovalModel copyWith({
    String? id,
    String? visitorName,
    String? companyName,
    String? destination,
    String? date,
    String? timeRange,
    VisitorStatus? status,
    String? avatarUrl,
    String? phoneNumber,
    String? email,
    String? purpose,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isApproved,
    bool? isDenied,
  }) {
    return ApprovalModel(
      id: id ?? this.id,
      visitorName: visitorName ?? this.visitorName,
      companyName: companyName ?? this.companyName,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isApproved: isApproved ?? this.isApproved,
      isDenied: isDenied ?? this.isDenied,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApprovalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}