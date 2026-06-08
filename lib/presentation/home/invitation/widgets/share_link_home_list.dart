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

  @override
  void initState() {
    super.initState();
    // Always fetch newest 3 after frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardShareLinks();
    });

    // Reset to start when list changes (focused on new item)
    _listWorker = ever(controller.dashboardShareLinks, (list) {
      if (_pageController.hasClients && list.isNotEmpty) {
        final listLength = list.length > 3 ? 3 : list.length;
        // Jump to the nearest multiple of listLength near 1200 so that (page % listLength) == 0
        final targetPage = 1200 - (1200 % listLength);
        _pageController.jumpToPage(targetPage);
        _currentPage.value = targetPage;
        _resetCarouselTimer(); // Reset the timer so it stays on item 1 longer
      }
    });

    // Start timer for live countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted &&
          controller.dashboardShareLinks.isNotEmpty &&
          _pageController.hasClients) {
        // Only slide if there is more than 1 item
        final listLength = controller.dashboardShareLinks.length > 3
            ? 3
            : controller.dashboardShareLinks.length;
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
    _timer?.cancel();
    _listWorker?.dispose();
    super.dispose();
  }

  // Delete dialog moved to ShareLinkDetailModal

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isShareLinkLoading.value &&
          controller.dashboardShareLinks.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(rw(context, 20.0)),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      if (controller.dashboardShareLinks.isEmpty) {
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
                  'No share links found',
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
          // Header row: title only
          Text(
            'List Share Link',
            style: TextStyle(
              fontSize: rfs(context, 15),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          vSpace(context, 12),

          // Carousel
          SizedBox(
            height: rh(context, 205), // Height for the card and shadow
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int index) {
                _currentPage.value = index;
              },
              itemBuilder: (context, index) {
                final links = controller.dashboardShareLinks;
                // Only take the first 3 items for the carousel logic as per requirement
                final list = links.length > 3 ? links.take(3).toList() : links;
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
          if (controller.dashboardShareLinks.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.dashboardShareLinks.length > 3
                    ? 3
                    : controller.dashboardShareLinks.length,
                (index) {
                  final listLength = controller.dashboardShareLinks.length > 3
                      ? 3
                      : controller.dashboardShareLinks.length;
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
