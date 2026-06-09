import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../invitation/controller/invitation_controller.dart';
import '../../../../data/models/approval_ticket_model.dart';
import '../../approval/approval_page.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.approvalTickets.isEmpty) {
        controller.fetchApprovalTickets();
      }
    });

    _listWorker = ever(controller.approvalTickets, (list) {
      if (_pageController.hasClients && list.isNotEmpty) {
        final listLength = list.length > 3 ? 3 : list.length;
        final targetPage = 1200 - (1200 % listLength);
        _pageController.jumpToPage(targetPage);
        _currentPage.value = targetPage;
        _resetCarouselTimer();
      }
    });

    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted &&
          controller.approvalTickets.isNotEmpty &&
          _pageController.hasClients) {
        final listLength = controller.approvalTickets.length > 3
            ? 3
            : controller.approvalTickets.length;
        if (listLength > 1) {
          _currentPage.value++;
          _pageController.animateToPage(
            _currentPage.value,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  void _resetCarouselTimer() {
    _carouselTimer?.cancel();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselTimer?.cancel();
    _listWorker?.dispose();
    super.dispose();
  }

  bool _checkNeedApproval(ApprovalTicketModel ticket) {
    if (ticket.needApproval != null) {
      return ticket.needApproval!;
    }
    final sitesList = controller.sites;
    if (sitesList.isEmpty) return true;

    for (var s in sitesList) {
      if (ticket.siteId != null && ticket.siteId!.isNotEmpty) {
        if (s['id']?.toString().toLowerCase() == ticket.siteId!.toLowerCase()) {
          return s['need_approval'] == true;
        }
      }
      if (ticket.siteName != null && ticket.siteName!.isNotEmpty) {
        if (s['name']?.toString().toLowerCase() ==
            ticket.siteName!.toLowerCase()) {
          return s['need_approval'] == true;
        }
      }
      if (ticket.approverUserId != null && ticket.approverUserId!.isNotEmpty) {
        if (s['host']?.toString().toLowerCase() ==
                ticket.approverUserId!.toLowerCase() ||
            s['Employee']?['id']?.toString().toLowerCase() ==
                ticket.approverUserId!.toLowerCase()) {
          return s['need_approval'] == true;
        }
      }
      if (ticket.hostOrganizationName != null &&
          ticket.hostOrganizationName!.isNotEmpty) {
        if (s['name']?.toString().toLowerCase() ==
                ticket.hostOrganizationName!.toLowerCase() ||
            s['Employee']?['Organization']?['name']?.toString().toLowerCase() ==
                ticket.hostOrganizationName!.toLowerCase()) {
          return s['need_approval'] == true;
        }
      }
      if (ticket.hostName != null && ticket.hostName!.isNotEmpty) {
        if (s['Employee']?['name']?.toString().toLowerCase() ==
            ticket.hostName!.toLowerCase()) {
          return s['need_approval'] == true;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isApprovalLoading.value &&
          controller.approvalTickets.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.approvalTickets.isEmpty) {
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
                  'No invitation approval requests found.',
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel
          SizedBox(
            height: rh(context, () {
              final tickets = controller.approvalTickets;
              final list = tickets.length > 3
                  ? tickets.take(3).toList()
                  : tickets;
              if (list.isEmpty) return 210.0;
              final listLength = list.length;
              final currentIndex = _currentPage.value % listLength;
              final currentTicket = list[currentIndex];

              final isPending =
                  currentTicket.approvalActorStatus?.toLowerCase() ==
                      'pending' ||
                  currentTicket.approvalStatus?.toLowerCase() == 'pending';
              final bool hasButtons =
                  isPending && _checkNeedApproval(currentTicket);
              if (hasButtons) {
                return 300.0;
              } else {
                return currentTicket.approvedAt != null ? 245.0 : 210.0;
              }
            }()),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int index) {
                _currentPage.value = index;
              },
              itemBuilder: (context, index) {
                final tickets = controller.approvalTickets;
                final list = tickets.length > 3
                    ? tickets.take(3).toList()
                    : tickets;
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
          if (controller.approvalTickets.length > 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.approvalTickets.length > 3
                    ? 3
                    : controller.approvalTickets.length,
                (index) {
                  final listLength = controller.approvalTickets.length > 3
                      ? 3
                      : controller.approvalTickets.length;
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

          // More Approval button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Get.to(() => const ApprovalPage());
              },
              icon: Icon(Icons.arrow_forward_rounded, size: rw(context, 16)),
              label: const Text('Show More Approval'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary500,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: rfs(context, 13),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildApprovalCard(BuildContext context, ApprovalTicketModel ticket, int no) {
    final start = ticket.visitorPeriodStart;
    final end = ticket.visitorPeriodEnd;
    final startStr = start != null
        ? DateFormat('dd MMM yy HH:mm').format(start)
        : '-';
    final endStr = end != null
        ? DateFormat('dd MMM yy HH:mm').format(end)
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

    return Container(
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
                    '$no',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: rfs(context, 11),
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
                      fontSize: rfs(context, 14),
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
                      fontSize: rfs(context, 10),
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
                vSpace(context, 8),
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

          // Actions if pending
          if (isPending && _checkNeedApproval(ticket)) ...[
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
                      onPressed: () {
                        if (ticket.approvalTicketId != null) {
                          controller.rejectTicketAction(
                            ticket.approvalTicketId!,
                            ticket.actorId ?? '',
                          );
                        }
                      },
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (ticket.approvalTicketId != null) {
                          controller.approveTicketAction(
                            ticket.approvalTicketId!,
                            ticket.actorId ?? '',
                          );
                        }
                      },
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
            Container(height: 1, color: const Color(0xFFF0F0F0)),
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
          ] else if (isRejected && ticket.approvedAt != null) ...[
            Container(height: 1, color: const Color(0xFFF0F0F0)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                rw(context, 16),
                rh(context, 8),
                rw(context, 16),
                rh(context, 10),
              ),
              child: Text(
                'Ditolak: ${DateFormat('dd MMM yyyy, HH:mm').format(ticket.approvedAt!)}',
                style: TextStyle(
                  fontSize: rfs(context, 11),
                  color: const Color(0xFFC62828),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: rw(context, 13), color: Colors.grey.shade400),
        hSpace(context, 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 10),
                  color: Colors.grey.shade500,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
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
