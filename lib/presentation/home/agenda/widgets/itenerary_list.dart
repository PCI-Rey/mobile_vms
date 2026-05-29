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
          // Header
          Text(
            'List Approval',
            style: TextStyle(
              fontSize: rfs(context, 15),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          vSpace(context, 12),

          // Carousel
          SizedBox(
            height: rh(context, () {
              final tickets = controller.approvalTickets;
              final list = tickets.length > 3
                  ? tickets.take(3).toList()
                  : tickets;
              if (list.isEmpty) return 165.0;
              final listLength = list.length;
              final currentIndex = _currentPage.value % listLength;
              final currentTicket = list[currentIndex];

              final isPending =
                  currentTicket.approvalActorStatus?.toLowerCase() ==
                      'pending' ||
                  currentTicket.approvalStatus?.toLowerCase() == 'pending';
              final bool hasButtons =
                  isPending && _checkNeedApproval(currentTicket);
              return hasButtons ? 245.0 : 165.0;
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
                  child: _buildApprovalCard(context, ticket),
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

  Widget _buildApprovalCard(BuildContext context, ApprovalTicketModel ticket) {
    final startStr = ticket.visitorPeriodStart != null
        ? DateFormat(
            'dd MMM yyyy, HH:mm',
          ).format(ticket.visitorPeriodStart!.toLocal())
        : '-';
    final endStr = ticket.visitorPeriodEnd != null
        ? DateFormat('HH:mm').format(ticket.visitorPeriodEnd!.toLocal())
        : '-';
    final period = '$startStr - $endStr';

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

    Color badgeColor = Colors.orange.shade50;
    Color textColor = Colors.orange.shade800;
    String statusLabel = 'Pending';

    if (isApproved) {
      badgeColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      statusLabel = 'Approved';
    } else if (isRejected) {
      badgeColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      statusLabel = 'Rejected';
    }

    return Container(
      padding: EdgeInsets.all(rw(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 16)),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: rw(context, 8),
            offset: Offset(0, rh(context, 4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket.visitorTypeName ?? 'Visitor Invitation',
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 10),
                  vertical: rh(context, 4),
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: rfs(context, 10),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          vSpace(context, 8),

          // Agenda / Event Name
          Text(
            ticket.agenda ?? 'Meeting',
            style: TextStyle(
              fontSize: rfs(context, 16),
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          vSpace(context, 8),

          // Details row
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: rw(context, 16),
                color: Colors.grey.shade600,
              ),
              hSpace(context, 6),
              Expanded(
                child: Text(
                  '${ticket.hostName ?? "Unknown Host"} (${ticket.hostOrganizationName ?? "SPU"})',
                  style: TextStyle(
                    fontSize: rfs(context, 12.5),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          vSpace(context, 6),

          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: rw(context, 16),
                color: Colors.grey.shade600,
              ),
              hSpace(context, 6),
              Expanded(
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: rfs(context, 12.5),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          // Actions if pending
          if (isPending && _checkNeedApproval(ticket)) ...[
            vSpace(context, 16),
            const Divider(height: 1, color: Color(0xFFF2F2F2)),
            vSpace(context, 12),
            Row(
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
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(
                        color: Colors.redAccent,
                        width: 1.5,
                      ),
                      padding: EdgeInsets.symmetric(vertical: rh(context, 12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: rfs(context, 13.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                hSpace(context, 12),
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
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: rh(context, 12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: rfs(context, 13.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
