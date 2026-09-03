import 'dart:convert';

class AccessPassModel {
  final String id;
  final String agenda;
  final String initialTrxCode;
  final String host;
  final bool isGroup;
  final String groupName;
  final DateTime visitorPeriodStart;
  final DateTime visitorPeriodEnd;
  final String visitorNumber;
  final String visitorCode;
  final String invitationCode;
  final String visitorStatus;
  final String sitePlaceName;
  final String hostName;
  final String parkingSlot;
  final String parkingArea;
  final String vehiclePlateNumber;
  final String vehicleType;
  final bool isDriving;
  final String tz;
  final String siteId;
  final String visitorName;
  final bool isPraregisterDone;
  final String visitorRole;
  // Fields from /visitor/transaction/dt
  final String approvalStatus;
  final String visitorTypeName;
  final String visitorTypeId;
  final String transactionVisitorId;
  final String invitedByName;
  final String invitedBy;
  final String hostOrganizationName;
  final String flow;
  final String visitorOrganizationName;
  final String visitorPhone;
  final String visitorEmail;
  final String visitorIdentityId;
  final String receiverName;
  final String receiverEmail;
  final String receiverPhone;
  final String groupCode;
  final bool? canTrackBle;
  final bool? canAccess;
  final DateTime? invitationCreatedAt;
  final String? sitePlaceId;
  final bool isReceiverSelf;

  AccessPassModel({
    required this.id,
    required this.agenda,
    required this.initialTrxCode,
    required this.host,
    required this.isGroup,
    required this.groupName,
    required this.visitorPeriodStart,
    required this.visitorPeriodEnd,
    required this.visitorNumber,
    required this.visitorCode,
    required this.invitationCode,
    required this.visitorStatus,
    required this.sitePlaceName,
    required this.hostName,
    required this.parkingSlot,
    required this.parkingArea,
    required this.vehiclePlateNumber,
    required this.vehicleType,
    required this.isDriving,
    required this.tz,
    required this.siteId,
    required this.visitorName,
    required this.isPraregisterDone,
    required this.visitorRole,
    this.approvalStatus = '',
    this.visitorTypeName = '',
    this.visitorTypeId = '',
    this.transactionVisitorId = '',
    this.invitedByName = '',
    this.invitedBy = '',
    this.hostOrganizationName = '',
    this.flow = '',
    this.visitorOrganizationName = '',
    this.visitorPhone = '',
    this.visitorEmail = '',
    this.visitorIdentityId = '',
    this.receiverName = '',
    this.receiverEmail = '',
    this.receiverPhone = '',
    this.groupCode = '',
    this.canTrackBle = false,
    this.canAccess = false,
    this.invitationCreatedAt,
    this.sitePlaceId,
    this.isReceiverSelf = false,
  });

  factory AccessPassModel.fromRawJson(String str) =>
      AccessPassModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AccessPassModel.fromJson(Map<String, dynamic> json) {
    return AccessPassModel(
      id: (json['id'] ?? json['transaction_visitor_id'])?.toString() ?? '',
      agenda: json['agenda']?.toString() ?? '',
      initialTrxCode: json['initial_trx_code']?.toString() ?? '',
      host: json['host']?.toString() ?? '',
      isGroup: json['is_group'] == true ||
          json['is_group'] == 1 ||
          json['is_group']?.toString() == 'true' ||
          json['type_registered']?.toString() == '1' ||
          json['self_only'] == false ||
          json['self_only'] == 0 ||
          json['self_only']?.toString() == 'false' ||
          (json['group_name']?.toString() ?? '').isNotEmpty,
      groupName: json['group_name']?.toString() ?? '',
      visitorPeriodStart:
          (json['visitor_period_start'] ??
                  json['visit_start'] ??
                  json['start_date'] ??
                  json['visit_date']) !=
              null
          ? _parseUtcToLocal(
              (json['visitor_period_start'] ??
                      json['visit_start'] ??
                      json['start_date'] ??
                      json['visit_date'])
                  .toString(),
            )
          : DateTime.now(),
      visitorPeriodEnd:
          (json['visitor_period_end'] ??
                  json['visit_end'] ??
                  json['end_date']) !=
              null
          ? _parseUtcToLocal(
              (json['visitor_period_end'] ??
                      json['visit_end'] ??
                      json['end_date'])
                  .toString(),
            )
          : DateTime.now(),
      visitorNumber: json['visitor_number']?.toString() ?? '',
      visitorCode: json['visitor_code']?.toString() ?? json['initial_trx_code']?.toString() ?? '',
      invitationCode: json['invitation_code']?.toString() ?? json['initial_trx_code']?.toString() ?? '',
      // Support both old visitor_status and new transaction_status field
      visitorStatus: (json['transaction_status'] ?? json['visitor_status'])?.toString() ?? '',
      sitePlaceName: (json['site_place_name'] ?? json['host_organization_name'])?.toString() ?? '',
      hostName: json['host_name']?.toString() ?? '',
      parkingSlot: json['parking_slot']?.toString() ?? '',
      parkingArea: json['parking_area']?.toString() ?? '',
      vehiclePlateNumber: json['vehicle_plate_number']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      isDriving: json['is_driving'] == true,
      tz: json['tz']?.toString() ?? '',
      siteId: (json['site_id'] ?? json['site_place'])?.toString() ?? '',
      visitorName: (json['visitor_name']?.toString() ?? '').isNotEmpty
          ? json['visitor_name'].toString()
          : (json['group_name']?.toString() ?? ''),
      isPraregisterDone:
          json['is_complete_preregister'] == true ||
          json['is_praregister_done'] == true,
      visitorRole: json['visitor_role']?.toString() ?? '',
      approvalStatus: json['approval_status']?.toString() ?? '',
      visitorTypeName: json['visitor_type_name']?.toString() ?? '',
      visitorTypeId: (json['visitor_type_id'] ?? json['visitor_type'])?.toString() ?? '',
      transactionVisitorId: json['transaction_visitor_id']?.toString() ?? '',
      invitedByName: json['invited_by_name']?.toString() ?? '',
      invitedBy: json['invited_by']?.toString() ?? '',
      hostOrganizationName: json['host_organization_name']?.toString() ?? '',
      flow: json['flow']?.toString() ?? '',
      visitorOrganizationName:
          json['visitor_organization_name']?.toString() ?? '',
      visitorPhone: json['visitor_phone']?.toString() ?? '',
      visitorEmail: json['visitor_email']?.toString() ?? '',
      visitorIdentityId: json['visitor_identity_id']?.toString() ?? '',
      receiverName: json['receiver_name']?.toString() ?? '',
      receiverEmail: json['receiver_email']?.toString() ?? '',
      receiverPhone: json['receiver_phone']?.toString() ?? '',
      groupCode: json['group_code']?.toString() ?? '',
      canTrackBle: json['can_track_ble'] == true ||
          json['can_track_ble'] == 1 ||
          json['can_track_ble']?.toString() == 'true',
      canAccess: json['can_access'] == true ||
          json['can_access'] == 1 ||
          json['can_access']?.toString() == 'true',
      invitationCreatedAt: json['invitation_created_at'] != null
          ? _parseUtcToLocal(json['invitation_created_at'].toString())
          : null,
      sitePlaceId: (json['site_place_id'] ?? json['site_place'] ?? json['site_id'])?.toString(),
      isReceiverSelf: json['is_receiver_self'] == true ||
          json['is_receiver_self'] == 1 ||
          json['is_receiver_self']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agenda': agenda,
    'initial_trx_code': initialTrxCode,
    'host': host,
    'is_group': isGroup,
    'group_name': groupName,
    'visitor_period_start': visitorPeriodStart.toIso8601String(),
    'visitor_period_end': visitorPeriodEnd.toIso8601String(),
    'visitor_number': visitorNumber,
    'visitor_code': visitorCode,
    'invitation_code': invitationCode,
    'visitor_status': visitorStatus,
    'site_place_name': sitePlaceName,
    'host_name': hostName,
    'parking_slot': parkingSlot,
    'parking_area': parkingArea,
    'vehicle_plate_number': vehiclePlateNumber,
    'vehicle_type': vehicleType,
    'is_driving': isDriving,
    'tz': tz,
    'site_id': siteId,
    'visitor_name': visitorName,
    'is_complete_preregister': isPraregisterDone,
    'visitor_role': visitorRole,
    'approval_status': approvalStatus,
    'visitor_type_name': visitorTypeName,
    'visitor_type_id': visitorTypeId,
    'transaction_visitor_id': transactionVisitorId,
    'invited_by_name': invitedByName,
    'invited_by': invitedBy,
    'host_organization_name': hostOrganizationName,
    'flow': flow,
    'visitor_organization_name': visitorOrganizationName,
    'visitor_phone': visitorPhone,
    'visitor_email': visitorEmail,
    'visitor_identity_id': visitorIdentityId,
    'receiver_name': receiverName,
    'receiver_email': receiverEmail,
    'receiver_phone': receiverPhone,
    'group_code': groupCode,
    'can_track_ble': canTrackBle,
    'can_access': canAccess,
    'invitation_created_at': invitationCreatedAt?.toIso8601String(),
    'site_place_id': sitePlaceId,
    'is_receiver_self': isReceiverSelf,
  };

  AccessPassModel copyWith({
    String? id,
    String? agenda,
    String? initialTrxCode,
    String? host,
    bool? isGroup,
    String? groupName,
    DateTime? visitorPeriodStart,
    DateTime? visitorPeriodEnd,
    String? visitorNumber,
    String? visitorCode,
    String? invitationCode,
    String? visitorStatus,
    String? sitePlaceName,
    String? hostName,
    String? parkingSlot,
    String? parkingArea,
    String? vehiclePlateNumber,
    String? vehicleType,
    bool? isDriving,
    String? tz,
    String? siteId,
    String? visitorName,
    bool? isPraregisterDone,
    String? visitorRole,
    String? approvalStatus,
    String? visitorTypeName,
    String? visitorTypeId,
    String? transactionVisitorId,
    String? invitedByName,
    String? invitedBy,
    String? hostOrganizationName,
    String? flow,
    String? visitorOrganizationName,
    String? visitorPhone,
    String? visitorEmail,
    String? visitorIdentityId,
    String? receiverName,
    String? receiverEmail,
    String? receiverPhone,
    String? groupCode,
    bool? canTrackBle,
    bool? canAccess,
    DateTime? invitationCreatedAt,
    String? sitePlaceId,
    bool? isReceiverSelf,
  }) {
    return AccessPassModel(
      id: id ?? this.id,
      agenda: agenda ?? this.agenda,
      initialTrxCode: initialTrxCode ?? this.initialTrxCode,
      host: host ?? this.host,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      visitorPeriodStart: visitorPeriodStart ?? this.visitorPeriodStart,
      visitorPeriodEnd: visitorPeriodEnd ?? this.visitorPeriodEnd,
      visitorNumber: visitorNumber ?? this.visitorNumber,
      visitorCode: visitorCode ?? this.visitorCode,
      invitationCode: invitationCode ?? this.invitationCode,
      visitorStatus: visitorStatus ?? this.visitorStatus,
      sitePlaceName: sitePlaceName ?? this.sitePlaceName,
      hostName: hostName ?? this.hostName,
      parkingSlot: parkingSlot ?? this.parkingSlot,
      parkingArea: parkingArea ?? this.parkingArea,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isDriving: isDriving ?? this.isDriving,
      tz: tz ?? this.tz,
      siteId: siteId ?? this.siteId,
      visitorName: visitorName ?? this.visitorName,
      isPraregisterDone: isPraregisterDone ?? this.isPraregisterDone,
      visitorRole: visitorRole ?? this.visitorRole,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      visitorTypeName: visitorTypeName ?? this.visitorTypeName,
      visitorTypeId: visitorTypeId ?? this.visitorTypeId,
      transactionVisitorId: transactionVisitorId ?? this.transactionVisitorId,
      invitedByName: invitedByName ?? this.invitedByName,
      invitedBy: invitedBy ?? this.invitedBy,
      hostOrganizationName: hostOrganizationName ?? this.hostOrganizationName,
      flow: flow ?? this.flow,
      visitorOrganizationName:
          visitorOrganizationName ?? this.visitorOrganizationName,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      visitorEmail: visitorEmail ?? this.visitorEmail,
      visitorIdentityId: visitorIdentityId ?? this.visitorIdentityId,
      receiverName: receiverName ?? this.receiverName,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      groupCode: groupCode ?? this.groupCode,
      canTrackBle: canTrackBle ?? this.canTrackBle,
      canAccess: canAccess ?? this.canAccess,
      invitationCreatedAt: invitationCreatedAt ?? this.invitationCreatedAt,
      sitePlaceId: sitePlaceId ?? this.sitePlaceId,
      isReceiverSelf: isReceiverSelf ?? this.isReceiverSelf,
    );
  }

  /// Parse a datetime string from the API as UTC and convert to device local time.
  /// The API may return strings without timezone suffix (e.g. "2026-05-04T04:04:00"),
  /// which Dart would incorrectly treat as local time. We force UTC by appending 'Z'
  /// if no timezone information is present.
  static DateTime _parseUtcToLocal(String s) {
    try {
      // If the string doesn't have timezone info (Z or +), assume UTC and append Z
      if (!s.contains('Z') && !s.contains('+')) {
        // Remove trailing milliseconds if present for cleaner parsing
        final clean = s.split('.').first;
        s = '${clean}Z';
      }
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}
