import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/approval_history_model.dart';

class HistoryApprovalModal extends StatefulWidget {
  final String entityId;
  final String? fallbackTitle;

  const HistoryApprovalModal({
    super.key,
    required this.entityId,
    this.fallbackTitle,
  });

  /// Helper to show this bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String entityId,
    String? fallbackTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HistoryApprovalModal(
        entityId: entityId,
        fallbackTitle: fallbackTitle,
      ),
    );
  }

  @override
  State<HistoryApprovalModal> createState() => _HistoryApprovalModalState();
}

class _HistoryApprovalModalState extends State<HistoryApprovalModal> {
  bool _isLoading = true;
  String? _errorMessage;
  ApprovalHistoryCollection? _historyData;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = HiveService().getUser()?.token ?? '';
      if (token.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sesi telah berakhir, silakan login kembali.';
        });
        return;
      }

      if (widget.entityId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Entity ID tidak valid.';
        });
        return;
      }

      final res = await ApiService().getApprovalTicketHistory(
        token,
        widget.entityId,
      );

      if (res.data != null &&
          (res.data['status'] == 'success' ||
              res.data['status_code'] == 200 ||
              res.statusCode == 200)) {
        final parsed = ApprovalHistoryResponse.fromJson(res.data);
        setState(() {
          _isLoading = false;
          _historyData = parsed.collection;
          if (_historyData == null) {
            _errorMessage = 'Tidak ada data tiket approval untuk undangan ini.';
          }
        });
      } else {
        final msg = res.data?['msg'] ??
            res.data?['message'] ??
            'Gagal memuat riwayat approval.';
        setState(() {
          _isLoading = false;
          _errorMessage = msg.toString();
        });
      }
    } catch (e) {
      debugPrint('Error fetching approval history: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan jaringan saat memuat riwayat approval.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(rw(context, 20)),
              topRight: Radius.circular(rw(context, 20)),
            ),
          ),
          child: Column(
            children: [
              // ── Drag Handle ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(top: rh(context, 12)),
                child: Container(
                  width: rw(context, 40),
                  height: rh(context, 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(rw(context, 2)),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 20),
                  vertical: rh(context, 14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(rw(context, 9)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005596).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: const Color(0xFF005596),
                        size: rw(context, 22),
                      ),
                    ),
                    hSpace(context, 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'History Approval',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: rfs(context, 16),
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          vSpace(context, 2),
                          Text(
                            _historyData?.ticketName.isNotEmpty == true
                                ? _historyData!.ticketName
                                : (widget.fallbackTitle ?? 'Approval ticket'),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: rfs(context, 12),
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade600,
                        size: rw(context, 22),
                      ),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: rw(context, 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.grey.shade100),

              // ── Body ─────────────────────────────────────────────────
              Expanded(
                child: _buildBody(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 14),
            vSpace(context, 12),
            Text(
              'Memuat riwayat approval...',
              style: TextStyle(
                fontSize: rfs(context, 13),
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(context, 28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(rw(context, 14)),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.red.shade400,
                  size: rw(context, 32),
                ),
              ),
              vSpace(context, 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rfs(context, 13),
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              vSpace(context, 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005596),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rw(context, 8)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 18),
                    vertical: rh(context, 10),
                  ),
                ),
                onPressed: _fetchHistory,
                icon: Icon(Icons.refresh_rounded, size: rw(context, 16), color: Colors.white),
                label: Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final collection = _historyData;
    if (collection == null) return const SizedBox.shrink();

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 20),
        vertical: rh(context, 16),
      ),
      children: [
        // ── Top Ticket Card ──────────────────────────────────────────
        _buildTopTicketCard(collection),
        vSpace(context, 20),

        // ── Section Title: Approval Timeline ─────────────────────────
        Row(
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
              'Approval Timeline',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: rfs(context, 14),
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        vSpace(context, 14),

        // ── Timeline List ─────────────────────────────────────────────
        if (collection.timeline.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: rh(context, 20)),
            child: Center(
              child: Text(
                'Belum ada langkah approval yang tercatat.',
                style: TextStyle(
                  fontSize: rfs(context, 13),
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          )
        else
          ...List.generate(collection.timeline.length, (index) {
            final step = collection.timeline[index];
            final isLast = index == collection.timeline.length - 1;
            return _buildTimelineStepItem(step, isLast);
          }),

        vSpace(context, 20),
      ],
    );
  }

  // ── Top Ticket Card ────────────────────────────────────────────────────────
  Widget _buildTopTicketCard(ApprovalHistoryCollection item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 14)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(rw(context, 16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.ticketName.isNotEmpty
                            ? item.ticketName
                            : 'Approval ticket',
                        style: TextStyle(
                          fontSize: rfs(context, 14),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (item.ticketDescription.isNotEmpty) ...[
                        vSpace(context, 4),
                        Text(
                          item.ticketDescription,
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                hSpace(context, 10),
                _buildStatusPill(item.approvalStatus),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 16),
              vertical: rh(context, 12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created By',
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      vSpace(context, 2),
                      Text(
                        item.createdBy.isNotEmpty ? item.createdBy : '-',
                        style: TextStyle(
                          fontSize: rfs(context, 13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created At',
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      vSpace(context, 2),
                      Text(
                        item.formattedCreatedAt,
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Timeline Step Item ─────────────────────────────────────────────────────
  Widget _buildTimelineStepItem(ApprovalTimelineStep step, bool isLast) {
    final theme = _getStepTheme(step);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon & Vertical Connector Line ────────────────────────
          Column(
            children: [
              Container(
                width: rw(context, 32),
                height: rw(context, 32),
                decoration: BoxDecoration(
                  color: theme.bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.borderColor, width: 1.5),
                ),
                child: Icon(
                  theme.icon,
                  size: rw(context, 16),
                  color: theme.iconColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: rh(context, 4)),
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          hSpace(context, 14),

          // ── Step Content ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : rh(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: rfs(context, 13.5),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            if (step.subtitle.isNotEmpty) ...[
                              vSpace(context, 2),
                              Text(
                                step.subtitle,
                                style: TextStyle(
                                  fontSize: rfs(context, 12),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      hSpace(context, 8),
                      _buildStepStatusBadge(step.status, step.action),
                    ],
                  ),

                  // Description if provided and distinct
                  if (step.description.isNotEmpty &&
                      step.description.toLowerCase() != step.title.toLowerCase()) ...[
                    vSpace(context, 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: rfs(context, 11.5),
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],

                  // Time display if available (especially for submitted / completed steps)
                  if (step.formattedTime.isNotEmpty && step.actors.isEmpty) ...[
                    vSpace(context, 4),
                    Text(
                      step.formattedTime,
                      style: TextStyle(
                        fontSize: rfs(context, 11),
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // ── Actors Card (Approvers) ───────────────────────
                  if (step.actors.isNotEmpty) ...[
                    vSpace(context, 10),
                    ...step.actors.map((actor) => _buildActorCard(actor, step)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actor Card ─────────────────────────────────────────────────────────────
  Widget _buildActorCard(ApprovalActor actor, ApprovalTimelineStep step) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(context, 8)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 12),
        vertical: rh(context, 10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(rw(context, 10)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  actor.fullname.isNotEmpty ? actor.fullname : 'Approver',
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          vSpace(context, 2),
          Text(
            '${actor.email.isNotEmpty ? actor.email : actor.username}${actor.approverType.isNotEmpty ? ' · ${actor.approverType}' : ''}',
            style: TextStyle(
              fontSize: rfs(context, 11.5),
              color: const Color(0xFF64748B),
            ),
          ),
          vSpace(context, 8),
          Wrap(
            spacing: rw(context, 6),
            runSpacing: rh(context, 4),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Actor status badge
              _buildActorStatusBadge(actor.approvalActorStatus),

              // Reviewer / Final Approver badge
              if (actor.isReviewer)
                _buildOutlineRoleBadge('Reviewer')
              else if (actor.isFinal)
                _buildOutlineRoleBadge('Final Approver')
              else if (actor.approverType.isNotEmpty)
                _buildOutlineRoleBadge(actor.approverType),
            ],
          ),
          if (step.formattedTime.isNotEmpty) ...[
            vSpace(context, 6),
            Text(
              step.formattedTime,
              style: TextStyle(
                fontSize: rfs(context, 11),
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Status Pill Builders ───────────────────────────────────────────────────
  Widget _buildStatusPill(String status) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFE2E8F0);
    Color fg = const Color(0xFF475569);

    if (s == 'completed' || s == 'approved') {
      bg = const Color(0xFF10B981);
      fg = Colors.white;
    } else if (s == 'rejected' || s == 'reject' || s == 'denied') {
      bg = const Color(0xFFEF4444);
      fg = Colors.white;
    } else if (s == 'pending' || s == 'in_progress' || s == 'in progress') {
      bg = const Color(0xFFF59E0B);
      fg = Colors.white;
    } else if (s == 'waiting') {
      bg = const Color(0xFF3B82F6);
      fg = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 10),
        vertical: rh(context, 4),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(rw(context, 20)),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(
          fontSize: rfs(context, 11),
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildStepStatusBadge(String status, String action) {
    final s = status.toLowerCase();
    final a = action.toLowerCase();
    String label = status;
    Color bg = const Color(0xFFE2E8F0);
    Color fg = const Color(0xFF475569);

    if (s == 'completed' || a == 'submitted' || a == 'approved') {
      label = 'Completed';
      bg = const Color(0xFF10B981);
      fg = Colors.white;
    } else if (s == 'rejected' || a == 'rejected') {
      label = 'Rejected';
      bg = const Color(0xFFEF4444);
      fg = Colors.white;
    } else if (s == 'in_progress' || a == 'pending') {
      label = 'In Progress';
      bg = const Color(0xFFF59E0B);
      fg = Colors.white;
    } else if (s == 'waiting' || a == 'waiting') {
      label = 'Waiting';
      bg = const Color(0xFF3B82F6);
      fg = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 9),
        vertical: rh(context, 3.5),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(rw(context, 20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: rfs(context, 10.5),
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildActorStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFE2E8F0);
    Color fg = const Color(0xFF475569);

    if (s == 'approved') {
      bg = const Color(0xFF10B981);
      fg = Colors.white;
    } else if (s == 'rejected') {
      bg = const Color(0xFFEF4444);
      fg = Colors.white;
    } else if (s == 'pending') {
      bg = const Color(0xFFF59E0B);
      fg = Colors.white;
    } else if (s == 'waiting') {
      bg = const Color(0xFF3B82F6);
      fg = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 8),
        vertical: rh(context, 3),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(rw(context, 20)),
      ),
      child: Text(
        status.isEmpty ? 'Pending' : status,
        style: TextStyle(
          fontSize: rfs(context, 10.5),
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildOutlineRoleBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 8),
        vertical: rh(context, 2.5),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(rw(context, 20)),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: rfs(context, 10.5),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }

  _StepTheme _getStepTheme(ApprovalTimelineStep step) {
    final s = step.status.toLowerCase();
    final a = step.action.toLowerCase();

    if (s == 'completed' || a == 'submitted' || a == 'approved') {
      return _StepTheme(
        bgColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFFA7F3D0),
        iconColor: const Color(0xFF10B981),
        icon: a == 'submitted' ? Icons.send_rounded : Icons.check_rounded,
      );
    } else if (s == 'rejected' || a == 'rejected') {
      return _StepTheme(
        bgColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
        iconColor: const Color(0xFFEF4444),
        icon: Icons.close_rounded,
      );
    } else if (s == 'in_progress' || a == 'pending' || step.isCurrentStep) {
      return _StepTheme(
        bgColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFDE68A),
        iconColor: const Color(0xFFF59E0B),
        icon: Icons.access_time_rounded,
      );
    } else {
      return _StepTheme(
        bgColor: const Color(0xFFF0F9FF),
        borderColor: const Color(0xFFBAE6FD),
        iconColor: const Color(0xFF0284C7),
        icon: Icons.schedule_rounded,
      );
    }
  }
}

class _StepTheme {
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  _StepTheme({
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });
}

