import 'dart:convert';

class UserModel {
  final String? applicationId;
  final String? organizationId;
  final String? userGroupId;
  final String? email;
  final String? username;
  final String? fullname;
  final String? description;
  final String? access;
  final String? token;
  final String? employeeId;
  final String? distributorId;
  final List<dynamic>? menu;
  final List<GroupAccess>? groupAccess;
  final String? roleAccess;
  final String id;
  final int? status;

  // Visitor-specific fields
  final String? phone;
  final String? visitorCode;
  final String? invitationCode;
  final String? hostName;
  final String? sitePlaceName;
  final String? visitorStatus;
  final String? faceUrl;

  /// Stores the complete raw API collection JSON string (for both Employee & Visitor)
  final String? extraData;

  UserModel({
    this.applicationId,
    this.organizationId,
    this.userGroupId,
    this.email,
    this.username,
    this.fullname,
    this.description,
    this.access,
    this.token,
    this.employeeId,
    this.distributorId,
    this.menu,
    this.groupAccess,
    this.roleAccess,
    required this.id,
    this.status,
    // Visitor fields
    this.phone,
    this.visitorCode,
    this.invitationCode,
    this.hostName,
    this.sitePlaceName,
    this.visitorStatus,
    this.faceUrl,
    this.extraData,
  });

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      applicationId: json['application_id']?.toString(),
      organizationId: json['organization_id']?.toString(),
      userGroupId: json['user_group_id']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      fullname: json['fullname']?.toString(),
      description: json['description']?.toString(),
      access: json['access']?.toString(),
      token: json['token']?.toString(),
      employeeId: json['employee_id']?.toString(),
      distributorId: json['distributor_id']?.toString(),
      menu: json['menu'] != null ? List<dynamic>.from(json['menu']) : null,
      groupAccess: json['groupAccess'] != null
          ? List<GroupAccess>.from(
              json['groupAccess'].map((x) => GroupAccess.fromJson(x)))
          : null,
      roleAccess: json['role_access']?.toString(),
      id: json['id'].toString(),
      status: json['status'],
      // Visitor fields
      phone: json['phone']?.toString(),
      visitorCode: json['visitor_code']?.toString(),
      invitationCode: json['invitation_code']?.toString(),
      hostName: json['host_name']?.toString(),
      sitePlaceName: json['site_place_name']?.toString(),
      visitorStatus: json['visitor_status']?.toString(),
      faceUrl: json['visitor_face']?.toString() ?? json['face_url']?.toString(),
      extraData: json['extra_data']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'organization_id': organizationId,
      'user_group_id': userGroupId,
      'email': email,
      'username': username,
      'fullname': fullname,
      'description': description,
      'access': access,
      'token': token,
      'employee_id': employeeId,
      'distributor_id': distributorId,
      'menu': menu,
      'groupAccess': groupAccess?.map((x) => x.toJson()).toList(),
      'role_access': roleAccess,
      'id': id,
      'status': status,
      // Visitor fields
      'phone': phone,
      'visitor_code': visitorCode,
      'invitation_code': invitationCode,
      'host_name': hostName,
      'site_place_name': sitePlaceName,
      'visitor_status': visitorStatus,
      'visitor_face': faceUrl,
      'extra_data': extraData,
    };
  }
}

class GroupAccess {
  final String? userGroupId;
  final String? accessCode;
  final int? isPrivate;
  final dynamic userId;
  final String? roleAccess;
  final String? id;
  final int? status;

  GroupAccess({
    this.userGroupId,
    this.accessCode,
    this.isPrivate,
    this.userId,
    this.roleAccess,
    this.id,
    this.status,
  });

  factory GroupAccess.fromRawJson(String str) =>
      GroupAccess.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GroupAccess.fromJson(Map<String, dynamic> json) {
    return GroupAccess(
      userGroupId: json['user_group_id']?.toString(),
      accessCode: json['access_code']?.toString(),
      isPrivate: json['is_private'],
      userId: json['userId'],
      roleAccess: json['role_access']?.toString(),
      id: json['id']?.toString(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_group_id': userGroupId,
      'access_code': accessCode,
      'is_private': isPrivate,
      'userId': userId,
      'role_access': roleAccess,
      'id': id,
      'status': status,
    };
  }
}
