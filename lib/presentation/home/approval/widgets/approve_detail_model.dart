// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../data/models/approval_ticket_model.dart';
import '../../invitation/controller/invitation_controller.dart';
import '../approval_page.dart';

class ApprovalDetailModal extends StatefulWidget {
  const ApprovalDetailModal({super.key, required this.ticket});

  final ApprovalTicketModel ticket;

  static Future<void> show(
    BuildContext context,
    ApprovalTicketModel ticket,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApprovalDetailModal(ticket: ticket),
    );
  }

  @override
  State<ApprovalDetailModal> createState() => _ApprovalDetailModalState();
}

class _ApprovalDetailModalState extends State<ApprovalDetailModal> {
  late final InvitationController _ctrl;
  List<Map<String, dynamic>> _visitors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<InvitationController>()
        ? Get.find<InvitationController>()
        : Get.put(InvitationController());
    _fetchVisitors();
  }

  Future<void> _fetchVisitors() async {
    final entityId = widget.ticket.entityId;
    if (entityId == null || entityId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Entity ID tidak tersedia.';
      });
      return;
    }
    try {
      final result = await _ctrl.fetchTransactionVisitors(entityId);
      if (mounted) {
        setState(() {
          _visitors = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Gagal memuat data visitor.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final isPending =
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'pending';
    final isApproved =
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'approved';
    final isRejected =
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'rejected' ||
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'denied' ||
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'reject' ||
        (ticket.approvalActorStatus ?? '').toLowerCase() == 'deny';

    Color statusBgColor;
    if (isPending) {
      statusBgColor = AppColors.warning500;
    } else if (isApproved) {
      statusBgColor = AppColors.success500;
    } else {
      statusBgColor = AppColors.error500;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 24)),
        ),
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              vSpace(context, 12),
              // Drag handle
              Center(
                child: Container(
                  width: rw(context, 40),
                  height: rh(context, 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(rw(context, 2)),
                  ),
                ),
              ),
              vSpace(context, 12),

              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 20),
                  vertical: rh(context, 14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(rw(context, 10)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005596).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Color(0xFF005596),
                      ),
                    ),
                    hSpace(context, 12),
                    Expanded(
                      child: Text(
                        ticket.agenda ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: rfs(context, 16),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 10),
                        vertical: rh(context, 5),
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(rw(context, 20)),
                      ),
                      child: Text(
                        ticket.approvalActorStatus ?? '-',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.grey.shade100),

              // ── Scrollable Body ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 20),
                    vertical: rh(context, 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Ticket Information
                      _section(context, 'Ticket Information'),
                      _grid(context, [
                        _SheetField(
                          'Host',
                          '${ticket.hostName ?? '-'} (${ticket.hostOrganizationName ?? '-'})',
                          Icons.person_outline,
                        ),
                        if (ticket.visitorTypeName != null)
                          _SheetField(
                            'Visitor Type',
                            ticket.visitorTypeName!,
                            Icons.badge_outlined,
                          ),
                        if (ticket.flow != null)
                          _SheetField(
                            'Flow',
                            ticket.flow!,
                            Icons.timeline_outlined,
                          ),
                        _SheetField(
                          'Transaction Status',
                          ticket.transactionStatus ?? '-',
                          Icons.info_outline,
                          badgeColor: _statusColor(ticket.transactionStatus ?? ''),
                        ),
                        if (isApproved && ticket.approvedAt != null)
                          _SheetField(
                            'Approved',
                            DateFormat('dd MMM yyyy, HH:mm').format(ticket.approvedAt!),
                            Icons.done_all_outlined,
                          ),
                        if (isRejected && ticket.approvedAt != null)
                          _SheetField(
                            'Rejected',
                            DateFormat('dd MMM yyyy, HH:mm').format(ticket.approvedAt!),
                            Icons.cancel_outlined,
                          ),
                      ]),

                      vSpace(context, 16),

                      // 2. Visit Period
                      _section(context, 'Visit Period'),
                      Container(
                        padding: EdgeInsets.all(rw(context, 14)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(rw(context, 10)),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.login_outlined,
                                        size: rw(context, 14),
                                        color: Colors.green.shade600,
                                      ),
                                      hSpace(context, 4),
                                      Text(
                                        'Start',
                                        style: TextStyle(
                                          fontSize: rfs(context, 12),
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  vSpace(context, 4),
                                  Text(
                                    ticket.visitorPeriodStart != null
                                        ? DateFormat('dd MMMM yyyy').format(ticket.visitorPeriodStart!)
                                        : '-',
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (ticket.visitorPeriodStart != null)
                                    Text(
                                      DateFormat('HH:mm').format(ticket.visitorPeriodStart!),
                                      style: TextStyle(
                                        fontSize: rfs(context, 12),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: rh(context, 50),
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: rw(context, 12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.logout_outlined,
                                          size: rw(context, 14),
                                          color: Colors.grey.shade500,
                                        ),
                                        hSpace(context, 4),
                                        Text(
                                          'End',
                                          style: TextStyle(
                                            fontSize: rfs(context, 12),
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    vSpace(context, 4),
                                    Text(
                                      ticket.visitorPeriodEnd != null
                                          ? DateFormat('dd MMMM yyyy').format(ticket.visitorPeriodEnd!)
                                          : '-',
                                      style: TextStyle(
                                        fontSize: rfs(context, 12),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (ticket.visitorPeriodEnd != null)
                                      Text(
                                        DateFormat('HH:mm').format(ticket.visitorPeriodEnd!),
                                        style: TextStyle(
                                          fontSize: rfs(context, 12),
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      vSpace(context, 16),

                      // 3. Daftar Visitor
                      _section(
                        context,
                        _visitors.length > 1 ? 'List Visitors' : 'List Visitor',
                      ),
                      if (_loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_error != null)
                        _ErrorState(message: _error!)
                      else if (_visitors.isEmpty)
                        _EmptyVisitors()
                      else
                        ..._visitors.map(
                          (v) => Padding(
                            padding: EdgeInsets.only(bottom: rh(context, 10)),
                            child: _VisitorCard(visitor: v),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Reject/Approve Buttons ──────────────────────────────────
              if (isPending) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 20),
                    vertical: rh(context, 8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmAction(
                            context,
                            title: 'Reject Approval',
                            message: 'Are you sure you want to reject this approval?',
                            onConfirm: () => _ctrl.rejectMeetingHostAction(
                              approvalTicketId: ticket.approvalTicketId ?? ticket.ticketId ?? '',
                              actorId: ticket.actorId ?? '',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: rh(context, 14)),
                            side: const BorderSide(color: Color(0xFFD32F2F)),
                            foregroundColor: const Color(0xFFD32F2F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(rw(context, 12)),
                            ),
                          ),
                          child: Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      hSpace(context, 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await VisitorApprovalDialog.show(context, ticket, _ctrl);
                            if (context.mounted) {
                              Navigator.of(context).pop(); // close bottom sheet
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: rh(context, 14)),
                            backgroundColor: AppColors.primary500,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(rw(context, 12)),
                            ),
                          ),
                          child: Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Close button ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 20),
                  rh(context, 10),
                  rw(context, 20),
                  rh(context, 16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005596),
                      padding: EdgeInsets.symmetric(vertical: rh(context, 14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 12)),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: rfs(context, 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              final success = await onConfirm();
              if (success && mounted) {
                Navigator.of(context).pop(); // close bottom sheet
              }
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

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 10)),
      child: Row(
        children: [
          Container(
            width: rw(context, 3),
            height: rh(context, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF005596),
              borderRadius: BorderRadius.circular(rw(context, 2)),
            ),
          ),
          hSpace(context, 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: rfs(context, 14),
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    List<_SheetField> fields,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rw(context, 10)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(fields.length, (i) {
          final f = fields[i];
          final isLast = i == fields.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 14),
                  vertical: rh(context, 10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      f.icon,
                      size: rw(context, 16),
                      color: Colors.grey.shade400,
                    ),
                    hSpace(context, 10),
                    SizedBox(
                      width: rw(context, 100),
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: f.badgeColor != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 8),
                                    vertical: rh(context, 3),
                                  ),
                                  decoration: BoxDecoration(
                                    color: f.badgeColor,
                                    borderRadius: BorderRadius.circular(rw(context, 4)),
                                  ),
                                  child: Text(
                                    f.value,
                                    style: TextStyle(
                                      fontSize: rfs(context, 11),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    f.value,
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                  indent: rw(context, 14),
                  endIndent: rw(context, 14),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status.toLowerCase().trim()) {
    case 'checkin':
    case 'approved':
    case 'approve':
    case 'success':
      return const Color(0xFF00897B);
    case 'checkout':
      return const Color(0xFF3949AB);
    case 'available':
      return const Color(0xFF8E24AA);
    case 'waiting':
    case 'pending':
      return const Color(0xFFFB8C00);
    case 'denied':
    case 'deny':
    case 'rejected':
    case 'reject':
      return const Color(0xFFE53935);
    case 'quickaccess':
      return const Color(0xFFD81B60);
    case 'preregis':
    case 'praregis':
      return const Color(0xFF00B0FF);
    default:
      return const Color(0xFF546E7A);
  }
}

class _SheetField {
  final String label;
  final String value;
  final IconData icon;
  final Color? badgeColor;
  _SheetField(this.label, this.value, this.icon, {this.badgeColor});
}

class _VisitorCard extends StatelessWidget {
  const _VisitorCard({required this.visitor});
  final Map<String, dynamic> visitor;

  @override
  Widget build(BuildContext context) {
    final name =
        visitor['visitor_name']?.toString() ??
        visitor['name']?.toString() ??
        '-';
    final code =
        visitor['invitation_code']?.toString() ??
        visitor['code']?.toString() ??
        '';
    final status =
        visitor['visitor_status']?.toString() ??
        visitor['status']?.toString() ??
        '';
    final role =
        visitor['visitor_role']?.toString() ?? visitor['role']?.toString() ?? '';
    final company =
        visitor['visitor_company']?.toString() ??
        visitor['company']?.toString() ??
        '';
    final vehicle =
        visitor['vehicle_plate_number']?.toString() ??
        visitor['plate_number']?.toString() ??
        '';

    final statusColor = _statusColor(status);

    return Container(
      padding: EdgeInsets.all(rw(context, 14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 10)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: rw(context, 44),
            height: rw(context, 44),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(rw(context, 10)),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF005596),
                ),
              ),
            ),
          ),
          hSpace(context, 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: rfs(context, 14),
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (status.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 8),
                          vertical: rh(context, 2),
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: rfs(context, 10),
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),

                if (role.isNotEmpty) ...[
                  vSpace(context, 3),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
                if (company.isNotEmpty) ...[
                  vSpace(context, 2),
                  Text(
                    company,
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
                if (code.isNotEmpty) ...[
                  vSpace(context, 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 8),
                      vertical: rh(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(rw(context, 6)),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: rfs(context, 11),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF005596),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                if (vehicle.isNotEmpty) ...[
                  vSpace(context, 6),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: rw(context, 13),
                        color: Colors.grey.shade400,
                      ),
                      hSpace(context, 4),
                      Text(
                        vehicle,
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVisitors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rh(context, 24)),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: rw(context, 48),
              color: Colors.grey.shade300,
            ),
            vSpace(context, 12),
            Text(
              'Belum ada visitor terdaftar',
              style: TextStyle(
                fontSize: rfs(context, 14),
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rh(context, 24)),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: rw(context, 48),
              color: Colors.red.shade200,
            ),
            vSpace(context, 12),
            Text(
              message,
              style: TextStyle(
                fontSize: rfs(context, 13),
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
