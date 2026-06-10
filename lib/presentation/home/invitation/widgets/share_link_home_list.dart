import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../controller/invitation_controller.dart';
import '../send_invitation_page.dart';
import 'share_link_card.dart';
import 'share_link_detail_modal.dart';

class ShareLinkHomeList extends StatefulWidget {
  const ShareLinkHomeList({super.key});

  @override
  State<ShareLinkHomeList> createState() => _ShareLinkHomeListState();
}

class _ShareLinkHomeListState extends State<ShareLinkHomeList> {
  final InvitationController controller =
      Get.isRegistered<InvitationController>()
      ? Get.find<InvitationController>()
      : Get.put(InvitationController());
  Timer? _timer;
  Timer? _carouselTimer;
  final PageController _pageController = PageController(
    viewportFraction: 1.0,
    initialPage: 1200,
  );
  final RxInt _currentPage = 1200.obs;

  Worker? _listWorker;
  Worker? _dateWorker;

  DateTime? _parseShareLinkDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      String normalized = dateStr;
      if (!normalized.endsWith('Z') && !normalized.contains('+')) {
        normalized = '${normalized.replaceFirst(' ', 'T')}Z';
      }
      return DateTime.parse(normalized).toLocal();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Always fetch newest 3 after frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardShareLinks();
    });

    void updateCarousel() {
      final selectedDate = controller.selectedDashboardDate.value;
      final filtered = controller.dashboardShareLinks.where((item) {
        final dateStr = item['visitor_period_start']?.toString() ??
            item['created_at']?.toString() ??
            item['expired_at']?.toString();
        final date = _parseShareLinkDate(dateStr);
        if (date == null) return false;
        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      }).toList();
      if (_pageController.hasClients && filtered.isNotEmpty) {
        final listLength = filtered.length > 3 ? 3 : filtered.length;
        final targetPage = 1200 - (1200 % listLength);
        _pageController.jumpToPage(targetPage);
        _currentPage.value = targetPage;
        _resetCarouselTimer();
      }
    }

    _listWorker = ever(controller.dashboardShareLinks, (_) => updateCarousel());
    _dateWorker = ever(controller.selectedDashboardDate, (_) => updateCarousel());

    // Start timer for live countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

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
    _timer?.cancel();
    _listWorker?.dispose();
    _dateWorker?.dispose();
    super.dispose();
  }

  // Delete dialog moved to ShareLinkDetailModal

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDashboardDate.value;
      final filteredShareLinks = controller.dashboardShareLinks.where((item) {
        final dateStr = item['visitor_period_start']?.toString() ??
            item['created_at']?.toString() ??
            item['expired_at']?.toString();
        final date = _parseShareLinkDate(dateStr);
        if (date == null) return false;
        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      }).toList();

      // Sort descending by date (newest first on that date)
      filteredShareLinks.sort((a, b) {
        final dateStrA = a['visitor_period_start']?.toString() ??
            a['created_at']?.toString() ??
            a['expired_at']?.toString();
        final dateStrB = b['visitor_period_start']?.toString() ??
            b['created_at']?.toString() ??
            b['expired_at']?.toString();
        final dateA = _parseShareLinkDate(dateStrA);
        final dateB = _parseShareLinkDate(dateStrB);
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      final list = filteredShareLinks.length > 3
          ? filteredShareLinks.take(3).toList()
          : filteredShareLinks;

      if (controller.isShareLinkLoading.value &&
          controller.dashboardShareLinks.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(rw(context, 20.0)),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      if (filteredShareLinks.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(rw(context, 20.0)),
            child: Column(
              children: [
                Icon(
                  Icons.link_off,
                  size: rw(context, 48),
                  color: Colors.grey.shade300,
                ),
                vSpace(context, 8),
                Text(
                  'No share links found for this date.',
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
          // Carousel
          SizedBox(
            height: rh(context, 220), // Height for the card and shadow
            child: PageView.builder(
              controller: _pageController,
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
                  child: ShareLinkCard(
                    item: item,
                    no: realIndex + 1,
                    onTap: () => ShareLinkDetailModal.show(context, item),
                  ),
                );
              },
            ),
          ),
          vSpace(context, 12),

          // Carousel Indicators
          if (filteredShareLinks.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                filteredShareLinks.length > 3
                    ? 3
                    : filteredShareLinks.length,
                (index) {
                  final listLength = filteredShareLinks.length > 3
                      ? 3
                      : filteredShareLinks.length;
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

          // More Link button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Get.to(() => const SendInvitationPage(initialTab: 1));
              },
              icon: Icon(Icons.arrow_forward_rounded, size: rw(context, 16)),
              label: const Text('Show More Link'),
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

  // UI components extracted to ShareLinkCard and ShareLinkDetailModal
}
