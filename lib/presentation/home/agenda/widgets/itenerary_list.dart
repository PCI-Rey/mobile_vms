import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../invitation/controller/invitation_controller.dart';
import '../../../../data/models/approval_ticket_model.dart';
import '../../approval/approval_page.dart';
import '../../approval/widgets/approve_detail_model.dart';

class IteneraryList extends StatefulWidget {
  const IteneraryList({super.key});

  @override
  State<IteneraryList> createState() => _IteneraryListState();
}

class _IteneraryListState extends State<IteneraryList> {
  final InvitationController controller =
      Get.isRegistered<InvitationController>()
      ? Get.find<InvitationController>()
      : Get.put(InvitationController());

  Timer? _carouselTimer;
  final PageController _pageController = PageController(
    viewportFraction: 1.0,
    initialPage: 1200,
  );
  final RxInt _currentPage = 1200.obs;
  Worker? _listWorker;
  Worker? _dateWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.approvalTickets.isEmpty) {
        controller.fetchApprovalTickets();
      }
    });

    void updateCarousel() {
      final selectedDate = controller.selectedDashboardDate.value;
      final filtered = controller.approvalTickets.where((ticket) {
        if (ticket.visitorPeriodStart == null) return false;
        return ticket.visitorPeriodStart!.year == selectedDate.year &&
            ticket.visitorPeriodStart!.month == selectedDate.month &&
            ticket.visitorPeriodStart!.day == selectedDate.day;
      }).toList();
      if (_pageController.hasClients && filtered.isNotEmpty) {
        final listLength = filtered.length > 3 ? 3 : filtered.length;
        final targetPage = 1200 - (1200 % listLength);
        _pageController.jumpToPage(targetPage);
        _currentPage.value = targetPage;
        _resetCarouselTimer();
      }
    }

    _listWorker = ever(controller.approvalTickets, (_) => updateCarousel());
    _dateWorker = ever(controller.selectedDashboardDate, (_) => updateCarousel());

    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    // Auto slide disabled as per user request
  }

  void _resetCarouselTimer() {
    // Auto slide disabled as per user request
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselTimer?.cancel();
    _listWorker?.dispose();
    _dateWorker?.dispose();
    super.dispose();
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


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDashboardDate.value;
      final filteredTickets = controller.approvalTickets.where((ticket) {
        if (ticket.visitorPeriodStart == null) return false;
        return ticket.visitorPeriodStart!.year == selectedDate.year &&
            ticket.visitorPeriodStart!.month == selectedDate.month &&
            ticket.visitorPeriodStart!.day == selectedDate.day;
      }).toList();

      // Sort: Pending first, then descending by visitorPeriodStart
      filteredTickets.sort((a, b) {
        final aPending = a.approvalActorStatus?.toLowerCase() == 'pending' ||
            a.approvalStatus?.toLowerCase() == 'pending';
        final bPending = b.approvalActorStatus?.toLowerCase() == 'pending' ||
            b.approvalStatus?.toLowerCase() == 'pending';

        if (aPending != bPending) {
          return aPending ? -1 : 1; // Pending comes first
        }

        if (a.visitorPeriodStart == null && b.visitorPeriodStart == null) return 0;
        if (a.visitorPeriodStart == null) return 1;
        if (b.visitorPeriodStart == null) return -1;
        return b.visitorPeriodStart!.compareTo(a.visitorPeriodStart!);
      });

      final list = filteredTickets.length > 3
          ? filteredTickets.take(3).toList()
          : filteredTickets;

      if (controller.isApprovalLoading.value &&
          controller.approvalTickets.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (filteredTickets.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: rh(context, 32)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: rw(context, 48),
                  color: Colors.grey.shade300,
                ),
                vSpace(context, 12),
                Text(
                  'No invitation approval requests found for this date.',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: rfs(context, 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      double carouselHeight = 235.0;
      if (list.isNotEmpty) {
        final int currentIndex = _currentPage.value % list.length;
        if (currentIndex < list.length) {
          final ticket = list[currentIndex];
          final isPending =
              ticket.approvalActorStatus?.toLowerCase() == 'pending' ||
              ticket.approvalStatus?.toLowerCase() == 'pending';
          final isApproved =
              ticket.approvalActorStatus?.toLowerCase() == 'approved' ||
              ticket.approvalStatus?.toLowerCase() == 'approved';
          final isRejected =
              ticket.approvalActorStatus?.toLowerCase() == 'rejected' ||
              ticket.approvalActorStatus?.toLowerCase() == 'denied' ||
              ticket.approvalStatus?.toLowerCase() == 'rejected' ||
              ticket.approvalStatus?.toLowerCase() == 'denied';

          final needsApproval = isPending;

          if (needsApproval) {
            carouselHeight = 270.0;
          } else if ((isApproved || isRejected) && ticket.approvedAt != null) {
            carouselHeight = 235.0;
          } else {
            carouselHeight = 200.0;
          }
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: rh(context, list.isEmpty ? 235.0 : carouselHeight),
            child: PageView.builder(
              controller: _pageController,
              physics: list.length <= 1
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (int index) {
                _currentPage.value = index;
              },
              itemBuilder: (context, index) {
                final int realIndex = index % list.length;
                final ticket = list[realIndex];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 2),
                    vertical: rh(context, 4),
                  ),
                  child: _buildApprovalCard(context, ticket, realIndex + 1),
                );
              },
            ),
          ),
          vSpace(context, 12),

          // Carousel Indicators
          if (filteredTickets.length > 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                filteredTickets.length > 3
                    ? 3
                    : filteredTickets.length,
                (index) {
                  final listLength = filteredTickets.length > 3
                      ? 3
                      : filteredTickets.length;
                  final isActive = (_currentPage.value % listLength) == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: rw(context, 4)),
                    height: rw(context, 6),
                    width: isActive ? rw(context, 16) : rw(context, 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary500
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(rw(context, 3)),
                    ),
                  );
                },
              ),
            ),
            vSpace(context, 12),
          ],

        ],
      );
    });
  }

  Widget _buildApprovalCard(BuildContext context, ApprovalTicketModel ticket, int no) {
    final start = ticket.visitorPeriodStart;
    final end = ticket.visitorPeriodEnd;
    final startStr = start != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(start)
        : '-';
    final endStr = end != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(end)
        : '-';

    final isPending =
        ticket.approvalActorStatus?.toLowerCase() == 'pending' ||
        ticket.approvalStatus?.toLowerCase() == 'pending';
    final isApproved =
        ticket.approvalActorStatus?.toLowerCase() == 'approved' ||
        ticket.approvalStatus?.toLowerCase() == 'approved';
    final isRejected =
        ticket.approvalActorStatus?.toLowerCase() == 'rejected' ||
        ticket.approvalActorStatus?.toLowerCase() == 'denied' ||
        ticket.approvalStatus?.toLowerCase() == 'rejected' ||
        ticket.approvalStatus?.toLowerCase() == 'denied';

    final needsApproval = isPending;

    Color statusBg;
    Color statusFg;
    bool hasBorder = true;
    String statusLabel = 'Pending';

    if (isApproved) {
      statusBg = const Color(0xFF43A047);
      statusFg = Colors.white;
      hasBorder = false;
      statusLabel = 'Approved';
    } else if (isRejected) {
      statusBg = const Color(0xFFE53935);
      statusFg = Colors.white;
      hasBorder = false;
      statusLabel = 'Rejected';
    } else {
      statusBg = const Color(0xFFFFF3E0);
      statusFg = const Color(0xFFE65100);
      hasBorder = true;
      statusLabel = 'Pending';
    }

    final cardContent = Container(
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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Number circle + Agenda (title) + Status badge
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 12),
                bottom: rh(context, 8),
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
                      '$no',
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
                          ? Border.all(
                              color: statusFg.withValues(alpha: 0.4),
                            )
                          : null,
                    ),
                    child: Text(
                      statusLabel,
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
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade100,
            ),
  
            // Body: Info grid fields
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 8),
                bottom: rh(context, 12),
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
                          ticket.visitorTypeName == null || ticket.visitorTypeName!.isEmpty
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
                  vSpace(context, 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.business_outlined,
                          'Organization',
                          ticket.hostOrganizationName == null || ticket.hostOrganizationName!.isEmpty
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
                  vSpace(context, 6),
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
  
            // Actions if pending AND needs approval
            if (needsApproval) ...[
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
                        onPressed: () => _confirmAction(
                          context,
                          title: 'Tolak Approval',
                          message:
                              'Apakah Anda yakin ingin menolak approval ini?',
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
            ] else if (isApproved && ticket.approvedAt != null) ...[
               Container(height: 1, color: const Color(0xFFF0F0F0)),
               Padding(
                 padding: EdgeInsets.symmetric(
                   horizontal: rw(context, 16),
                   vertical: rh(context, 10),
                 ),
                 child: Text(
                   'Disetujui: ${DateFormat('dd MMMM yyyy, HH:mm').format(ticket.approvedAt!)}',
                   style: TextStyle(
                     fontSize: rfs(context, 13),
                     color: const Color(0xFF2E7D32),
                   ),
                 ),
               ),
             ] else if (isRejected && ticket.approvedAt != null) ...[
               Container(height: 1, color: const Color(0xFFF0F0F0)),
               Padding(
                 padding: EdgeInsets.symmetric(
                   horizontal: rw(context, 16),
                   vertical: rh(context, 10),
                 ),
                 child: Text(
                   'Ditolak: ${DateFormat('dd MMMM yyyy, HH:mm').format(ticket.approvedAt!)}',
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

    // Wrap with GestureDetector to open detail modal on tap.
    // For pending cards with action buttons, only the card body (non-button area) opens detail.
    return GestureDetector(
      onTap: () => ApprovalDetailModal.show(context, ticket),
      child: cardContent,
    );
  }

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
}
