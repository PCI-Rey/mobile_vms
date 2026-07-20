import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import '../invitation/controller/invitation_controller.dart';
import '../../../data/models/approval_ticket_model.dart';
import 'widgets/approve_detail_model.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Per-tab filter state redirected to persistent fields in the controller
  DateTime? get _pendingStartDate => controller.approvalPendingStartDate;
  set _pendingStartDate(DateTime? val) => controller.approvalPendingStartDate = val;

  DateTime? get _pendingEndDate => controller.approvalPendingEndDate;
  set _pendingEndDate(DateTime? val) => controller.approvalPendingEndDate = val;

  DateTime? get _approvedStartDate => controller.approvalApprovedStartDate;
  set _approvedStartDate(DateTime? val) => controller.approvalApprovedStartDate = val;

  DateTime? get _approvedEndDate => controller.approvalApprovedEndDate;
  set _approvedEndDate(DateTime? val) => controller.approvalApprovedEndDate = val;

  DateTime? get _rejectedStartDate => controller.approvalRejectedStartDate;
  set _rejectedStartDate(DateTime? val) => controller.approvalRejectedStartDate = val;

  DateTime? get _rejectedEndDate => controller.approvalRejectedEndDate;
  set _rejectedEndDate(DateTime? val) => controller.approvalRejectedEndDate = val;

  late final InvitationController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (Get.isRegistered<InvitationController>()) {
      controller = Get.find<InvitationController>();
    } else {
      controller = Get.put(InvitationController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchApprovalTickets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Filtered lists ────────────────────────────────────────────────────────

  List<ApprovalTicketModel> get _pendingTickets {
    List<ApprovalTicketModel> list = controller.approvalTickets.where((t) {
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
      final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
      final isRejected = actorStatus == 'rejected' ||
          actorStatus == 'denied' ||
          ticketStatus == 'rejected' ||
          ticketStatus == 'denied';
      final isPending = !isApproved && !isRejected;
      return isPending;
    }).toList();

    if (_pendingStartDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isBefore(
          DateTime(
            _pendingStartDate!.year,
            _pendingStartDate!.month,
            _pendingStartDate!.day,
          ),
        );
      }).toList();
    }

    if (_pendingEndDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isAfter(
          DateTime(
            _pendingEndDate!.year,
            _pendingEndDate!.month,
            _pendingEndDate!.day,
            23,
            59,
            59,
          ),
        );
      }).toList();
    }

    return list;
  }

  List<ApprovalTicketModel> get _approvedTickets {
    List<ApprovalTicketModel> list = controller.approvalTickets.where((t) {
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
      return actorStatus == 'approved' || ticketStatus == 'approved';
    }).toList();

    if (_approvedStartDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isBefore(
          DateTime(
            _approvedStartDate!.year,
            _approvedStartDate!.month,
            _approvedStartDate!.day,
          ),
        );
      }).toList();
    }

    if (_approvedEndDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isAfter(
          DateTime(
            _approvedEndDate!.year,
            _approvedEndDate!.month,
            _approvedEndDate!.day,
            23,
            59,
            59,
          ),
        );
      }).toList();
    }

    return list;
  }

  List<ApprovalTicketModel> get _rejectedTickets {
    List<ApprovalTicketModel> list = controller.approvalTickets.where((t) {
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
      return actorStatus == 'rejected' ||
          actorStatus == 'denied' ||
          ticketStatus == 'rejected' ||
          ticketStatus == 'denied';
    }).toList();

    if (_rejectedStartDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isBefore(
          DateTime(
            _rejectedStartDate!.year,
            _rejectedStartDate!.month,
            _rejectedStartDate!.day,
          ),
        );
      }).toList();
    }

    if (_rejectedEndDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isAfter(
          DateTime(
            _rejectedEndDate!.year,
            _rejectedEndDate!.month,
            _rejectedEndDate!.day,
            23,
            59,
            59,
          ),
        );
      }).toList();
    }

    return list;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Approval',
          style: TextStyle(
            fontSize: rfs(context, 22),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: rh(context, 1.0)),
        ),
      ),
      body: Column(
        children: [
          // ── Tab Bar ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary600,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: AppColors.primary600,
              indicatorWeight: 2.5,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: rfs(context, 18),
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: rfs(context, 18),
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),

          // ── Tab Views ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PendingTabView(
                  controller: controller,
                  startDate: _pendingStartDate,
                  endDate: _pendingEndDate,
                  pendingTickets: () => _pendingTickets,
                  onFilterTap: _openPendingFilter,
                  onClearDateFilter: () => setState(() {
                    _pendingStartDate = null;
                    _pendingEndDate = null;
                  }),
                  onConfirmAction: _confirmAction,
                  formatDateRange: _formatDateRange,
                ),
                _ApprovedTabView(
                  controller: controller,
                  startDate: _approvedStartDate,
                  endDate: _approvedEndDate,
                  approvedTickets: () => _approvedTickets,
                  onFilterTap: _openApprovedFilter,
                  onClearDateFilter: () => setState(() {
                    _approvedStartDate = null;
                    _approvedEndDate = null;
                  }),
                  onConfirmAction: _confirmAction,
                  formatDateRange: _formatDateRange,
                ),
                _RejectedTabView(
                  controller: controller,
                  startDate: _rejectedStartDate,
                  endDate: _rejectedEndDate,
                  rejectedTickets: () => _rejectedTickets,
                  onFilterTap: _openRejectedFilter,
                  onClearDateFilter: () => setState(() {
                    _rejectedStartDate = null;
                    _rejectedEndDate = null;
                  }),
                  formatDateRange: _formatDateRange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPendingFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 16)),
        ),
      ),
      builder: (context) => FilterBottomSheet(
        showSiteFilter: false,
        initialStartDate: _pendingStartDate,
        initialEndDate: _pendingEndDate,
      ),
    );

    if (result != null) {
      setState(() {
        _pendingStartDate = result['startDate'];
        _pendingEndDate = result['endDate'];
      });
    }
  }

  Future<void> _openApprovedFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 16)),
        ),
      ),
      builder: (context) => FilterBottomSheet(
        showSiteFilter: false,
        initialStartDate: _approvedStartDate,
        initialEndDate: _approvedEndDate,
      ),
    );

    if (result != null) {
      setState(() {
        _approvedStartDate = result['startDate'];
        _approvedEndDate = result['endDate'];
      });
    }
  }

  Future<void> _openRejectedFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 16)),
        ),
      ),
      builder: (context) => FilterBottomSheet(
        showSiteFilter: false,
        initialStartDate: _rejectedStartDate,
        initialEndDate: _rejectedEndDate,
      ),
    );

    if (result != null) {
      setState(() {
        _rejectedStartDate = result['startDate'];
        _rejectedEndDate = result['endDate'];
      });
    }
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await onConfirm();
            },
            child: const Text(
              'Yes, Reject',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final fmt = DateFormat('dd MMMM yyyy');
    if (start != null && end != null) {
      return '${fmt.format(start)} - ${fmt.format(end)}';
    } else if (start != null) {
      return 'Dari ${fmt.format(start)}';
    } else {
      return 'Sampai ${fmt.format(end!)}';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PENDING TAB
// ═══════════════════════════════════════════════════════════════════════════

class _PendingTabView extends StatelessWidget {
  const _PendingTabView({
    required this.controller,
    required this.startDate,
    required this.endDate,
    required this.pendingTickets,
    required this.onFilterTap,
    required this.onClearDateFilter,
    required this.onConfirmAction,
    required this.formatDateRange,
  });

  final InvitationController controller;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ApprovalTicketModel> Function() pendingTickets;
  final VoidCallback onFilterTap;
  final VoidCallback onClearDateFilter;
  final void Function(
    BuildContext, {
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
  })
  onConfirmAction;
  final String Function(DateTime?, DateTime?) formatDateRange;

  bool get _hasDateFilter => startDate != null || endDate != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ──────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rh(context, 12),
            bottom: rh(context, 6),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filter button
                GestureDetector(
                  onTap: onFilterTap,
                  child: const _FilterChip(label: 'Filter'),
                ),

                // Active date-range chip
                if (_hasDateFilter) ...[
                  hSpace(context, 8),
                  _FilterValueChip(
                    label: formatDateRange(startDate, endDate),
                    onClear: onClearDateFilter,
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── List ─────────────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (controller.isApprovalLoading.value &&
                controller.approvalTickets.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = pendingTickets();

            if (tickets.isEmpty) {
              return _EmptyState(
                onRefresh: controller.fetchApprovalTickets,
                message: 'Tidak ada approval yang pending',
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchApprovalTickets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ListHeader(count: tickets.length, label: 'Pending'),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        rw(context, 16),
                        rh(context, 8),
                        rw(context, 16),
                        rh(context, 24),
                      ),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: rh(context, 12)),
                        child: _ApprovalCard(
                          ticket: tickets[index],
                          index: index,
                          onConfirmAction: onConfirmAction,
                          controller: controller,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// APPROVED TAB  (no filter)
// ═══════════════════════════════════════════════════════════════════════════

class _ApprovedTabView extends StatelessWidget {
  const _ApprovedTabView({
    required this.controller,
    required this.startDate,
    required this.endDate,
    required this.approvedTickets,
    required this.onFilterTap,
    required this.onClearDateFilter,
    required this.onConfirmAction,
    required this.formatDateRange,
  });

  final InvitationController controller;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ApprovalTicketModel> Function() approvedTickets;
  final VoidCallback onFilterTap;
  final VoidCallback onClearDateFilter;
  final void Function(
    BuildContext, {
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
  })
  onConfirmAction;
  final String Function(DateTime?, DateTime?) formatDateRange;

  bool get _hasDateFilter => startDate != null || endDate != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rh(context, 12),
            bottom: rh(context, 6),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onFilterTap,
                  child: const _FilterChip(label: 'Filter'),
                ),
                if (_hasDateFilter) ...[
                  hSpace(context, 8),
                  _FilterValueChip(
                    label: formatDateRange(startDate, endDate),
                    onClear: onClearDateFilter,
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── List ────────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (controller.isApprovalLoading.value &&
                controller.approvalTickets.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = approvedTickets();

            if (tickets.isEmpty) {
              return _EmptyState(
                onRefresh: controller.fetchApprovalTickets,
                message: 'Belum ada approval yang disetujui',
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchApprovalTickets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ListHeader(count: tickets.length, label: 'Approved'),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        rw(context, 16),
                        rh(context, 8),
                        rw(context, 16),
                        rh(context, 24),
                      ),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: rh(context, 12)),
                        child: _ApprovalCard(
                          ticket: tickets[index],
                          index: index,
                          onConfirmAction: onConfirmAction,
                          controller: controller,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REJECTED TAB
// ═══════════════════════════════════════════════════════════════════════════

class _RejectedTabView extends StatelessWidget {
  const _RejectedTabView({
    required this.controller,
    required this.startDate,
    required this.endDate,
    required this.rejectedTickets,
    required this.onFilterTap,
    required this.onClearDateFilter,
    required this.formatDateRange,
  });

  final InvitationController controller;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ApprovalTicketModel> Function() rejectedTickets;
  final VoidCallback onFilterTap;
  final VoidCallback onClearDateFilter;
  final String Function(DateTime?, DateTime?) formatDateRange;

  bool get _hasDateFilter => startDate != null || endDate != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rh(context, 12),
            bottom: rh(context, 6),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onFilterTap,
                  child: const _FilterChip(label: 'Filter'),
                ),
                if (_hasDateFilter) ...[
                  hSpace(context, 8),
                  _FilterValueChip(
                    label: formatDateRange(startDate, endDate),
                    onClear: onClearDateFilter,
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── List ────────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (controller.isApprovalLoading.value &&
                controller.approvalTickets.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = rejectedTickets();

            if (tickets.isEmpty) {
              return _EmptyState(
                onRefresh: controller.fetchApprovalTickets,
                message: 'Tidak ada approval yang ditolak',
                icon: Icons.cancel_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchApprovalTickets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ListHeader(count: tickets.length, label: 'Rejected'),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        rw(context, 16),
                        rh(context, 8),
                        rw(context, 16),
                        rh(context, 24),
                      ),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: rh(context, 12)),
                        child: _RejectedCard(
                          ticket: tickets[index],
                          index: index,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeFg;
    Color borderColor;

    final lbl = label.toLowerCase();
    if (lbl.contains('pending')) {
      badgeBg = const Color(0xFFFFF3E0);
      badgeFg = const Color(0xFFE65100);
      borderColor = const Color(0xFFFFB74D);
    } else if (lbl.contains('approved') || lbl.contains('approve')) {
      badgeBg = const Color(0xFFE8F5E9);
      badgeFg = const Color(0xFF2E7D32);
      borderColor = const Color(0xFF81C784);
    } else {
      badgeBg = const Color(0xFFFFEBEE);
      badgeFg = const Color(0xFFC62828);
      borderColor = const Color(0xFFE57373);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        rw(context, 20),
        rh(context, 6),
        rw(context, 20),
        rh(context, 4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'List Approval',
            style: TextStyle(
              fontSize: rfs(context, 18),
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 10),
              vertical: rh(context, 3),
            ),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(rw(context, 20)),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              '$count $label',
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: FontWeight.w600,
                color: badgeFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onRefresh,
    required this.message,
    this.icon = Icons.fact_check_outlined,
  });
  final Future<void> Function() onRefresh;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: rw(context, 64), color: Colors.grey.shade300),
                vSpace(context, 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: rfs(context, 15),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                vSpace(context, 8),
                Text(
                  'Tarik ke bawah untuk memperbarui',
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: rh(context, 32),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: rfs(context, 12), color: Colors.black87),
          ),
          hSpace(context, 6),
          FaIcon(
            FontAwesomeIcons.chevronDown,
            size: rw(context, 11),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _FilterValueChip extends StatelessWidget {
  const _FilterValueChip({required this.label, required this.onClear});
  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: rh(context, 32),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 10)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.trim(),
            style: TextStyle(fontSize: rfs(context, 12), color: Colors.black87),
          ),
          hSpace(context, 6),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(rw(context, 10)),
            child: Padding(
              padding: EdgeInsets.all(rw(context, 2)),
              child: Icon(
                Icons.close,
                size: rw(context, 14),
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// APPROVAL CARD
// ═══════════════════════════════════════════════════════════════════════════

// ─── _buildCardField helper ──────────────────────────────────────────────────
Widget _buildCardField(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  Color? color,
  Widget? trailing,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, size: rw(context, 12), color: Colors.grey.shade400),
      hSpace(context, 5),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 12),
                color: Colors.grey.shade500,
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: rfs(context, 10),
                      fontWeight: FontWeight.w600,
                      color: color ?? Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (trailing != null) ...[hSpace(context, 4), trailing],
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// APPROVAL CARD
// ═══════════════════════════════════════════════════════════════════════════

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.ticket,
    required this.index,
    required this.onConfirmAction,
    required this.controller,
  });

  final ApprovalTicketModel ticket;
  final int index;
  final InvitationController controller;
  final void Function(
    BuildContext, {
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
  })
  onConfirmAction;

  @override
  Widget build(BuildContext context) {
    final actorStatus = (ticket.approvalActorStatus ?? '').toLowerCase();
    final ticketStatus = (ticket.approvalStatus ?? '').toLowerCase();

    final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
    final isRejected = actorStatus == 'rejected' ||
        actorStatus == 'denied' ||
        ticketStatus == 'rejected' ||
        ticketStatus == 'denied';
    final isPending = !isApproved && !isRejected;

    final decisionDate = ticket.approvedAt ?? ticket.approvalTicketAt;

    Color statusBg;
    Color statusFg;
    bool hasBorder = true;
    String statusText = 'Pending';

    if (isApproved) {
      statusBg = const Color(0xFF43A047);
      statusFg = Colors.white;
      hasBorder = false;
      statusText = 'Approved';
    } else if (isRejected) {
      statusBg = const Color(0xFFE53935);
      statusFg = Colors.white;
      hasBorder = false;
      statusText = 'Rejected';
    } else {
      statusBg = const Color(0xFFFFF3E0);
      statusFg = const Color(0xFFE65100);
      hasBorder = true;
      statusText = 'Pending';
    }

    final start = ticket.visitorPeriodStart;
    final end = ticket.visitorPeriodEnd;
    final startStr = start != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(start)
        : '-';
    final endStr = end != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(end)
        : '-';

    return GestureDetector(
      onTap: () => ApprovalDetailModal.show(context, ticket),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: rw(context, 10),
              offset: Offset(0, rh(context, 3)),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Number circle + Agenda (title) + Status badge
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 16),
                bottom: rh(context, 12),
              ),
              child: Row(
                children: [
                  Container(
                    width: rw(context, 26),
                    height: rw(context, 26),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF005596),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  hSpace(context, 10),
                  Expanded(
                    child: Text(
                      ticket.agenda ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: rfs(context, 16),
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  hSpace(context, 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 8),
                      vertical: rh(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                      border: hasBorder
                          ? Border.all(color: statusFg.withValues(alpha: 0.4))
                          : null,
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

            // Body: Info grid fields
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 12),
                bottom: rh(context, 16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.badge_outlined,
                          'Visitor Type',
                          ticket.visitorTypeName == null ||
                                  ticket.visitorTypeName!.isEmpty
                              ? '-'
                              : ticket.visitorTypeName!,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.person_outline,
                          'Host',
                          ticket.hostName == null || ticket.hostName!.isEmpty
                              ? '-'
                              : ticket.hostName!,
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.business_outlined,
                          'Organization',
                          ticket.hostOrganizationName == null ||
                                  ticket.hostOrganizationName!.isEmpty
                              ? '-'
                              : ticket.hostOrganizationName!,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.timeline,
                          'Flow',
                          ticket.flow == null || ticket.flow!.isEmpty
                              ? '-'
                              : ticket.flow!,
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.login_outlined,
                          'Period Start',
                          startStr,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.logout_outlined,
                          'Period End',
                          endStr,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer action buttons
            if (isPending) ...[
              Container(height: 1, color: const Color(0xFFF0F0F0)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 12),
                  vertical: rh(context, 10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onConfirmAction(
                          context,
                          title: 'Reject Approval',
                          message:
                              'Are you sure you want to reject this approval?',
                          onConfirm: () => controller.rejectMeetingHostAction(
                            approvalTicketId:
                                ticket.approvalTicketId ??
                                ticket.ticketId ??
                                '',
                            actorId: ticket.actorId ?? '',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: rh(context, 9),
                          ),
                          side: const BorderSide(color: Color(0xFFD32F2F)),
                          foregroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 8)),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    hSpace(context, 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => VisitorApprovalDialog.show(
                          context,
                          ticket,
                          controller,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: rh(context, 9),
                          ),
                          backgroundColor: AppColors.primary500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 8)),
                          ),
                        ),
                        child: Text(
                          'Approve',
                          style: TextStyle(
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isApproved && decisionDate != null) ...[
              Container(height: 1, color: const Color(0xFFF0F0F0)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 16),
                  rh(context, 8),
                  rw(context, 16),
                  rh(context, 10),
                ),
                child: Text(
                  'Disetujui: ${DateFormat('dd MMMM yyyy, HH:mm').format(decisionDate)}',
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REJECTED CARD
// ═══════════════════════════════════════════════════════════════════════════

class _RejectedCard extends StatelessWidget {
  const _RejectedCard({required this.ticket, required this.index});

  final ApprovalTicketModel ticket;
  final int index;

  @override
  Widget build(BuildContext context) {
    final actorStatus = (ticket.approvalActorStatus ?? '').toLowerCase();
    final ticketStatus = (ticket.approvalStatus ?? '').toLowerCase();

    final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
    final isRejected = actorStatus == 'rejected' ||
        actorStatus == 'denied' ||
        ticketStatus == 'rejected' ||
        ticketStatus == 'denied';
    final isPending = !isApproved && !isRejected;

    final decisionDate = ticket.approvedAt ?? ticket.approvalTicketAt;

    Color statusBg = const Color(0xFFE53935);
    Color statusFg = Colors.white;
    bool isPendingState = false;
    String statusText = 'Rejected';

    if (isApproved) {
      statusBg = const Color(0xFF43A047);
      statusText = 'Approved';
    } else if (isPending) {
      statusBg = const Color(0xFFFFF3E0);
      statusFg = const Color(0xFFE65100);
      statusText = 'Pending';
      isPendingState = true;
    } else {
      statusBg = const Color(0xFFE53935);
      statusText = 'Rejected';
    }

    final start = ticket.visitorPeriodStart;
    final end = ticket.visitorPeriodEnd;
    final startStr = start != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(start)
        : '-';
    final endStr = end != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(end)
        : '-';

    return GestureDetector(
      onTap: () => ApprovalDetailModal.show(context, ticket),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: rw(context, 10),
              offset: Offset(0, rh(context, 3)),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Number circle + Agenda (title) + Status badge
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 16),
                bottom: rh(context, 12),
              ),
              child: Row(
                children: [
                  Container(
                    width: rw(context, 26),
                    height: rw(context, 26),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF005596),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  hSpace(context, 10),
                  Expanded(
                    child: Text(
                      ticket.agenda ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: rfs(context, 16),
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  hSpace(context, 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 8),
                      vertical: rh(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                      border: isPendingState
                          ? Border.all(color: statusFg.withValues(alpha: 0.4))
                          : null,
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

            // Body: Info grid fields
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 12),
                bottom: rh(context, 16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.badge_outlined,
                          'Visitor Type',
                          ticket.visitorTypeName == null ||
                                  ticket.visitorTypeName!.isEmpty
                              ? '-'
                              : ticket.visitorTypeName!,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.person_outline,
                          'Host',
                          ticket.hostName == null || ticket.hostName!.isEmpty
                              ? '-'
                              : ticket.hostName!,
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.business_outlined,
                          'Organization',
                          ticket.hostOrganizationName == null ||
                                  ticket.hostOrganizationName!.isEmpty
                              ? '-'
                              : ticket.hostOrganizationName!,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.timeline,
                          'Flow',
                          ticket.flow == null || ticket.flow!.isEmpty
                              ? '-'
                              : ticket.flow!,
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.login_outlined,
                          'Period Start',
                          startStr,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.logout_outlined,
                          'Period End',
                          endStr,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (decisionDate != null) ...[
              Container(height: 1, color: const Color(0xFFF0F0F0)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 16),
                  rh(context, 8),
                  rw(context, 16),
                  rh(context, 10),
                ),
                child: Text(
                  'Ditolak: ${DateFormat('dd MMMM yyyy, HH:mm').format(decisionDate)}',
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    color: const Color(0xFFC62828),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VisitorApprovalDialog extends StatefulWidget {
  const VisitorApprovalDialog({super.key, required this.ticket, required this.controller});

  final ApprovalTicketModel ticket;
  final InvitationController controller;

  static Future<void> show(
    BuildContext context,
    ApprovalTicketModel ticket,
    InvitationController controller,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          VisitorApprovalDialog(ticket: ticket, controller: controller),
    );
  }

  @override
  State<VisitorApprovalDialog> createState() => _VisitorApprovalDialogState();
}

class _VisitorApprovalDialogState extends State<VisitorApprovalDialog> {
  List<Map<String, dynamic>> _visitors = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchVisitors();
  }

  Future<void> _fetchVisitors() async {
    final entityId = widget.ticket.entityId;
    if (entityId == null || entityId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'ID Transaksi tidak ditemukan.';
      });
      return;
    }
    try {
      final result = await widget.controller.fetchTransactionVisitors(entityId);
      if (mounted) {
        setState(() {
          _visitors = result;
          for (final v in result) {
            final id = v['id']?.toString();
            if (id != null) {
              _selectedIds.add(id);
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Gagal memuat data visitor.';
        });
      }
    }
  }

  void _toggleAll(bool? checked) {
    setState(() {
      if (checked == true) {
        for (final v in _visitors) {
          final id = v['id']?.toString();
          if (id != null) {
            _selectedIds.add(id);
          }
        }
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedIds.isEmpty) {
      Get.snackbar(
        'Warning',
        'Pilih minimal satu visitor untuk disetujui.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.controller.approveMeetingHostAndTicketsAction(
        approvalTicketId:
            widget.ticket.approvalTicketId ?? widget.ticket.ticketId ?? '',
        actorId: widget.ticket.actorId ?? '',
        listTrxVisitorId: _selectedIds.toList(),
      );
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.of(context).pop(); // close dialog
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allChecked =
        _visitors.isNotEmpty && _selectedIds.length == _visitors.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rw(context, 16)),
      ),
      title: Text(
        'Pilih Visitor untuk Disetujui',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: rfs(context, 16),
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
      content: SizedBox(
        width: rw(context, 320),
        height: rh(context, 300),
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: rfs(context, 13),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : _visitors.isEmpty
            ? Center(
                child: Text(
                  'Tidak ada visitor ditemukan.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: rfs(context, 13),
                  ),
                ),
              )
            : Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      'Pilih Semua',
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    value: allChecked,
                    onChanged: _toggleAll,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary500,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _visitors.length,
                      itemBuilder: (context, index) {
                        final v = _visitors[index];
                        final name =
                            v['visitor_name']?.toString() ??
                            v['name']?.toString() ??
                            '-';
                        final id = v['id']?.toString() ?? '';
                        final company =
                            v['visitor_company']?.toString() ??
                            v['company']?.toString() ??
                            '';
                        final isChecked = _selectedIds.contains(id);

                        return CheckboxListTile(
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: rfs(context, 13),
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: company.isNotEmpty
                              ? Text(
                                  company,
                                  style: TextStyle(
                                    fontSize: rfs(context, 11),
                                    color: Colors.grey.shade500,
                                  ),
                                )
                              : null,
                          value: isChecked,
                          onChanged: (_) => _toggleItem(id),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary500,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Batal',
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isSubmitting || _isLoading || _error != null || _visitors.isEmpty
              ? null
              : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary500,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rw(context, 8)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 16),
              vertical: rh(context, 8),
            ),
            elevation: 0,
          ),
          child: Text(
            'Approve',
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
