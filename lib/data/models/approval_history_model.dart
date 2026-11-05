import 'package:intl/intl.dart';

class ApprovalHistoryResponse {
  final String status;
  final int statusCode;
  final String msg;
  final ApprovalHistoryCollection? collection;

  ApprovalHistoryResponse({
    required this.status,
    required this.statusCode,
    required this.msg,
    this.collection,
  });

  factory ApprovalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ApprovalHistoryResponse(
      status: json['status']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code']?.toString() ?? '0') ?? 0,
      msg: json['msg']?.toString() ?? json['message']?.toString() ?? '',
      collection: json['collection'] != null && json['collection'] is Map<String, dynamic>
          ? ApprovalHistoryCollection.fromJson(json['collection'])
          : null,
    );
  }
}

class ApprovalHistoryCollection {
  final String ticketId;
  final String ticketName;
  final String ticketDescription;
  final String approvalWorkflowId;
  final String workflowName;
  final String entityId;
  final String entityType;
  final String approvalStatus;
  final int currentStep;
  final int totalSteps;
  final DateTime? createdAt;
  final String createdBy;
  final List<ApprovalTimelineStep> timeline;

  ApprovalHistoryCollection({
    required this.ticketId,
    required this.ticketName,
    required this.ticketDescription,
    required this.approvalWorkflowId,
    required this.workflowName,
    required this.entityId,
    required this.entityType,
    required this.approvalStatus,
    required this.currentStep,
    required this.totalSteps,
    this.createdAt,
    required this.createdBy,
    required this.timeline,
  });

  factory ApprovalHistoryCollection.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        String str = val.toString();
        if (!str.endsWith('Z') && !str.contains('+')) {
          str = '${str.replaceFirst(' ', 'T')}Z';
        }
        return DateTime.parse(str).toLocal();
      } catch (_) {
        return null;
      }
    }

    final rawTimeline = json['timeline'];
    List<ApprovalTimelineStep> steps = [];
    if (rawTimeline is List) {
      steps = rawTimeline
          .whereType<Map<String, dynamic>>()
          .map((e) => ApprovalTimelineStep.fromJson(e))
          .toList();
    }

    return ApprovalHistoryCollection(
      ticketId: json['ticket_id']?.toString() ?? '',
      ticketName: json['ticket_name']?.toString() ?? 'Approval Ticket',
      ticketDescription: json['ticket_description']?.toString() ?? '',
      approvalWorkflowId: json['approval_workflow_id']?.toString() ?? '',
      workflowName: json['workflow_name']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      entityType: json['entity_type']?.toString() ?? '',
      approvalStatus: json['approval_status']?.toString() ?? 'Pending',
      currentStep: int.tryParse(json['current_step']?.toString() ?? '0') ?? 0,
      totalSteps: int.tryParse(json['total_steps']?.toString() ?? '0') ?? 0,
      createdAt: parseDate(json['created_at']),
      createdBy: json['created_by']?.toString() ?? '-',
      timeline: steps,
    );
  }

  String get formattedCreatedAt {
    if (createdAt == null) return '-';
    return DateFormat('dd MMMM yyyy, HH:mm').format(createdAt!);
  }
}

class ApprovalTimelineStep {
  final int stepOrder;
  final String title;
  final String subtitle;
  final String description;
  final String status;
  final String action;
  final String logic;
  final DateTime? timestamp;
  final String timeDisplay;
  final bool isCurrentStep;
  final bool isFinal;
  final List<ApprovalActor> actors;

  ApprovalTimelineStep({
    required this.stepOrder,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.status,
    required this.action,
    required this.logic,
    this.timestamp,
    required this.timeDisplay,
    required this.isCurrentStep,
    required this.isFinal,
    required this.actors,
  });

  factory ApprovalTimelineStep.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        String str = val.toString();
        if (!str.endsWith('Z') && !str.contains('+')) {
          str = '${str.replaceFirst(' ', 'T')}Z';
        }
        return DateTime.parse(str).toLocal();
      } catch (_) {
        return null;
      }
    }

    final rawActors = json['actors'];
    List<ApprovalActor> actorList = [];
    if (rawActors is List) {
      actorList = rawActors
          .whereType<Map<String, dynamic>>()
          .map((e) => ApprovalActor.fromJson(e))
          .toList();
    }

    return ApprovalTimelineStep(
      stepOrder: int.tryParse(json['step_order']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'waiting',
      action: json['action']?.toString() ?? '',
      logic: json['logic']?.toString() ?? 'AND',
      timestamp: parseDate(json['timestamp']),
      timeDisplay: json['time_display']?.toString() ?? '',
      isCurrentStep: json['is_current_step'] == true,
      isFinal: json['is_final'] == true,
      actors: actorList,
    );
  }

  String get formattedTime {
    if (timestamp != null) {
      return DateFormat('dd MMMM yyyy, HH:mm').format(timestamp!);
    }
    if (timeDisplay.isNotEmpty) return timeDisplay;
    return '';
  }
}

class ApprovalActor {
  final String actorId;
  final String conditionId;
  final String approverUserId;
  final String fullname;
  final String email;
  final String username;
  final String approverType;
  final String approvalActorStatus;
  final bool isReviewer;
  final bool isFinal;
  final bool approvalActorReviewerStatus;
  final bool approvalActorFinalStatus;

  ApprovalActor({
    required this.actorId,
    required this.conditionId,
    required this.approverUserId,
    required this.fullname,
    required this.email,
    required this.username,
    required this.approverType,
    required this.approvalActorStatus,
    required this.isReviewer,
    required this.isFinal,
    required this.approvalActorReviewerStatus,
    required this.approvalActorFinalStatus,
  });

  factory ApprovalActor.fromJson(Map<String, dynamic> json) {
    return ApprovalActor(
      actorId: json['actor_id']?.toString() ?? '',
      conditionId: json['condition_id']?.toString() ?? '',
      approverUserId: json['approver_user_id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '-',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      approverType: json['approver_type']?.toString() ?? '',
      approvalActorStatus: json['approval_actor_status']?.toString() ?? 'Pending',
      isReviewer: json['is_reviewer'] == true,
      isFinal: json['is_final'] == true,
      approvalActorReviewerStatus: json['approval_actor_reviewer_status'] == true,
      approvalActorFinalStatus: json['approval_actor_final_status'] == true,
    );
  }
}

