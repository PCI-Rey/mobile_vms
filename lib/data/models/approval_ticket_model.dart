class ApprovalTicketModel {
  final String? agenda;
  final String? hostName;
  final String? hostOrganizationName;
  final String? visitorTypeName;
  final DateTime? visitorPeriodStart;
  final DateTime? visitorPeriodEnd;
  final String? transactionStatus;
  final String? flow;
  final String? actorId;
  final String? approvalTicketId;
  final String? approvalActorStatus;
  final DateTime? approvedAt;
  final String? approvalWorkflowId;
  final String? approverUserId;
  final String? ticketId;
  final String? entityId;
  final String? approvalWorkflowType;
  final String? approvalStatus;
  final int? currentStep;
  final DateTime? approvalTicketAt;
  final String? siteId;
  final String? siteName;
  final bool? needApproval;

  ApprovalTicketModel({
    this.agenda,
    this.hostName,
    this.hostOrganizationName,
    this.visitorTypeName,
    this.visitorPeriodStart,
    this.visitorPeriodEnd,
    this.transactionStatus,
    this.flow,
    this.actorId,
    this.approvalTicketId,
    this.approvalActorStatus,
    this.approvedAt,
    this.approvalWorkflowId,
    this.approverUserId,
    this.ticketId,
    this.entityId,
    this.approvalWorkflowType,
    this.approvalStatus,
    this.currentStep,
    this.approvalTicketAt,
    this.siteId,
    this.siteName,
    this.needApproval,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      String s = value.toString();
      if (!s.contains('Z') && !s.contains('+')) {
        final clean = s.split('.').first;
        s = '${clean}Z';
      }
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return DateTime.tryParse(value.toString());
    }
  }

  factory ApprovalTicketModel.fromJson(Map<String, dynamic> json) {
    return ApprovalTicketModel(
      agenda: json['agenda']?.toString(),
      hostName: json['host_name']?.toString(),
      hostOrganizationName: json['host_organization_name']?.toString(),
      visitorTypeName: json['visitor_type_name']?.toString(),
      visitorPeriodStart: _parseDateTime(
        json['visitor_period_start'] ??
        json['visit_start'] ??
        json['start_date'] ??
        json['visit_date']
      ),
      visitorPeriodEnd: _parseDateTime(
        json['visitor_period_end'] ??
        json['visit_end'] ??
        json['end_date']
      ),
      transactionStatus: json['transaction_status']?.toString(),
      flow: json['flow']?.toString(),
      actorId: json['actor_id']?.toString(),
      approvalTicketId: json['approval_ticket_id']?.toString(),
      approvalActorStatus: json['approval_actor_status']?.toString(),
      approvedAt: _parseDateTime(json['approved_at']),
      approvalWorkflowId: json['approval_workflow_id']?.toString(),
      approverUserId: json['approver_user_id']?.toString(),
      ticketId: json['ticket_id']?.toString(),
      entityId: json['entity_id']?.toString(),
      approvalWorkflowType: json['approval_workflow_type']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step'] as int
          : int.tryParse(json['current_step']?.toString() ?? ''),
      approvalTicketAt: _parseDateTime(json['approval_ticket_at']),
      siteId: json['site_id']?.toString(),
      siteName: json['site_name']?.toString() ?? json['site']?.toString(),
      needApproval: json['need_approval'] is bool
          ? json['need_approval'] as bool
          : (json['need_approval'] != null
              ? json['need_approval'].toString().toLowerCase() == 'true'
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agenda': agenda,
      'host_name': hostName,
      'host_organization_name': hostOrganizationName,
      'visitor_type_name': visitorTypeName,
      'visitor_period_start': visitorPeriodStart?.toIso8601String(),
      'visitor_period_end': visitorPeriodEnd?.toIso8601String(),
      'transaction_status': transactionStatus,
      'flow': flow,
      'actor_id': actorId,
      'approval_ticket_id': approvalTicketId,
      'approval_actor_status': approvalActorStatus,
      'approved_at': approvedAt?.toIso8601String(),
      'approval_workflow_id': approvalWorkflowId,
      'approver_user_id': approverUserId,
      'ticket_id': ticketId,
      'entity_id': entityId,
      'approval_workflow_type': approvalWorkflowType,
      'approval_status': approvalStatus,
      'current_step': currentStep,
      'approval_ticket_at': approvalTicketAt?.toIso8601String(),
      'site_id': siteId,
      'site_name': siteName,
      'need_approval': needApproval,
    };
  }
}
