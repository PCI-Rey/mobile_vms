// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../presentation/home/alarm/list_alarm_page.dart';
import 'alarm/controller/alarm_controller.dart';
import '../../presentation/notification/notification_page.dart';
import '../../presentation/profile/profile_page.dart';

import '../../presentation/home/invitation/send_invitation_page.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';

import '../../core/core.dart';
import 'access_pass/access_pass_page.dart';
import 'approval/approval_page.dart';
import '../parking/as_guest/guest_parking_page.dart';
import 'today_activity_page.dart';
import 'new_visitor_page.dart';
import 'today_summary_page.dart';
import 'invitation/controller/invitation_controller.dart';
import 'invitation/widgets/create_share_link_dialog.dart';
import 'invitation/widgets/create_quick_access_dialog.dart';
import 'visitor_request/add_pra_registration_dialog.dart';
import '../../data/models/access_pass_model.dart';
import '../../data/models/approval_ticket_model.dart';
import '../../data/datasources/api_service.dart';
import '../../data/datasources/hive_service.dart';
import '../dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey _bellKey = GlobalKey();
  late AnimationController _bellAnimationController;
  late Animation<double> _bellScaleAnimation;
  late Animation<double> _bellRotateAnimation;
  final langCtrl = LanguageController.to;
  final InvitationController invitationController =
      Get.isRegistered<InvitationController>()
      ? Get.find<InvitationController>()
      : Get.put(InvitationController());

  bool _showBellRedDot = false;
  bool _isPageTransitionComplete = false;

  Worker? _approvalTicketsWorker;

  @override
  void initState() {
    super.initState();

    _bellAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bellScaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
        ]).animate(
          CurvedAnimation(
            parent: _bellAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _bellRotateAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.12), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.12, end: -0.12), weight: 25),
          TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.08), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.08, end: 0.0), weight: 25),
        ]).animate(
          CurvedAnimation(
            parent: _bellAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchSites();
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) {
            setState(() {
              _isPageTransitionComplete = true;
            });
            _checkAndShowPendingPopup(invitationController.approvalTickets);
          }
        });
      }
    });

    _approvalTicketsWorker = ever(invitationController.approvalTickets, (
      tickets,
    ) {
      if (mounted) {
        _checkAndShowPendingPopup(tickets);
      }
    });
  }

  Future<void> _prefetchSites() async {
    try {
      final hive = HiveService();
      final token = hive.getUser()?.token;
      if (token != null) {
        final api = ApiService();
        final response = await api.getSitesWithToken(token);
        if (response.data['status'] == 'success') {
          final collection = response.data['collection'] as List<dynamic>? ?? [];
          final newList = <Map<String, String>>[];
          for (var item in collection) {
            newList.add({
              'id': item['id']?.toString() ?? '',
              'name': item['name']?.toString() ?? '',
            });
          }
          await hive.saveSites(newList);
          debugPrint('Sites pre-fetched and saved to Hive successfully.');
        }
      }
    } catch (e) {
      debugPrint('Error prefetching sites: $e');
    }
  }

  @override
  void dispose() {
    _bellAnimationController.dispose();
    _approvalTicketsWorker?.dispose();
    super.dispose();
  }

  void _checkAndShowPendingPopup(List<ApprovalTicketModel> tickets) {
    if (!_isPageTransitionComplete) return;
    if (invitationController.hasShownPendingPopup) return;

    List<ApprovalTicketModel> pendingTickets = tickets.where((t) {
      final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
      final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
      final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
      final isRejected = actorStatus == 'rejected' ||
          actorStatus == 'denied' ||
          ticketStatus == 'rejected' ||
          ticketStatus == 'denied';
      final isPending = !isApproved && !isRejected;
      return isPending;
    }).toList();

    // If we have postponed tickets (remind me again was pressed), only show those!
    if (invitationController.postponedTicketIds.isNotEmpty) {
      pendingTickets = pendingTickets.where((t) {
        final id = t.approvalTicketId ?? t.ticketId;
        return id != null &&
            invitationController.postponedTicketIds.contains(id);
      }).toList();
    }

    if (pendingTickets.isNotEmpty) {
      invitationController.hasShownPendingPopup = true;
      invitationController.postponedTicketIds.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPendingWarningDialog(pendingTickets);
        }
      });
    }
  }

  void _showPendingWarningDialog(List<ApprovalTicketModel> pendingTickets) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final currentTickets = List<ApprovalTicketModel>.from(pendingTickets);
        int currentPage = 0;
        bool hasPressedRemindMe = false;
        PageController? pageController;

        return StatefulBuilder(
          builder: (context, setState) {
            pageController ??= PageController(initialPage: currentPage);
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
              child: Stack(
                children: [
                  // Main White Box Container wrapped in padding to ensure X button is within Stack bounds for hit testing
                  Padding(
                    padding: const EdgeInsets.only(top: 12, right: 12),
                    child: Container(
                      width: rw(context, 370),
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 16),
                        vertical: rh(context, 20),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(context, 20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pending_actions_rounded,
                            size: rw(context, 44),
                            color: const Color(0xFFE65100), // Orange
                          ),
                          vSpace(context, 8),
                          Text(
                            'Pending Approval',
                            style: TextStyle(
                              fontSize: rfs(context, 18),
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          vSpace(context, 16),

                          // Carousel of Pending Tickets
                          SizedBox(
                            height: rh(context, 145),
                            child: PageView.builder(
                              key: ValueKey(
                                currentTickets.length,
                              ), // Rebuild PageView on item removal to avoid index mismatches
                              controller: pageController,
                              itemCount: currentTickets.length,
                              onPageChanged: (index) {
                                setState(() {
                                  currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final ticket = currentTickets[index];
                                invitationController.fetchVisitorNameForTicket(
                                  ticket,
                                );
                                final host = ticket.hostName ?? 'Unknown Host';
                                final agenda = ticket.agenda ?? 'Meeting';
                                final type =
                                    ticket.visitorTypeName ?? 'Visitor';
                                final start = ticket.visitorPeriodStart;
                                final startStr = start != null
                                    ? DateFormat(
                                        'dd MMMM yyyy, HH:mm',
                                      ).format(start)
                                    : '-';

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: rw(context, 4),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 12),
                                    vertical: rh(context, 12),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FB),
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 16),
                                    ),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // TikTok style avatar / icon
                                      Container(
                                        width: rw(context, 46),
                                        height: rw(context, 46),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.badge_outlined,
                                          color: AppColors.primary500,
                                          size: rw(context, 22),
                                        ),
                                      ),
                                      hSpace(context, 12),

                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Obx(() {
                                              final ticketId =
                                                  ticket.approvalTicketId ??
                                                  ticket.ticketId ??
                                                  '';
                                              final displayName =
                                                  invitationController
                                                      .ticketVisitorNames[ticketId] ??
                                                  host;
                                              return RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: rfs(context, 15),
                                                    color: Colors.black87,
                                                    height: 1.3,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: displayName,
                                                      style: TextStyle(
                                                        fontSize: rfs(
                                                          context,
                                                          15,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          ' requested approval for ',
                                                      style: TextStyle(
                                                        fontSize: rfs(
                                                          context,
                                                          15,
                                                        ),
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: agenda,
                                                      style: TextStyle(
                                                        fontSize: rfs(
                                                          context,
                                                          15,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: '.',
                                                      style: TextStyle(
                                                        fontSize: rfs(
                                                          context,
                                                          15,
                                                        ),
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                            vSpace(context, 4),
                                            Text(
                                              type,
                                              style: TextStyle(
                                                fontSize: rfs(context, 13),
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            vSpace(context, 2),
                                            Text(
                                              startStr,
                                              style: TextStyle(
                                                fontSize: rfs(context, 12),
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          vSpace(context, 10),

                          // Dots Indicators
                          if (currentTickets.length > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                currentTickets.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: currentPage == index ? 12 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: currentPage == index
                                        ? AppColors.primary500
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          vSpace(context, 14),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    final ticket = currentTickets[currentPage];
                                    final ticketId =
                                        ticket.approvalTicketId ??
                                        ticket.ticketId ??
                                        '';
                                    _runFlyingAnimation(setRedDot: true);

                                    setState(() {
                                      hasPressedRemindMe = true;
                                      invitationController.startReminderTimer(
                                        30,
                                        ticketId,
                                        () {
                                          invitationController
                                              .fetchApprovalTickets();
                                        },
                                      );

                                      currentTickets.removeAt(currentPage);
                                      if (currentPage >=
                                          currentTickets.length) {
                                        currentPage = currentTickets.length - 1;
                                      }
                                      if (currentPage < 0) currentPage = 0;
                                      pageController = PageController(
                                        initialPage: currentPage,
                                      );
                                    });

                                    if (currentTickets.isEmpty) {
                                      Navigator.of(dialogCtx).pop();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.grey700,
                                    side: const BorderSide(
                                      color: AppColors.grey400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        rw(context, 12),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: rh(context, 10),
                                    ),
                                  ),
                                  child: Text(
                                    'Remind me again',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: rfs(context, 13.5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              hSpace(context, 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _runFlyingAnimation(setRedDot: false);

                                    setState(() {
                                      currentTickets.removeAt(currentPage);
                                      if (currentPage >=
                                          currentTickets.length) {
                                        currentPage = currentTickets.length - 1;
                                      }
                                      if (currentPage < 0) currentPage = 0;
                                      pageController = PageController(
                                        initialPage: currentPage,
                                      );
                                    });

                                    if (currentTickets.isEmpty) {
                                      Navigator.of(dialogCtx).pop();
                                      if (!hasPressedRemindMe) {
                                        invitationController
                                            .cancelReminderTimer();
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary500,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        rw(context, 12),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: rh(context, 10),
                                    ),
                                  ),
                                  child: Text(
                                    'Yes, I Know',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: rfs(context, 13.5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Close button 'x' outside the box at the top right (inside Stack bounds)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final isHomeTab = Dashboard.selectedIndex == 0;
                        this.setState(() {
                          _showBellRedDot = true;
                        });
                        Navigator.of(dialogCtx).pop();
                        if (isHomeTab) {
                          _bellAnimationController.forward(from: 0.0);
                        }
                      },
                      child: Container(
                        width: rw(context, 32),
                        height: rw(context, 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black87,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _runFlyingAnimation({required bool setRedDot}) {
    final isHomeTab = Dashboard.selectedIndex == 0;
    if (!isHomeTab) {
      if (setRedDot) {
        setState(() {
          _showBellRedDot = true;
        });
      }
      return;
    }

    final renderBox = _bellKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      if (setRedDot) {
        setState(() {
          _showBellRedDot = true;
        });
      }
      return;
    }

    final bellPosition = renderBox.localToGlobal(Offset.zero);
    final bellSize = renderBox.size;
    final bellCenter = Offset(
      bellPosition.dx + bellSize.width / 2,
      bellPosition.dy + bellSize.height / 2,
    );

    final screenSize = MediaQuery.of(context).size;
    final startPosition = Offset(screenSize.width / 2, screenSize.height / 2);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => FlyingIconAnimation(
        startOffset: startPosition,
        endOffset: bellCenter,
        onComplete: () {
          entry.remove();
          if (setRedDot) {
            setState(() {
              _showBellRedDot = true;
            });
            _bellAnimationController.forward(from: 0.0);
          }
        },
      ),
    );

    Overlay.of(context).insert(entry);
  }

  Future<void> _selectDateFromCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: invitationController.selectedDashboardDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _blue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      if (normalized != invitationController.selectedDashboardDate.value) {
        invitationController.selectedDashboardDate.value = normalized;
      }
    }
  }

  // Design constants
  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0D47A1);
  static const _bgPage = Color(0xFFF8FAFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // 1. Full background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_blue, _blueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // --- FIXED HEADER ---
                _buildHeader(context),

                // --- SCROLLABLE BODY ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait([
                        invitationController.fetchOngoingInvitations(
                          clearFilters: true,
                        ),
                        invitationController.fetchShareLinks(resetPage: true),
                        invitationController.fetchApprovalTickets(),
                        invitationController.fetchDashboardShareLinks(),
                        invitationController.fetchTodayActivities(),
                      ]);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Column(
                        children: [
                          vSpace(context, 24),
                          // --- MENU GRID ---
                          _buildMenuGrid(context),

                          vSpace(context, 32),

                          // --- BOTTOM CONTENT (SCHEDULE & AGENDA) ---
                          _buildBottomContent(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 24),
        vertical: rh(context, 8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Dashboard.state?.changeTab(2),
            child: CustomCircleImage(
              image: Assets.images.avaPerson1.image(fit: BoxFit.cover),
              size: rw(context, 48),
              scale: 1.5,
            ),
          ),
          hSpace(context, 16),
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'welcome'.tr,
                  style: TextStyle(
                    fontSize: rfs(context, 22),
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Obx(
                  () => Text(
                    UserController.to.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: rfs(context, 18),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLanguageDropdown(context),
        hSpace(context, 12),
        GestureDetector(
          key: _bellKey,
          onTap: () {
            setState(() {
              _showBellRedDot = false;
            });
            context.push(const NotificationPage());
          },
          child: ScaleTransition(
            scale: _bellScaleAnimation,
            child: RotationTransition(
              turns: _bellRotateAnimation,
              child: Container(
                padding: EdgeInsets.all(rw(context, 9)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: rw(context, 22),
                    ),
                    Obx(() {
                      final hasUnread =
                          _showBellRedDot ||
                          invitationController.unreadTicketIds.isNotEmpty;
                      if (!hasUnread) return const SizedBox.shrink();
                      return Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          width: rw(context, 7),
                          height: rw(context, 7),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Obx(() {
      final isId = langCtrl.selectedLang.value == 'id';
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(rw(context, 20)),
          color: Colors.white.withValues(alpha: 0.18),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 10),
          vertical: rh(context, 2),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: isId ? 'id' : 'en',
            icon: Icon(
              Icons.arrow_drop_down,
              size: rw(context, 16),
              color: Colors.white,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(rw(context, 10)),
            style: TextStyle(
              color: Colors.white,
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.w600,
            ),
            isDense: true,
            onChanged: (v) {
              if (v != null) langCtrl.changeLanguage(v);
            },
            items: const [
              DropdownMenuItem(
                value: 'en',
                child: Text(
                  '🇬🇧 ENG',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'id',
                child: Text(
                  '🇮🇩 ID',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
            selectedItemBuilder: (_) => [
              Text(
                '🇬🇧 ENG',
                style: TextStyle(
                  fontSize: rfs(context, 13),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '🇮🇩 ID',
                style: TextStyle(
                  fontSize: rfs(context, 13),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Obx(() {
      langCtrl.selectedLang.value; // Track changes

      final List<Map<String, dynamic>> items = [
        {
          'label': 'access_pass'.tr,
          'icon': Icons.badge_outlined,
          'bgColor': const Color(0xFFE8F1FD),
          'iconColor': const Color(0xFF1976D2),
          'onTap': () {
            // Show loading overlay
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (loadingCtx) =>
                  const Center(child: CircularProgressIndicator()),
            );

            Future.microtask(() async {
              try {
                // Ensure parent transactions list is populated
                if (invitationController.allRawVisitors.isEmpty) {
                  await invitationController.fetchOngoingInvitations(
                    isSilent: true,
                  );
                }

                final String currentUserName = UserController.to.fullName
                    .toLowerCase()
                    .trim();
                final List<AccessPassModel> employeePasses = [];
                final DateTime now = DateTime.now();

                // Filter parent transactions that are not expired yet
                final activeParents = invitationController.allRawVisitors.where(
                  (parent) {
                    return parent.visitorPeriodEnd.isAfter(now);
                  },
                ).toList();

                // Fetch sub-visitors in parallel for active parent transactions
                final List<Future<void>> fetchFutures = activeParents.map((
                  parent,
                ) async {
                  final String parentId = parent.id;
                  if (parentId.isEmpty) return;

                  final visitorsList = await invitationController
                      .fetchTransactionVisitors(parentId);
                  for (var visitorMap in visitorsList) {
                    final visitorName = (visitorMap['visitor_name'] ?? '')
                        .toString()
                        .toLowerCase()
                        .trim();
                    if (visitorName.isNotEmpty &&
                        (visitorName.contains('endru') ||
                            (currentUserName.isNotEmpty &&
                                visitorName.contains(currentUserName)))) {
                      final model = AccessPassModel.fromJson(visitorMap);

                      // Merge sub-visitor details with parent transaction details
                      final mergedModel = AccessPassModel(
                        id: model.id.isEmpty ? parent.id : model.id,
                        agenda: model.agenda.isEmpty
                            ? parent.agenda
                            : model.agenda,
                        initialTrxCode: model.initialTrxCode.isEmpty
                            ? parent.initialTrxCode
                            : model.initialTrxCode,
                        host: model.host.isEmpty ? parent.host : model.host,
                        isGroup: parent.isGroup,
                        groupName: model.groupName.isEmpty
                            ? parent.groupName
                            : model.groupName,
                        groupCode: parent.groupCode,
                        visitorPeriodStart: parent.visitorPeriodStart,
                        visitorPeriodEnd: parent.visitorPeriodEnd,
                        visitorNumber: model.visitorNumber.isNotEmpty
                            ? model.visitorNumber
                            : parent.visitorNumber,
                        visitorCode: model.visitorCode.isEmpty
                            ? parent.visitorCode
                            : model.visitorCode,
                        invitationCode: model.invitationCode.isEmpty
                            ? parent.invitationCode
                            : model.invitationCode,
                        visitorStatus: model.visitorStatus.isEmpty
                            ? parent.visitorStatus
                            : model.visitorStatus,
                        sitePlaceName: model.sitePlaceName.isEmpty
                            ? parent.sitePlaceName
                            : model.sitePlaceName,
                        hostName: model.hostName.isEmpty
                            ? parent.hostName
                            : model.hostName,
                        parkingSlot: model.parkingSlot.isEmpty
                            ? parent.parkingSlot
                            : model.parkingSlot,
                        parkingArea: model.parkingArea.isEmpty
                            ? parent.parkingArea
                            : model.parkingArea,
                        vehiclePlateNumber: model.vehiclePlateNumber.isEmpty
                            ? parent.vehiclePlateNumber
                            : model.vehiclePlateNumber,
                        vehicleType: model.vehicleType.isEmpty
                            ? parent.vehicleType
                            : model.vehicleType,
                        isDriving: model.isDriving,
                        tz: model.tz.isEmpty ? parent.tz : model.tz,
                        siteId: model.siteId.isEmpty
                            ? parent.siteId
                            : model.siteId,
                        sitePlaceId: (model.sitePlaceId ?? '').isEmpty
                            ? parent.sitePlaceId
                            : model.sitePlaceId,
                        visitorName:
                            (visitorMap['visitor_name'] ?? '')
                                .toString()
                                .isNotEmpty
                            ? (visitorMap['visitor_name'] ?? '').toString()
                            : UserController.to.fullName,
                        isPraregisterDone: model.isPraregisterDone,
                        visitorRole: model.visitorRole.isEmpty
                            ? parent.visitorRole
                            : model.visitorRole,
                        approvalStatus: model.approvalStatus.isEmpty
                            ? parent.approvalStatus
                            : model.approvalStatus,
                        visitorTypeName: model.visitorTypeName.isEmpty
                            ? parent.visitorTypeName
                            : model.visitorTypeName,
                        visitorTypeId: model.visitorTypeId.isEmpty
                            ? parent.visitorTypeId
                            : model.visitorTypeId,
                        invitedByName: model.invitedByName.isEmpty
                            ? parent.invitedByName
                            : model.invitedByName,
                        invitedBy: model.invitedBy.isEmpty
                            ? parent.invitedBy
                            : model.invitedBy,
                        hostOrganizationName: model.hostOrganizationName.isEmpty
                            ? parent.hostOrganizationName
                            : model.hostOrganizationName,
                        flow: model.flow.isEmpty ? parent.flow : model.flow,
                        visitorOrganizationName:
                            model.visitorOrganizationName.isEmpty
                            ? parent.visitorOrganizationName
                            : model.visitorOrganizationName,
                        visitorPhone: model.visitorPhone.isEmpty
                            ? parent.visitorPhone
                            : model.visitorPhone,
                        visitorEmail: model.visitorEmail.isEmpty
                            ? parent.visitorEmail
                            : model.visitorEmail,
                        visitorIdentityId: model.visitorIdentityId.isEmpty
                            ? parent.visitorIdentityId
                            : model.visitorIdentityId,
                        receiverName: model.receiverName.isEmpty
                            ? parent.receiverName
                            : model.receiverName,
                        receiverEmail: model.receiverEmail.isEmpty
                            ? parent.receiverEmail
                            : model.receiverEmail,
                        receiverPhone: model.receiverPhone.isEmpty
                            ? parent.receiverPhone
                            : model.receiverPhone,
                        canTrackBle: model.canTrackBle,
                        canAccess: model.canAccess,
                      );

                      if (!employeePasses.any(
                        (item) => item.id == mergedModel.id,
                      )) {
                        employeePasses.add(mergedModel);
                      }
                    }
                  }
                }).toList();

                await Future.wait(fetchFutures);

                // Sort employeePasses so that active passes are first, and sorted by visitorPeriodStart descending (newest first)
                employeePasses.sort((a, b) {
                  final bool aExpired = now.isAfter(a.visitorPeriodEnd);
                  final bool bExpired = now.isAfter(b.visitorPeriodEnd);
                  if (aExpired != bExpired) {
                    return aExpired ? 1 : -1;
                  }
                  return b.visitorPeriodStart.compareTo(a.visitorPeriodStart);
                });

                // Dismiss loading overlay
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (employeePasses.isEmpty) {
                  Get.snackbar(
                    'Access Pass',
                    'No active access pass found for this employee.',
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                } else {
                  showAccessPassDialog(context: context, items: employeePasses);
                }
              } catch (e) {
                // Dismiss loading overlay on error
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                debugPrint('Error loading access passes: $e');
              }
            });
          },
        },
        {
          'label': 'invitation'.tr,
          'icon': Icons.calendar_month_outlined,
          'bgColor': const Color(0xFFEAF3DE),
          'iconColor': const Color(0xFF3B6D11),
          'onTap': () => context.push(const SendInvitationPage()),
        },
        {
          'label': 'approval'.tr,
          'icon': Icons.fact_check_outlined,
          'bgColor': const Color(0xFFFFF3E0),
          'iconColor': const Color(0xFFE65100),
          'onTap': () => context.push(const ApprovalPage()),
        },
        {
          'label': 'parking'.tr,
          'icon': Icons.local_parking_rounded,
          'bgColor': const Color(0xFFEDE7F6),
          'iconColor': const Color(0xFF5E35B1),
          'onTap': () => context.push(const GuestParkingPage()),
        },
      ];

      return Container(
        margin: EdgeInsets.symmetric(horizontal: rw(context, 20)),
        padding: EdgeInsets.symmetric(
          vertical: rh(context, 24),
          horizontal: rw(context, 8),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(rw(context, 28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: rw(context, 20),
              offset: Offset(0, rh(context, 10)),
            ),
          ],
        ),
        child: Row(
          children: items
              .map((item) => Expanded(child: _buildMenuItem(context, item)))
              .toList(),
        ),
      );
    });
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    final boxSize = rw(context, 54);
    final iconSize = rw(context, 26);

    return InkWell(
      onTap: item['onTap'],
      borderRadius: BorderRadius.circular(rw(context, 16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: item['bgColor'],
              borderRadius: BorderRadius.circular(rw(context, 14)),
            ),
            child: Icon(item['icon'], color: item['iconColor'], size: iconSize),
          ),
          vSpace(context, 8),
          Text(
            item['label'],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: rfs(context, 12),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF444441),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    final String lang = Get.isRegistered<LanguageController>()
        ? LanguageController.to.selectedLang.value
        : 'id';
    try {
      return DateFormat(
        'EEEE, d MMMM yyyy',
        lang == 'id' ? 'id_ID' : 'en_US',
      ).format(date);
    } catch (e) {
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    }
  }

  Widget _buildBottomContent(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 36)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: rw(context, 15),
            offset: Offset(0, rh(context, -5)),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        rw(context, 24),
        rh(context, 32),
        rw(context, 24),
        rh(context, 40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Selection (New Premium Card with Left/Right navigation chevrons)
          Obx(() {
            final date = invitationController.selectedDashboardDate.value;
            final dateStr = _formatSelectedDate(date);
            return Row(
              children: [
                // Left Arrow Button
                GestureDetector(
                  onTap: () {
                    invitationController.selectedDashboardDate.value = date
                        .subtract(const Duration(days: 1));
                  },
                  child: Container(
                    padding: EdgeInsets.all(rw(context, 8)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.grey.shade700,
                      size: rw(context, 20),
                    ),
                  ),
                ),
                hSpace(context, 12),
                // Center Date Box
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDateFromCalendar(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: rh(context, 12),
                        horizontal: rw(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(context, 12)),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.black87,
                            size: rw(context, 18),
                          ),
                          hSpace(context, 8),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          hSpace(context, 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade500,
                            size: rw(context, 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                hSpace(context, 12),
                // Right Arrow Button
                GestureDetector(
                  onTap: () {
                    invitationController.selectedDashboardDate.value = date.add(
                      const Duration(days: 1),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(rw(context, 8)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade700,
                      size: rw(context, 20),
                    ),
                  ),
                ),
              ],
            );
          }),
          vSpace(context, 24),
          _buildSummaryCards(context),
          vSpace(context, 24),
          _buildQuickActions(context),
          vSpace(context, 24),
          _buildTodayActivity(context),
          vSpace(context, 24),
          _buildNewVisitor(context),
        ],
      ),
    );
  }

  Widget _buildTodayActivity(BuildContext context) {
    return Obx(() {
      final date = invitationController.selectedDashboardDate.value;
      final isId = langCtrl.selectedLang.value == 'id';

      final List<_ActivityItem> activities = [];

      for (final item in invitationController.todayActivities) {
        final dateStr = item['actionAt']?.toString() ?? item['createdAt']?.toString();
        DateTime timestamp = DateTime.now();
        if (dateStr != null) {
          try {
            String normalized = dateStr;
            final dotIndex = normalized.indexOf('.');
            if (dotIndex != -1) {
              final tIndex = normalized.indexOf('T', dotIndex);
              final zIndex = normalized.indexOf('Z', dotIndex);
              final plusIndex = normalized.indexOf('+', dotIndex);
              int endSubSeconds = normalized.length;
              if (zIndex != -1) endSubSeconds = zIndex;
              else if (plusIndex != -1) endSubSeconds = plusIndex;
              
              final subSecondsStr = normalized.substring(dotIndex + 1, endSubSeconds);
              if (subSecondsStr.length > 6) {
                final trimmed = subSecondsStr.substring(0, 6);
                final suffix = endSubSeconds < normalized.length ? normalized.substring(endSubSeconds) : '';
                normalized = '${normalized.substring(0, dotIndex)}.$trimmed$suffix';
              }
            }
            if (!normalized.endsWith('Z') && !normalized.contains('+')) {
              normalized = '${normalized}Z';
            }
            timestamp = DateTime.parse(normalized).toLocal();
          } catch (e) {
            debugPrint('Error parsing activity timestamp: $e');
          }
        }

        final String action = (item['action']?.toString() ?? '').toLowerCase();
        final String title;
        final IconData icon;
        final Color iconColor;
        final Color bgColor;

        if (action.contains('approve')) {
          title = isId ? 'Persetujuan disetujui' : 'Approval approved';
          icon = Icons.check_circle_outline;
          iconColor = const Color(0xFF43A047);
          bgColor = const Color(0xFFE8F5E9);
        } else if (action.contains('reject') || action.contains('deny')) {
          title = isId ? 'Persetujuan ditolak' : 'Approval rejected';
          icon = Icons.cancel_outlined;
          iconColor = const Color(0xFFD32F2F);
          bgColor = const Color(0xFFFFEBEE);
        } else if (action.contains('password')) {
          title = isId ? 'Ubah Kata Sandi' : 'Change Password';
          icon = Icons.lock_outline;
          iconColor = const Color(0xFF534AB7);
          bgColor = const Color(0xFFF3EEFE);
        } else {
          title = item['action']?.toString() ?? 'Activity';
          icon = Icons.info_outline;
          iconColor = const Color(0xFF1976D2);
          bgColor = const Color(0xFFE8F1FD);
        }

        final description = item['description']?.toString() ?? '';

        activities.add(
          _ActivityItem(
            title: title,
            description: description,
            timestamp: timestamp,
            icon: icon,
            iconColor: iconColor,
            bgColor: bgColor,
          ),
        );
      }

      // Sort activities descending by timestamp
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
      
      final String sectionHeaderTitle;
      if (isToday) {
        sectionHeaderTitle = isId ? 'Aktivitas Hari Ini' : 'Activity Today';
      } else if (isYesterday) {
        sectionHeaderTitle = isId ? 'Aktivitas Kemarin' : 'Activity Yesterday';
      } else {
        sectionHeaderTitle = isId ? 'Aktivitas' : 'Activity';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, sectionHeaderTitle),
          vSpace(context, 16),
          if (activities.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rh(context, 32)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 16)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: rw(context, 48),
                    color: Colors.grey.shade400,
                  ),
                  vSpace(context, 12),
                  Text(
                    isId ? 'Tidak ada aktivitas hari ini' : 'No activity today',
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 16)),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ...activities.take(3).map((activity) {
                    final isLast =
                        activities.indexOf(activity) ==
                        activities.take(3).length - 1;
                    return Column(
                      children: [
                        _buildActivityRow(context, activity),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.shade100,
                            indent: rw(context, 76),
                          ),
                      ],
                    );
                  }),
                  if (activities.length > 3) ...[
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey.shade100,
                    ),
                    TextButton(
                      onPressed: () => context.push(const TodayActivityPage()),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: rh(context, 14),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary500,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isId
                                ? 'Lihat Semua Aktivitas'
                                : 'See All Activities',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rfs(context, 13),
                            ),
                          ),
                          hSpace(context, 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: rw(context, 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildActivityRow(BuildContext context, _ActivityItem activity) {
    final timeStr = DateFormat('HH:mm').format(activity.timestamp);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(context, 44),
            height: rw(context, 44),
            decoration: BoxDecoration(
              color: activity.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity.icon,
              color: activity.iconColor,
              size: rw(context, 20),
            ),
          ),
          hSpace(context, 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13.5),
                    color: Colors.black87,
                  ),
                ),
                vSpace(context, 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          hSpace(context, 12),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: rfs(context, 12),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewVisitor(BuildContext context) {
    return Obx(() {
      final date = invitationController.selectedDashboardDate.value;
      final isId = langCtrl.selectedLang.value == 'id';

      final List<AccessPassModel> newVisitors = invitationController
          .getTodayVisitors();
      final sectionHeaderTitle = isId ? 'Visitor Terbaru' : 'New Visitor';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, sectionHeaderTitle),
          vSpace(context, 16),
          if (newVisitors.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rh(context, 32)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 16)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: rw(context, 48),
                    color: Colors.grey.shade400,
                  ),
                  vSpace(context, 12),
                  Text(
                    isId
                        ? 'Tidak ada visitor baru hari ini'
                        : 'No new visitors today',
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 16)),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ...newVisitors.take(3).map((visitor) {
                    final index = newVisitors.indexOf(visitor);
                    final isLast = index == newVisitors.take(3).length - 1;
                    return Column(
                      children: [
                        _buildVisitorRow(context, visitor, index),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.shade100,
                            indent: rw(context, 76),
                          ),
                      ],
                    );
                  }),
                  if (newVisitors.length > 3) ...[
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey.shade100,
                    ),
                    TextButton(
                      onPressed: () => context.push(const NewVisitorPage()),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: rh(context, 14),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary500,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isId
                                ? 'Lihat Semua Visitor'
                                : 'See All New Visitors',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rfs(context, 13),
                            ),
                          ),
                          hSpace(context, 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: rw(context, 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    });
  }

  Map<String, Color> _getBadgeColors(String status) {
    final lower = status.toLowerCase().trim();
    if (lower == 'checkin') {
      return {'bg': const Color(0xFFE8F5E9), 'text': const Color(0xFF2E7D32)};
    } else if (lower == 'checkout') {
      return {'bg': const Color(0xFFE8EAF6), 'text': const Color(0xFF283593)};
    } else if (lower == 'pending' || lower == 'waiting') {
      return {'bg': const Color(0xFFFFF3E0), 'text': const Color(0xFFEF6C00)};
    } else if (lower == 'reject' ||
        lower == 'rejected' ||
        lower == 'denied' ||
        lower == 'deny') {
      return {'bg': const Color(0xFFFFEBEE), 'text': const Color(0xFFC62828)};
    } else {
      // Active, Available, or others
      return {'bg': const Color(0xFFE0F7FA), 'text': const Color(0xFF006064)};
    }
  }

  String _displayStatus(String status) {
    final lowerStatus = status.toLowerCase().trim();
    if (lowerStatus == 'available') {
      return 'Available';
    } else if (lowerStatus == 'pending' || lowerStatus == 'waiting') {
      return 'Pending';
    } else if (lowerStatus == 'undercreated') {
      return 'Under Created';
    } else if (lowerStatus == 'checkin') {
      return 'Checked In';
    } else if (lowerStatus == 'checkout') {
      return 'Checked Out';
    } else if (lowerStatus == 'reject' ||
        lowerStatus == 'rejected' ||
        lowerStatus == 'denied' ||
        lowerStatus == 'deny') {
      return 'Rejected';
    } else if (lowerStatus == 'preregis' ||
        lowerStatus == 'praregis' ||
        lowerStatus == 'praregister') {
      return 'Praregis';
    } else if (lowerStatus == 'quickaccess') {
      return 'Quick Access';
    } else if (status.isNotEmpty) {
      return status[0].toUpperCase() + status.substring(1);
    }
    return 'Active';
  }

  Widget _buildVisitorRow(
    BuildContext context,
    AccessPassModel visitor,
    int index,
  ) {
    final timeStr = DateFormat('HH:mm').format(visitor.invitationCreatedAt ?? visitor.visitorPeriodStart);
    final badgeColors = _getBadgeColors(visitor.visitorStatus);
    final displayStatus = _displayStatus(visitor.visitorStatus);

    final initials = visitor.visitorName.trim().isNotEmpty
        ? visitor.visitorName.trim()[0].toUpperCase()
        : 'V';

    final colors = [
      const Color(0xFF1976D2), // Blue
      const Color(0xFF388E3C), // Green
      const Color(0xFFD32F2F), // Red
      const Color(0xFFF57C00), // Orange
      const Color(0xFF7B1FA2), // Purple
    ];
    final color = colors[index % colors.length];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rw(context, 44),
            height: rw(context, 44),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 16),
                ),
              ),
            ),
          ),
          hSpace(context, 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  visitor.visitorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13.5),
                    color: Colors.black87,
                  ),
                ),
                vSpace(context, 4),
                Text(
                  visitor.visitorOrganizationName.isEmpty
                      ? '-'
                      : visitor.visitorOrganizationName,
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          hSpace(context, 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 8),
                  vertical: rh(context, 4),
                ),
                decoration: BoxDecoration(
                  color: badgeColors['bg'],
                  borderRadius: BorderRadius.circular(rw(context, 20)),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    fontWeight: FontWeight.bold,
                    color: badgeColors['text'],
                  ),
                ),
              ),
              vSpace(context, 6),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: rfs(context, 11),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Obx(() {
      final date = invitationController.selectedDashboardDate.value;

      // 1. Today Summary
      final todaySummaryCount = invitationController.visitorTodayCount.value;

      final waitingApprovalCount = invitationController.approvalTickets.where((
        t,
      ) {
        final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
        final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
        final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
        final isRejected = actorStatus == 'rejected' ||
            actorStatus == 'denied' ||
            ticketStatus == 'rejected' ||
            ticketStatus == 'denied';
        final isPending = !isApproved && !isRejected;
        if (!isPending) return false;
        final itemDate = t.visitorPeriodStart;
        if (itemDate == null) return false;
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      }).length;

      // 3. Active Invitation
      final activeInvitationCount = invitationController.allRawVisitors.where((
        item,
      ) {
        if (item.flow.toLowerCase() == 'quickaccessvisit') return false;
        if (item.agenda.isEmpty &&
            item.hostName.isEmpty &&
            item.visitorTypeName.isEmpty)
          return false;
        final itemDate = item.visitorPeriodStart;
        if (itemDate.year != date.year ||
            itemDate.month != date.month ||
            itemDate.day != date.day)
          return false;
        if (item.visitorPeriodEnd.isBefore(DateTime.now())) return false;
        return true;
      }).length;

      // 4. Active Notification
      int notificationCount = 0;
      final user = UserController.to.user.value;
      bool isGuest = true;
      if (user != null) {
        final r = (user.roleAccess ?? 'guest').toLowerCase();
        if ([
          'operator',
          'employee',
          'admin',
          'superadmin',
          'staff',
        ].contains(r)) {
          isGuest = false;
        }
      }

      if (isGuest) {
        final alarmCtrl = Get.isRegistered<AlarmController>()
            ? Get.find<AlarmController>()
            : Get.put(AlarmController());
        notificationCount = alarmCtrl.alarms.where((alarm) {
          final itemDate = alarm.createdAt;
          return itemDate.year == date.year &&
              itemDate.month == date.month &&
              itemDate.day == date.day;
        }).length;
      } else {
        notificationCount = invitationController.approvalTickets.where((t) {
          final actorStatus = (t.approvalActorStatus ?? '').toLowerCase();
          final ticketStatus = (t.approvalStatus ?? '').toLowerCase();
          final isApproved = actorStatus == 'approved' || ticketStatus == 'approved';
          final isRejected = actorStatus == 'rejected' ||
              actorStatus == 'denied' ||
              ticketStatus == 'rejected' ||
              ticketStatus == 'denied';
          final isPending = !isApproved && !isRejected;
          if (!isPending) return false;
          final itemDate = t.visitorPeriodStart;
          if (itemDate == null) return false;
          return itemDate.year == date.year &&
              itemDate.month == date.month &&
              itemDate.day == date.day;
        }).length;
      }

      final now = DateTime.now();
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      return Column(
        children: [
          _buildSectionHeader(
            context,
            isToday ? 'Today Summary' : 'Summary',
            onShowMoreTap: () => context.push(const TodaySummaryPage()),
          ),
          vSpace(context, 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Visitor Today',
                  count: todaySummaryCount,
                  unit: 'People',
                  icon: Icons.people,
                  color: const Color(0xFF1976D2),
                  isLoading:
                      invitationController.isVisitorTodayLoading.value &&
                      invitationController.visitorTodayCount.value == 0,
                ),
              ),
              hSpace(context, 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Waiting Approval',
                  count: waitingApprovalCount,
                  unit: 'Request(s)',
                  icon: Icons.access_time,
                  color: const Color(0xFFF57C00),
                ),
              ),
            ],
          ),
          vSpace(context, 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Active Invitation',
                  count: activeInvitationCount,
                  unit: 'Invitation(s)',
                  icon: Icons.mail_outline,
                  color: const Color(0xFF43A047),
                ),
              ),
              hSpace(context, 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Active Notification',
                  count: notificationCount,
                  unit: 'Alarm(s)',
                  icon: Icons.notifications_none_rounded,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildQuickActions(BuildContext context) {
    return Obx(() {
      final isId = langCtrl.selectedLang.value == 'id';
      final sectionTitle = isId ? 'Aksi Cepat' : 'Quick Action';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, sectionTitle),
          vSpace(context, 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionItem(
                  context,
                  label: isId ? 'Buat Undangan' : 'Make Invitation',
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF3B6D11),
                  bgColor: const Color(0xFFEAF3DE),
                  onTap: () async {
                    if (!Get.isRegistered<InvitationController>()) {
                      Get.put(InvitationController());
                    }
                    final result = await showAddPraRegistrationDialog(context);
                    if (result == true) {
                      invitationController.fetchOngoingInvitations(
                        clearFilters: true,
                      );
                    }
                  },
                ),
              ),
              hSpace(context, 10),
              Expanded(
                child: _buildQuickActionItem(
                  context,
                  label: 'Approve Request',
                  icon: Icons.fact_check_outlined,
                  iconColor: const Color(0xFFE65100),
                  bgColor: const Color(0xFFFFF3E0),
                  onTap: () {
                    context.push(const ApprovalPage());
                  },
                ),
              ),
              hSpace(context, 10),
              Expanded(
                child: _buildQuickActionItem(
                  context,
                  label: isId ? 'Bagikan Tautan' : 'Share Link',
                  icon: Icons.add_link,
                  iconColor: const Color(0xFF534AB7),
                  bgColor: const Color(0xFFF3EEFE),
                  onTap: () {
                    if (!Get.isRegistered<InvitationController>()) {
                      Get.put(InvitationController());
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const CreateShareLinkDialog(),
                    );
                  },
                ),
              ),
              hSpace(context, 10),
              Expanded(
                child: _buildQuickActionItem(
                  context,
                  label: isId ? 'Daftarkan Visitor' : 'Quick Access',
                  icon: Icons.flash_on_rounded,
                  iconColor: const Color(0xFFFF9800),
                  bgColor: const Color(0xFFFFF4E5),
                  onTap: () {
                    if (!Get.isRegistered<InvitationController>()) {
                      Get.put(InvitationController());
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const CreateQuickAccessDialog(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: rh(context, 16),
          horizontal: rw(context, 8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: rw(context, 48),
              height: rw(context, 48),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: rw(context, 22)),
            ),
            vSpace(context, 10),
            SizedBox(
              height: rh(context, 32),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: rfs(context, 11),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required int count,
    required String unit,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 12),
        vertical: rh(context, 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 16)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(rw(context, 12)),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: rw(context, 20)),
          ),
          hSpace(context, 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: rfs(context, 10),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 4),
                isLoading
                    ? SizedBox(
                        height: rh(context, 20),
                        width: rw(context, 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    : Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: rfs(context, 20),
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                vSpace(context, 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: rfs(context, 10),
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onShowMoreTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: rw(context, 5),
              height: rh(context, 20),
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(rw(context, 3)),
              ),
            ),
            hSpace(context, 10),
            Text(
              title,
              style: TextStyle(
                fontSize: rfs(context, 18),
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (onShowMoreTap != null)
          TextButton(
            onPressed: onShowMoreTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 4),
                vertical: rh(context, 2),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primary500,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'More',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: rfs(context, 13),
                  ),
                ),
                hSpace(context, 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: rw(context, 14),
                  color: AppColors.primary500,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class HorizontalDatePicker extends StatelessWidget {
  final DateTime startDate;
  final int daysCount;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChange;
  final ScrollController scrollController;

  const HorizontalDatePicker({
    super.key,
    required this.startDate,
    required this.daysCount,
    required this.selectedDate,
    required this.onDateChange,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rh(context, 84),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: daysCount,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => onDateChange(date),
            child: Container(
              width: rw(context, 62),
              margin: EdgeInsets.symmetric(horizontal: rw(context, 4)),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary500 : Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 12)),
                border: isSelected
                    ? null
                    : (isToday
                          ? Border.all(color: AppColors.primary500, width: 1.5)
                          : Border.all(color: Colors.grey.shade200, width: 1)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary500.withValues(alpha: 0.3),
                          blurRadius: rw(context, 8),
                          offset: Offset(0, rh(context, 3)),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: rw(context, 4),
                          offset: Offset(0, rh(context, 2)),
                        ),
                      ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: rh(context, 8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat("MMMM").format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: rfs(context, 10),
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                        if (isToday) ...[
                          hSpace(context, 4),
                          Container(
                            width: rw(context, 5),
                            height: rw(context, 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary500,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: rfs(context, 16),
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat("E").format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: rfs(context, 9),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FlyingIconAnimation extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final VoidCallback onComplete;

  const FlyingIconAnimation({
    super.key,
    required this.startOffset,
    required this.endOffset,
    required this.onComplete,
  });

  @override
  State<FlyingIconAnimation> createState() => _FlyingIconAnimationState();
}

class _FlyingIconAnimationState extends State<FlyingIconAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        // Curved path using a parabolic arc
        final currentX =
            widget.startOffset.dx +
            (widget.endOffset.dx - widget.startOffset.dx) * t;
        final arcY = -120 * t * (1 - t); // arc height
        final currentY =
            widget.startOffset.dy +
            (widget.endOffset.dy - widget.startOffset.dy) * t +
            arcY;

        final scale = 1.8 - 1.0 * t; // Shrinks down
        final opacity = (1.0 - t * 0.1).clamp(0.0, 1.0);

        return Positioned(
          left: currentX - 20,
          top: currentY - 20,
          child: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE65100),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pending_actions_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActivityItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  _ActivityItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
