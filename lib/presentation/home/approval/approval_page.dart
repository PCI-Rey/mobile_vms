import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import '../invitation/controller/invitation_controller.dart';
import '../../../data/models/approval_ticket_model.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedStatus;
  late final InvitationController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<InvitationController>()) {
      controller = Get.find<InvitationController>();
    } else {
      controller = Get.put(InvitationController());
    }
    // Refresh approval tickets setiap kali halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchApprovalTickets();
    });
  }

  List<ApprovalTicketModel> get _filteredTickets {
    List<ApprovalTicketModel> list = List.from(controller.approvalTickets);

    if (selectedStatus != null && selectedStatus!.isNotEmpty) {
      list = list
          .where(
            (t) =>
                (t.approvalActorStatus ?? '')
                    .toLowerCase() ==
                selectedStatus!.toLowerCase(),
          )
          .toList();
    }

    if (startDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isBefore(
          DateTime(startDate!.year, startDate!.month, startDate!.day),
        );
      }).toList();
    }

    if (endDate != null) {
      list = list.where((t) {
        final d = t.visitorPeriodStart;
        if (d == null) return true;
        return !d.isAfter(
          DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59),
        );
      }).toList();
    }

    return list;
  }

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
            fontSize: rfs(context, 18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter Bar ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 20),
              vertical: rh(context, 12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>>(
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
                          startDate = result['startDate'];
                          endDate = result['endDate'];
                        });
                      }
                    },
                    child: _buildFilterChip(context, 'Filter'),
                  ),

                  if (selectedStatus != null) ...[
                    hSpace(context, 8),
                    _buildFilterValueChip(
                      context,
                      selectedStatus!,
                      onClear: () => setState(() => selectedStatus = null),
                    ),
                  ],

                  if (startDate != null || endDate != null) ...[
                    hSpace(context, 8),
                    _buildFilterValueChip(
                      context,
                      _formatDateRange(startDate, endDate),
                      onClear: () => setState(() {
                        startDate = null;
                        endDate = null;
                      }),
                    ),
                  ],

                  // Quick status filters
                  hSpace(context, 8),
                  _buildQuickFilter(context, 'Pending'),
                  hSpace(context, 8),
                  _buildQuickFilter(context, 'Approved'),
                ],
              ),
            ),
          ),
          Container(height: 1, color: const Color(0xFFF0F0F0)),

          // ── List ─────────────────────────────────────────────────────
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      if (controller.isApprovalLoading.value &&
          controller.approvalTickets.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final tickets = _filteredTickets;

      if (tickets.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchApprovalTickets(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                      '${tickets.length} requests',
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 16),
                  rh(context, 8),
                  rw(context, 16),
                  rh(context, 24),
                ),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: rh(context, 12)),
                    child: _buildApprovalCard(context, tickets[index]),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildApprovalCard(BuildContext context, ApprovalTicketModel ticket) {
    final isPending =
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'pending';
    final isApproved =
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'approved';

    // Status badge color
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
    final startStr = start != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(start)
        : '-';
    final endStr = end != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(end)
        : '-';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: rw(context, 12),
            offset: Offset(0, rh(context, 4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Body ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              rw(context, 16),
              rh(context, 16),
              rw(context, 16),
              rh(context, 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row: visitor type badge + status badge
                Row(
                  children: [
                    if (ticket.visitorTypeName != null) ...[
                      Expanded(
                        child: Text(
                          ticket.visitorTypeName!,
                          style: TextStyle(
                            fontSize: rfs(context, 11),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 10),
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
                  ],
                ),

                vSpace(context, 8),

                // Agenda (judul besar)
                Text(
                  ticket.agenda ?? '-',
                  style: TextStyle(
                    fontSize: rfs(context, 17),
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),

                vSpace(context, 10),

                // Host / Invitee
                _infoRow(
                  context,
                  icon: Icons.person_outline_rounded,
                  label:
                      '${ticket.hostName ?? '-'} (${ticket.hostOrganizationName ?? '-'})',
                ),

                vSpace(context, 6),

                // Flow / type
                if (ticket.flow != null)
                  _infoRow(
                    context,
                    icon: Icons.swap_horiz_rounded,
                    label: ticket.flow!,
                  ),

                if (ticket.flow != null) vSpace(context, 6),

                // Start
                _infoRow(
                  context,
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Start: $startStr',
                ),

                vSpace(context, 6),

                // End
                _infoRow(
                  context,
                  icon: Icons.stop_circle_outlined,
                  label: 'End:   $endStr',
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────
          if (isPending) ...[
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: rw(context, 16)),
              color: const Color(0xFFF0F0F0),
            ),

            // ── Action Buttons ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 12),
                vertical: rh(context, 10),
              ),
              child: Row(
                children: [
                  // ✕ Reject
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmAction(
                        context,
                        title: 'Tolak Approval',
                        message:
                            'Apakah Anda yakin ingin menolak approval ini?',
                        onConfirm: () =>
                            controller.rejectTicketAction(ticket.actorId ?? ''),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: rh(context, 10)),
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        foregroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rw(context, 10)),
                        ),
                      ),
                      icon: Icon(Icons.close_rounded, size: rw(context, 18)),
                      label: Text(
                        'Tolak',
                        style: TextStyle(
                          fontSize: rfs(context, 13),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  hSpace(context, 10),

                  // ✓ Approve
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmAction(
                        context,
                        title: 'Setujui Approval',
                        message:
                            'Apakah Anda yakin ingin menyetujui approval ini?',
                        onConfirm: () =>
                            controller.approveTicketAction(ticket.actorId ?? ''),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: rh(context, 10)),
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rw(context, 10)),
                        ),
                      ),
                      icon: Icon(Icons.check_rounded, size: rw(context, 18)),
                      label: Text(
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
          ] else ...[
            // Approved / Rejected — tampilkan info approved_at jika ada
            if (isApproved && ticket.approvedAt != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 16),
                  0,
                  rw(context, 16),
                  rh(context, 12),
                ),
                child: Text(
                  'Disetujui pada ${DateFormat('dd MMM yyyy, HH:mm').format(ticket.approvedAt!)}',
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    color: const Color(0xFF2E7D32),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: rw(context, 15), color: Colors.grey.shade500),
        hSpace(context, 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: rfs(context, 13),
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
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

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchApprovalTickets(),
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: rw(context, 64),
                  color: Colors.grey.shade300,
                ),
                vSpace(context, 16),
                Text(
                  'Belum ada data approval',
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

  Widget _buildFilterChip(BuildContext context, String label) {
    return Container(
      height: rh(context, 34),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 14)),
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
            style: TextStyle(
              fontSize: rfs(context, 12),
              color: Colors.black87,
            ),
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

  Widget _buildFilterValueChip(
    BuildContext context,
    String label, {
    required VoidCallback onClear,
  }) {
    return Container(
      height: rh(context, 34),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 10)),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        border: Border.all(color: AppColors.primary200),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: rfs(context, 12),
              color: AppColors.primary700,
              fontWeight: FontWeight.w500,
            ),
          ),
          hSpace(context, 6),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close,
              size: rw(context, 14),
              color: AppColors.primary700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(BuildContext context, String status) {
    final isActive = selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(
        () => selectedStatus = isActive ? null : status,
      ),
      child: Container(
        height: rh(context, 34),
        padding: EdgeInsets.symmetric(horizontal: rw(context, 14)),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary500 : Colors.white,
          border: Border.all(
            color: isActive ? AppColors.primary500 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(rw(context, 50)),
        ),
        child: Center(
          child: Text(
            status,
            style: TextStyle(
              fontSize: rfs(context, 12),
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
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
