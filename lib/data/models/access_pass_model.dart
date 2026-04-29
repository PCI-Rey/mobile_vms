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
  final bool isDriving;
  final String tz;

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
    required this.isDriving,
    required this.tz,
  });

  factory AccessPassModel.fromRawJson(String str) => AccessPassModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AccessPassModel.fromJson(Map<String, dynamic> json) {
    return AccessPassModel(
      id: json['id']?.toString() ?? '',
      agenda: json['agenda']?.toString() ?? '',
      initialTrxCode: json['initial_trx_code']?.toString() ?? '',
      host: json['host']?.toString() ?? '',
      isGroup: json['is_group'] == true,
      groupName: json['group_name']?.toString() ?? '',
      visitorPeriodStart: json['visitor_period_start'] != null
          ? DateTime.parse(json['visitor_period_start'].toString())
          : DateTime.now(),
      visitorPeriodEnd: json['visitor_period_end'] != null
          ? DateTime.parse(json['visitor_period_end'].toString())
          : DateTime.now(),
      visitorNumber: json['visitor_number']?.toString() ?? '',
      visitorCode: json['visitor_code']?.toString() ?? '',
      invitationCode: json['invitation_code']?.toString() ?? '',
      visitorStatus: json['visitor_status']?.toString() ?? '',
      sitePlaceName: json['site_place_name']?.toString() ?? '',
      hostName: json['host_name']?.toString() ?? '',
      parkingSlot: json['parking_slot']?.toString() ?? '',
      parkingArea: json['parking_area']?.toString() ?? '',
      vehiclePlateNumber: json['vehicle_plate_number']?.toString() ?? '',
      isDriving: json['is_driving'] == true,
      tz: json['tz']?.toString() ?? '',
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
        'is_driving': isDriving,
        'tz': tz,
      };
}
