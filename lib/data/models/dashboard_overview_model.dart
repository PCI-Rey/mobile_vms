class DashboardMetadata {
  final String periodLabel;
  final String startDate;
  final String endDate;
  final String generatedAt;
  final String generatedBy;
  final String roleAccess;

  DashboardMetadata({
    this.periodLabel = '',
    this.startDate = '',
    this.endDate = '',
    this.generatedAt = '',
    this.generatedBy = '',
    this.roleAccess = '',
  });

  factory DashboardMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardMetadata();
    return DashboardMetadata(
      periodLabel: json['period_label']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      generatedAt: json['generated_at']?.toString() ?? '',
      generatedBy: json['generated_by']?.toString() ?? '',
      roleAccess: json['role_access']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'period_label': periodLabel,
    'start_date': startDate,
    'end_date': endDate,
    'generated_at': generatedAt,
    'generated_by': generatedBy,
    'role_access': roleAccess,
  };
}

class DashboardKpiSummary {
  final int totalPendingApproval;
  final int totalApprovedApproval;
  final int totalRejectedApproval;
  final int totalActiveVisitor;
  final int totalExpiredVisitor;
  final int totalMySchedule;
  final int totalInvitedGuest;
  final int totalInvitedCheckout;
  final int totalInvitedCheckin;
  final int totalInvitedNoShow;
  final int totalInvitedStillOnSite;
  final int totalAlarm;
  final int totalActivity;
  final int totalOverall;

  DashboardKpiSummary({
    this.totalPendingApproval = 0,
    this.totalApprovedApproval = 0,
    this.totalRejectedApproval = 0,
    this.totalActiveVisitor = 0,
    this.totalExpiredVisitor = 0,
    this.totalMySchedule = 0,
    this.totalInvitedGuest = 0,
    this.totalInvitedCheckout = 0,
    this.totalInvitedCheckin = 0,
    this.totalInvitedNoShow = 0,
    this.totalInvitedStillOnSite = 0,
    this.totalAlarm = 0,
    this.totalActivity = 0,
    this.totalOverall = 0,
  });

  factory DashboardKpiSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardKpiSummary();
    int parse(String key) => int.tryParse(json[key]?.toString() ?? '0') ?? 0;

    return DashboardKpiSummary(
      totalPendingApproval: parse('total_pending_approval'),
      totalApprovedApproval: parse('total_approved_approval'),
      totalRejectedApproval: parse('total_rejected_approval'),
      totalActiveVisitor: parse('total_active_visitor'),
      totalExpiredVisitor: parse('total_expired_visitor'),
      totalMySchedule: parse('total_my_schedule'),
      totalInvitedGuest: parse('total_invited_guest'),
      totalInvitedCheckout: parse('total_invited_checkout'),
      totalInvitedCheckin: parse('total_invited_checkin'),
      totalInvitedNoShow: parse('total_invited_no_show'),
      totalInvitedStillOnSite: parse('total_invited_still_on_site'),
      totalAlarm: parse('total_alarm'),
      totalActivity: parse('total_activity'),
      totalOverall: parse('total_overall'),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_pending_approval': totalPendingApproval,
    'total_approved_approval': totalApprovedApproval,
    'total_rejected_approval': totalRejectedApproval,
    'total_active_visitor': totalActiveVisitor,
    'total_expired_visitor': totalExpiredVisitor,
    'total_my_schedule': totalMySchedule,
    'total_invited_guest': totalInvitedGuest,
    'total_invited_checkout': totalInvitedCheckout,
    'total_invited_checkin': totalInvitedCheckin,
    'total_invited_no_show': totalInvitedNoShow,
    'total_invited_still_on_site': totalInvitedStillOnSite,
    'total_alarm': totalAlarm,
    'total_activity': totalActivity,
    'total_overall': totalOverall,
  };
}

class DashboardCategoryComparisonChart {
  final List<String> labels;
  final List<num> series;

  DashboardCategoryComparisonChart({
    this.labels = const [],
    this.series = const [],
  });

  factory DashboardCategoryComparisonChart.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardCategoryComparisonChart();
    return DashboardCategoryComparisonChart(
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      series: (json['series'] as List<dynamic>?)
              ?.map((e) => num.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'labels': labels,
    'series': series,
  };
}

class DashboardActivityTrendChart {
  final List<String> categories;
  final List<Map<String, dynamic>> series;

  DashboardActivityTrendChart({
    this.categories = const [],
    this.series = const [],
  });

  factory DashboardActivityTrendChart.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardActivityTrendChart();
    return DashboardActivityTrendChart(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      series: (json['series'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'categories': categories,
    'series': series,
  };
}

class DashboardCharts {
  final DashboardCategoryComparisonChart categoryComparison;
  final DashboardActivityTrendChart activityTrend;
  final Map<String, dynamic> alarmBySection;
  final Map<String, dynamic> visitorStatusDistribution;

  DashboardCharts({
    required this.categoryComparison,
    required this.activityTrend,
    this.alarmBySection = const {},
    this.visitorStatusDistribution = const {},
  });

  factory DashboardCharts.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardCharts(
        categoryComparison: DashboardCategoryComparisonChart(),
        activityTrend: DashboardActivityTrendChart(),
      );
    }
    return DashboardCharts(
      categoryComparison: DashboardCategoryComparisonChart.fromJson(
        json['category_comparison'] as Map<String, dynamic>?,
      ),
      activityTrend: DashboardActivityTrendChart.fromJson(
        json['activity_trend'] as Map<String, dynamic>?,
      ),
      alarmBySection: json['alarm_by_section'] is Map
          ? Map<String, dynamic>.from(json['alarm_by_section'] as Map)
          : {},
      visitorStatusDistribution: json['visitor_status_distribution'] is Map
          ? Map<String, dynamic>.from(json['visitor_status_distribution'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() => {
    'category_comparison': categoryComparison.toJson(),
    'activity_trend': activityTrend.toJson(),
    'alarm_by_section': alarmBySection,
    'visitor_status_distribution': visitorStatusDistribution,
  };
}

class DashboardDetails {
  final List<Map<String, dynamic>> pendingApprovals;
  final List<Map<String, dynamic>> approvedApprovals;
  final List<Map<String, dynamic>> rejectedApprovals;
  final List<Map<String, dynamic>> activeVisitors;
  final List<Map<String, dynamic>> expiredVisitors;
  final List<Map<String, dynamic>> mySchedule;
  final List<Map<String, dynamic>> invitedGuests;
  final List<dynamic> alarms;
  final Map<String, dynamic> alarmsBySection;
  final List<dynamic> activities;

  DashboardDetails({
    this.pendingApprovals = const [],
    this.approvedApprovals = const [],
    this.rejectedApprovals = const [],
    this.activeVisitors = const [],
    this.expiredVisitors = const [],
    this.mySchedule = const [],
    this.invitedGuests = const [],
    this.alarms = const [],
    this.alarmsBySection = const {},
    this.activities = const [],
  });

  factory DashboardDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardDetails();

    List<Map<String, dynamic>> parseList(String key) {
      final val = json[key];
      if (val is List) {
        return val.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }

    return DashboardDetails(
      pendingApprovals: parseList('pending_approvals'),
      approvedApprovals: parseList('approved_approvals'),
      rejectedApprovals: parseList('rejected_approvals'),
      activeVisitors: parseList('active_visitors'),
      expiredVisitors: parseList('expired_visitors'),
      mySchedule: parseList('my_schedule'),
      invitedGuests: parseList('invited_guests'),
      alarms: json['alarms'] is List ? (json['alarms'] as List) : [],
      alarmsBySection: json['alarms_by_section'] is Map
          ? Map<String, dynamic>.from(json['alarms_by_section'] as Map)
          : {},
      activities: json['activities'] is List ? (json['activities'] as List) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'pending_approvals': pendingApprovals,
    'approved_approvals': approvedApprovals,
    'rejected_approvals': rejectedApprovals,
    'active_visitors': activeVisitors,
    'expired_visitors': expiredVisitors,
    'my_schedule': mySchedule,
    'invited_guests': invitedGuests,
    'alarms': alarms,
    'alarms_by_section': alarmsBySection,
    'activities': activities,
  };
}

class DashboardOverviewModel {
  final String status;
  final int statusCode;
  final String title;
  final String msg;
  final DashboardMetadata metadata;
  final DashboardKpiSummary kpiSummary;
  final DashboardCharts charts;
  final DashboardDetails details;
  final Map<String, dynamic> rawCollection;

  DashboardOverviewModel({
    this.status = '',
    this.statusCode = 0,
    this.title = '',
    this.msg = '',
    required this.metadata,
    required this.kpiSummary,
    required this.charts,
    required this.details,
    this.rawCollection = const {},
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    final collection = json['collection'] is Map<String, dynamic>
        ? json['collection'] as Map<String, dynamic>
        : (json['collection'] is Map
            ? Map<String, dynamic>.from(json['collection'] as Map)
            : <String, dynamic>{});

    return DashboardOverviewModel(
      status: json['status']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      metadata: DashboardMetadata.fromJson(
        collection['metadata'] as Map<String, dynamic>?,
      ),
      kpiSummary: DashboardKpiSummary.fromJson(
        collection['kpi_summary'] as Map<String, dynamic>?,
      ),
      charts: DashboardCharts.fromJson(
        collection['charts'] as Map<String, dynamic>?,
      ),
      details: DashboardDetails.fromJson(
        collection['details'] as Map<String, dynamic>?,
      ),
      rawCollection: collection,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'status_code': statusCode,
    'title': title,
    'msg': msg,
    'collection': rawCollection.isNotEmpty
        ? rawCollection
        : {
            'metadata': metadata.toJson(),
            'kpi_summary': kpiSummary.toJson(),
            'charts': charts.toJson(),
            'details': details.toJson(),
          },
  };
}
