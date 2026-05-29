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

  // Per-tab filter state
  DateTime? _pendingStartDate;
  DateTime? _pendingEndDate;
  DateTime? _approvedStartDate;
  DateTime? _approvedEndDate;
  DateTime? _rejectedStartDate;
  DateTime? _rejectedEndDate;

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
    List<ApprovalTicketModel> list = controller.approvalTickets
        .where((t) => (t.approvalActorStatus ?? '').toLowerCase() == 'pending')
        .toList();

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
    List<ApprovalTicketModel> list = controller.approvalTickets
        .where((t) => (t.approvalActorStatus ?? '').toLowerCase() == 'approved')
        .toList();

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
    List<ApprovalTicketModel> list = controller.approvalTickets
        .where((t) =>
            (t.approvalActorStatus ?? '').toLowerCase() == 'rejected' ||
            (t.approvalActorStatus ?? '').toLowerCase() == 'reject')
        .toList();

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
            fontSize: rfs(context, 20),
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
              labelStyle: TextStyle(
                fontSize: rfs(context, 14),
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: rfs(context, 14),
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
      builder: (context) => const FilterBottomSheet(),
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
      builder: (context) => const FilterBottomSheet(),
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
      builder: (context) => const FilterBottomSheet(),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: rfs(context, 16),
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rw(context, 8)),
              ),
            ),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final fmt = DateFormat('dd/MM/yy');
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
          padding: EdgeInsets.symmetric(
            horizontal: rw(context, 20),
            vertical: rh(context, 10),
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
        Container(height: 1, color: const Color(0xFFF0F0F0)),

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
          padding: EdgeInsets.symmetric(
            horizontal: rw(context, 20),
            vertical: rh(context, 10),
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
        Container(height: 1, color: const Color(0xFFF0F0F0)),

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
          padding: EdgeInsets.symmetric(
            horizontal: rw(context, 20),
            vertical: rh(context, 10),
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
        Container(height: 1, color: const Color(0xFFF0F0F0)),

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
                        child: _RejectedCard(ticket: tickets[index]),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        rw(context, 20),
        rh(context, 16),
        rw(context, 20),
        rh(context, 4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'List Approval',
            style: TextStyle(
              fontSize: rfs(context, 15),
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
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(rw(context, 20)),
            ),
            child: Text(
              '$count $label',
              style: TextStyle(
                fontSize: rfs(context, 12),
                fontWeight: FontWeight.w600,
                color: AppColors.primary700,
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
                Icon(
                  icon,
                  size: rw(context, 64),
                  color: Colors.grey.shade300,
                ),
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
          Icon(
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

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.ticket,
    required this.onConfirmAction,
    required this.controller,
  });

  final ApprovalTicketModel ticket;
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
    final isPending =
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'pending';
    final isApproved =
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'approved';

    Color statusBg;
    Color statusFg;
    if (isPending) {
      statusBg = const Color(0xFFFFF3E0);
      statusFg = const Color(0xFFE65100);
    } else if (isApproved) {
      statusBg = const Color(0xFFE8F5E9);
      statusFg = const Color(0xFF2E7D32);
    } else {
      statusBg = const Color(0xFFFFEBEE);
      statusFg = const Color(0xFFC62828);
    }

    final start = ticket.visitorPeriodStart;
    final end = ticket.visitorPeriodEnd;
    final fmt = DateFormat('EEE, dd MMM yyyy');
    final timeFmt = DateFormat('HH:mm');
    final dateStr = start != null ? fmt.format(start) : '-';
    final timeStr = (start != null && end != null)
        ? '${timeFmt.format(start)} - ${timeFmt.format(end)}'
        : '-';

    return GestureDetector(
      onTap: () => ApprovalDetailModal.show(context, ticket),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: rw(context, 10),
              offset: Offset(0, rh(context, 3)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main content ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                rw(context, 16),
                rh(context, 14),
                rw(context, 16),
                rh(context, 14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: agenda + meta info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Visitor type label
                        if (ticket.visitorTypeName != null)
                          Text(
                            ticket.visitorTypeName!,
                            style: TextStyle(
                              fontSize: rfs(context, 11),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary600,
                            ),
                          ),
                        if (ticket.visitorTypeName != null)
                          vSpace(context, 4),

                        // Agenda (title)
                        Text(
                          ticket.agenda ?? '-',
                          style: TextStyle(
                            fontSize: rfs(context, 15),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),

                        vSpace(context, 6),

                        // Host
                        Text(
                          '${ticket.hostName ?? '-'} · ${ticket.hostOrganizationName ?? '-'}',
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            color: Colors.grey.shade600,
                          ),
                        ),

                        if (ticket.flow != null) ...[
                          vSpace(context, 3),
                          Text(
                            ticket.flow!,
                            style: TextStyle(
                              fontSize: rfs(context, 12),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  hSpace(context, 12),

                  // Right: status badge + date/time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 9),
                          vertical: rh(context, 3),
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                        ),
                        child: Text(
                          ticket.approvalActorStatus ?? '-',
                          style: TextStyle(
                            fontSize: rfs(context, 11),
                            fontWeight: FontWeight.w700,
                            color: statusFg,
                          ),
                        ),
                      ),

                      vSpace(context, 8),

                      // Date
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.end,
                      ),

                      vSpace(context, 2),

                      // Time range
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Footer ─────────────────────────────────────────────────
            if (isPending) ...[
              Container(
                height: 1,
                color: const Color(0xFFF0F0F0),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 12),
                  vertical: rh(context, 10),
                ),
                child: Row(
                  children: [
                    // Tolak
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onConfirmAction(
                          context,
                          title: 'Tolak Approval',
                          message:
                              'Apakah Anda yakin ingin menolak approval ini?',
                          onConfirm: () => controller.rejectMeetingHostAction(
                            approvalTicketId: ticket.approvalTicketId ?? ticket.ticketId ?? '',
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
                          'Tolak',
                          style: TextStyle(
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    hSpace(context, 10),

                    // Setujui
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _VisitorApprovalDialog.show(
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
                          'Setujui',
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
            ] else if (isApproved && ticket.approvedAt != null) ...[
              Container(
                height: 1,
                color: const Color(0xFFF0F0F0),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 16),
                  rh(context, 8),
                  rw(context, 16),
                  rh(context, 10),
                ),
                child: Text(
                  'Disetujui: ${DateFormat('dd MMM yyyy, HH:mm').format(ticket.approvedAt!)}',
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ],
        ),
      ), // end Container
    ); // end GestureDetector
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REJECTED CARD  (read-only, no action buttons)
// ═══════════════════════════════════════════════════════════════════════════

class _RejectedCard extends StatelessWidget {
  const _RejectedCard({required this.ticket});
  final ApprovalTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final start = ticket.visitorPeriodStart;
    final end = ticket.visitorPeriodEnd;
    final fmt = DateFormat('EEE, dd MMM yyyy');
    final timeFmt = DateFormat('HH:mm');
    final dateStr = start != null ? fmt.format(start) : '-';
    final timeStr = (start != null && end != null)
        ? '${timeFmt.format(start)} - ${timeFmt.format(end)}'
        : '-';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 14)),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: rw(context, 8),
            offset: Offset(0, rh(context, 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              rw(context, 16),
              rh(context, 14),
              rw(context, 16),
              rh(context, 14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ticket.visitorTypeName != null) ...[
                        Text(
                          ticket.visitorTypeName!,
                          style: TextStyle(
                            fontSize: rfs(context, 11),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary600,
                          ),
                        ),
                        vSpace(context, 4),
                      ],
                      Text(
                        ticket.agenda ?? '-',
                        style: TextStyle(
                          fontSize: rfs(context, 15),
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      vSpace(context, 6),
                      Text(
                        '${ticket.hostName ?? '-'} · ${ticket.hostOrganizationName ?? '-'}',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                hSpace(context, 12),

                // Right: status + date/time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 9),
                        vertical: rh(context, 3),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(rw(context, 20)),
                      ),
                      child: Text(
                        ticket.approvalActorStatus ?? 'Rejected',
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ),
                    vSpace(context, 8),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: rfs(context, 11),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    vSpace(context, 2),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: rfs(context, 11),
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorApprovalDialog extends StatefulWidget {
  const _VisitorApprovalDialog({
    required this.ticket,
    required this.controller,
  });

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
      builder: (_) => _VisitorApprovalDialog(
        ticket: ticket,
        controller: controller,
      ),
    );
  }

  @override
  State<_VisitorApprovalDialog> createState() => _VisitorApprovalDialogState();
}

class _VisitorApprovalDialogState extends State<_VisitorApprovalDialog> {
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
        approvalTicketId: widget.ticket.approvalTicketId ?? widget.ticket.ticketId ?? '',
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
    final allChecked = _visitors.isNotEmpty && _selectedIds.length == _visitors.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rw(context, 16)),
      ),
      title: Text(
        'Pilih Visitor untuk Disetujui',
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
                      style: TextStyle(color: Colors.red, fontSize: rfs(context, 13)),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _visitors.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada visitor ditemukan.',
                          style: TextStyle(color: Colors.grey, fontSize: rfs(context, 13)),
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
                                final name = v['visitor_name']?.toString() ?? v['name']?.toString() ?? '-';
                                final id = v['id']?.toString() ?? '';
                                final company = v['visitor_company']?.toString() ?? v['company']?.toString() ?? '';
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
          onPressed: _isSubmitting || _isLoading || _error != null || _visitors.isEmpty ? null : _submit,
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
            'Setujui',
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

