import '../../core/core.dart';

class VisitorModel {
  final String name;
  final String email;
  final String phone;
  final String organisation;
  final String gender;
  final String nik;
  final String? status; // 'checkin', 'checkout', 'deny'
  final String? checkTime; // format DateTime

  VisitorModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.organisation,
    required this.gender,
    required this.nik,
    this.status,
    this.checkTime,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      organisation: json['organisation'],
      gender: json['gender'],
      nik: json['nik'],
      status: json['status'],
      checkTime: json['check_time']
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'organisation': organisation,
        'gender': gender,
        'nik': nik,
        if (status != null) 'status': status,
        if (checkTime != null)
          'check_time': checkTime, // ISO format
      };
}

// Menggunakan model VisitorModel yang sudah ada dan menambahkan properti tambahan

extension VisitorModelExtension on VisitorModel {
  // Helper untuk mendapatkan status enum dari string
  VisitorStatus get statusEnum {
    switch (status?.toLowerCase()) {
      case 'checkin':
        return VisitorStatus.checkedIn;
      case 'checkout':
        return VisitorStatus.checkedOut;
      case 'deny':
        return VisitorStatus.denied;
      default:
        return VisitorStatus.approved; // Default untuk visitor yang sudah approved
    }
  }

  // Helper untuk mendapatkan status string dari enum
  String get statusString {
    switch (statusEnum) {
      case VisitorStatus.pending:
        return 'pending';
      case VisitorStatus.approved:
        return 'approved';
      case VisitorStatus.denied:
        return 'deny';
      case VisitorStatus.checkedIn:
        return 'checkin';
      case VisitorStatus.checkedOut:
        return 'checkout';
    }
  }

  // Copy with method untuk update model yang sudah ada
  VisitorModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? organisation,
    String? gender,
    String? nik,
    String? status,
    String? checkTime,
  }) {
    return VisitorModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organisation: organisation ?? this.organisation,
      gender: gender ?? this.gender,
      nik: nik ?? this.nik,
      status: status ?? this.status,
      checkTime: checkTime ?? this.checkTime,
    );
  }
}

// Model tambahan untuk list visitor yang extend dari VisitorModel yang sudah ada
class VisitorListModel {
  final VisitorModel visitor;
  final String id; // ID internal untuk list
  final String visitorId; // ID yang ditampilkan ke user
  final String destination;
  final String invitationCode;
  final String date;
  final String timeRange;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VisitorListModel({
    required this.visitor,
    required this.id,
    required this.visitorId,
    required this.destination,
    required this.invitationCode,
    required this.date,
    required this.timeRange,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  // Getter untuk mengakses data dari VisitorModel yang sudah ada
  String get name => visitor.name;
  String get email => visitor.email;
  String get phone => visitor.phone;
  String get organisation => visitor.organisation;
  String get gender => visitor.gender;
  String get nik => visitor.nik;
  String? get status => visitor.status;
  String? get checkTime => visitor.checkTime;
  VisitorStatus get statusEnum => visitor.statusEnum;

  factory VisitorListModel.fromJson(Map<String, dynamic> json) {
    return VisitorListModel(
      visitor: VisitorModel.fromJson(json),
      id: json['id'] ?? '',
      visitorId: json['visitor_id'] ?? '',
      destination: json['destination'] ?? '',
      invitationCode: json['invitation_code'] ?? '',
      date: json['date'] ?? '',
      timeRange: json['time_range'] ?? '',
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = visitor.toJson();
    json.addAll({
      'id': id,
      'visitor_id': visitorId,
      'destination': destination,
      'invitation_code': invitationCode,
      'date': date,
      'time_range': timeRange,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    });
    return json;
  }

  VisitorListModel copyWith({
    VisitorModel? visitor,
    String? id,
    String? visitorId,
    String? destination,
    String? invitationCode,
    String? date,
    String? timeRange,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VisitorListModel(
      visitor: visitor ?? this.visitor,
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      destination: destination ?? this.destination,
      invitationCode: invitationCode ?? this.invitationCode,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitorListModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VisitorListModel(id: $id, visitorId: $visitorId, name: $name, status: $status)';
  }
}

