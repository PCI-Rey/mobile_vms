import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../data/models/approval_ticket_model.dart';
import '../../invitation/controller/invitation_controller.dart';

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
      enableDrag: true,
      isDismissible: true,
      barrierColor: Colors.black54,
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

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return GestureDetector(
              onTap: () {}, // Prevent taps inside from bubbling up
              child: Container(
                decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(rw(context, 20)),
            ),
          ),
          child: Column(
            children: [
              // ── Handle ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(vertical: rh(context, 12)),
                child: Container(
                  width: rw(context, 40),
                  height: rh(context, 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(rw(context, 2)),
                  ),
                ),
              ),

              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 20),
                  0,
                  rw(context, 20),
                  rh(context, 12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket.agenda ?? '-',
                        style: TextStyle(
                          fontSize: rfs(context, 18),
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    hSpace(context, 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 10),
                        vertical: rh(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(rw(context, 20)),
                      ),
                      child: Text(
                        ticket.approvalActorStatus ?? '-',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          fontWeight: FontWeight.w700,
                          color: statusFg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: const Color(0xFFF0F0F0)),

              // ── Scrollable Body ────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    rw(context, 20),
                    rh(context, 16),
                    rw(context, 20),
                    rh(context, 32),
                  ),
                  children: [
                    // ── Ticket Info Card ────────────────────────────
                    _SectionCard(
                      children: [
                        _InfoRow(
                          label: 'Host',
                          value:
                              '${ticket.hostName ?? '-'} (${ticket.hostOrganizationName ?? '-'})',
                        ),
                        if (ticket.visitorTypeName != null)
                          _InfoRow(
                            label: 'Tipe Visitor',
                            value: ticket.visitorTypeName!,
                          ),
                        if (ticket.flow != null)
                          _InfoRow(label: 'Flow', value: ticket.flow!),
                        _InfoRow(
                          label: 'Mulai',
                          value: ticket.visitorPeriodStart != null
                              ? DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                ).format(ticket.visitorPeriodStart!)
                              : '-',
                        ),
                        _InfoRow(
                          label: 'Selesai',
                          value: ticket.visitorPeriodEnd != null
                              ? DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                ).format(ticket.visitorPeriodEnd!)
                              : '-',
                        ),
                        if (isApproved && ticket.approvedAt != null)
                          _InfoRow(
                            label: 'Disetujui',
                            value: DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(ticket.approvedAt!),
                            valueColor: const Color(0xFF2E7D32),
                          ),
                        _InfoRow(
                          label: 'Status Transaksi',
                          value: ticket.transactionStatus ?? '-',
                        ),
                      ],
                    ),

                    vSpace(context, 20),

                    // ── Visitors Section ────────────────────────────
                    Text(
                      'Daftar Visitor',
                      style: TextStyle(
                        fontSize: rfs(context, 15),
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    vSpace(context, 10),

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
            ],
          ),
        ),
      );
    },
  ),
],
);
}
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rw(context, 16)),
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
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: rw(context, 110),
            child: Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 12),
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
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

    Color statusColor;
    if (status.toLowerCase().contains('checkin')) {
      statusColor = Colors.green.shade600;
    } else if (status.toLowerCase().contains('checkout')) {
      statusColor = AppColors.primary600;
    } else if (status.toLowerCase().contains('preregis')) {
      statusColor = Colors.orange.shade600;
    } else {
      statusColor = Colors.grey.shade500;
    }

    return Container(
      padding: EdgeInsets.all(rw(context, 14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: rw(context, 8),
            offset: Offset(0, rh(context, 2)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: rw(context, 42),
            height: rw(context, 42),
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
                  color: AppColors.primary600,
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
                  vSpace(context, 5),
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
                        color: AppColors.primary700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                if (vehicle.isNotEmpty) ...[
                  vSpace(context, 4),
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
