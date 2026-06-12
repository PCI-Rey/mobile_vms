import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../data/models/access_pass_model.dart';
import '../controller/invitation_controller.dart';
import '../send_invitation_page.dart';

class InvitationHomeList extends StatefulWidget {
  const InvitationHomeList({super.key});

  @override
  State<InvitationHomeList> createState() => _InvitationHomeListState();
}

class _InvitationHomeListState extends State<InvitationHomeList> {
  final InvitationController controller =
      Get.isRegistered<InvitationController>()
      ? Get.find<InvitationController>()
      : Get.put(InvitationController());

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
    // Fetch ongoing invitations if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.ongoingInvitations.isEmpty) {
        controller.fetchOngoingInvitations();
      }
    });

    void updateCarousel() {
      final selectedDate = controller.selectedDashboardDate.value;
      final filtered = controller.ongoingInvitations.where((item) {
        return item.visitorPeriodStart.year == selectedDate.year &&
            item.visitorPeriodStart.month == selectedDate.month &&
            item.visitorPeriodStart.day == selectedDate.day;
      }).toList();
      if (_pageController.hasClients && filtered.isNotEmpty) {
        final listLength = filtered.length > 3 ? 3 : filtered.length;
        final targetPage = 1200 - (1200 % listLength);
        _pageController.jumpToPage(targetPage);
        _currentPage.value = targetPage;
      }
    }

    _listWorker = ever(controller.ongoingInvitations, (_) => updateCarousel());
    _dateWorker = ever(controller.selectedDashboardDate, (_) => updateCarousel());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listWorker?.dispose();
    _dateWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDashboardDate.value;
      final filtered = controller.ongoingInvitations.where((item) {
        return item.visitorPeriodStart.year == selectedDate.year &&
            item.visitorPeriodStart.month == selectedDate.month &&
            item.visitorPeriodStart.day == selectedDate.day;
      }).toList();

      // Sort Active first, then newest first
      final now = DateTime.now();
      filtered.sort((a, b) {
        final aExpired = now.isAfter(a.visitorPeriodEnd);
        final bExpired = now.isAfter(b.visitorPeriodEnd);
        if (aExpired != bExpired) {
          return aExpired ? 1 : -1;
        }
        return b.visitorPeriodStart.compareTo(a.visitorPeriodStart);
      });

      final list = filtered.length > 3 ? filtered.take(3).toList() : filtered;

      if (controller.isLoading.value && controller.ongoingInvitations.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(rw(context, 20.0)),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      if (filtered.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(rw(context, 20.0)),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: rw(context, 48),
                  color: Colors.grey.shade300,
                ),
                vSpace(context, 8),
                Text(
                  'No invitations found for this date.',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: rfs(context, 12),
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
          SizedBox(
            height: rh(context, 150),
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
                final item = list[realIndex];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 2),
                    vertical: rh(context, 4),
                  ),
                  child: _buildInvitationCard(item, realIndex + 1),
                );
              },
            ),
          ),
          vSpace(context, 12),

          // Indicators
          if (filtered.length > 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                filtered.length > 3 ? 3 : filtered.length,
                (index) {
                  final listLength = filtered.length > 3 ? 3 : filtered.length;
                  final isActive = (_currentPage.value % listLength) == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: rw(context, 4)),
                    height: rw(context, 6),
                    width: isActive ? rw(context, 16) : rw(context, 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary500 : Colors.grey.shade300,
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

  Widget _buildInvitationCard(AccessPassModel item, int no) {
    final now = DateTime.now();
    final isExpired = item.visitorPeriodEnd.isBefore(now);
    final String jenis;
    final Color jenisColor;

    if (item.visitorStatus.isEmpty && item.flow.isEmpty) {
      jenis = 'Invitation';
      jenisColor = const Color(0xFF6D4C41);
    } else {
      // Use flow field to determine type badge
      final lowerFlow = item.flow.toLowerCase();
      if (lowerFlow == 'quickaccessvisit') {
        jenis = 'Quick Access';
        jenisColor = const Color(0xFFD81B60);
      } else if (lowerFlow == 'praregister') {
        jenis = 'Praregis';
        jenisColor = const Color(0xFF00B0FF);
      } else if (lowerFlow == 'invitation') {
        jenis = 'Invitation';
        jenisColor = const Color(0xFF6D4C41);
      } else {
        // Fallback to transaction_status
        final lowerStatus = item.visitorStatus.toLowerCase();
        if (lowerStatus == 'available') {
          jenis = 'Available';
          jenisColor = const Color(0xFF8E24AA);
        } else if (lowerStatus == 'pending') {
          jenis = 'Pending';
          jenisColor = const Color(0xFFFB8C00);
        } else if (lowerStatus == 'undercreated') {
          jenis = 'Under Created';
          jenisColor = const Color(0xFF546E7A);
        } else if (lowerStatus == 'checkin') {
          jenis = 'Checkin';
          jenisColor = const Color(0xFF00897B);
        } else if (lowerStatus == 'checkout') {
          jenis = 'Checkout';
          jenisColor = const Color(0xFF3949AB);
        } else if (lowerStatus == 'reject' || lowerStatus == 'rejected' || lowerStatus == 'denied') {
          jenis = 'Rejected';
          jenisColor = const Color(0xFFE53935);
        } else if (item.visitorStatus.isNotEmpty) {
          jenis = item.visitorStatus[0].toUpperCase() + item.visitorStatus.substring(1);
          jenisColor = const Color(0xFF546E7A);
        } else {
          jenis = 'Invitation';
          jenisColor = const Color(0xFF6D4C41);
        }
      }
    }

    return GestureDetector(
      onTap: () => showInvitationDetailSheet(context, item),
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
                      item.agenda.isEmpty ? '-' : item.agenda,
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
                      color: jenisColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                      border: Border.all(color: jenisColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      jenis,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: jenisColor,
                      ),
                    ),
                  ),
                  hSpace(context, 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 8),
                      vertical: rh(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: isExpired ? const Color(0xFFE53935) : const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                    ),
                    child: Text(
                      isExpired ? 'Expired' : 'Active',
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                          item.visitorTypeName.isEmpty ? '-' : item.visitorTypeName,
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.person_outline,
                          'Host',
                          item.hostName.isEmpty ? '-' : item.hostName,
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
                          DateFormat('dd MMMM yyyy, HH:mm').format(item.visitorPeriodStart),
                        ),
                      ),
                      hSpace(context, 8),
                      Expanded(
                        child: _buildCardField(
                          context,
                          Icons.logout_outlined,
                          'Period End',
                          DateFormat('dd MMMM yyyy, HH:mm').format(item.visitorPeriodEnd),
                          color: isExpired ? Colors.red.shade600 : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                  fontSize: rfs(context, 11),
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
