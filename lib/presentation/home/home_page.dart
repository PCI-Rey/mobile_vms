import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../presentation/home/alarm/list_alarm_page.dart';
import '../../presentation/notification/notification_page.dart';
import '../../presentation/profile/profile_page.dart';

import 'invitation/widgets/share_link_home_list.dart';
import 'invitation/widgets/invitation_home_list.dart';
import 'invitation/widgets/quick_access_home_list.dart';
import '../../presentation/home/invitation/send_invitation_page.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';
import 'agenda/widgets/itenerary_list.dart';

import '../../core/core.dart';
import 'access_pass/access_pass_page.dart';
import 'approval/approval_page.dart';
import 'invitation/controller/invitation_controller.dart';
import '../../data/models/approval_ticket_model.dart';
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

  final ScrollController _scrollController = ScrollController();
  bool _isSelectingFromCalendar = false;
  bool _showBellRedDot = false;

  Worker? _dateScrollWorker;
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
      if (mounted) {
        _scrollToDate(
          invitationController.selectedDashboardDate.value,
          animate: false,
        );
        _checkAndShowPendingPopup(invitationController.approvalTickets);
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _scrollToDate(
            invitationController.selectedDashboardDate.value,
            animate: false,
          );
        }
      });
    });

    _dateScrollWorker = ever(invitationController.selectedDashboardDate, (
      date,
    ) {
      if (mounted) {
        if (_isSelectingFromCalendar) {
          _isSelectingFromCalendar = false;
          _scrollToDate(date, animate: true);
        }
        setState(() {});
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

  @override
  void dispose() {
    _bellAnimationController.dispose();
    _dateScrollWorker?.dispose();
    _approvalTicketsWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAndShowPendingPopup(List<ApprovalTicketModel> tickets) {
    if (invitationController.hasShownPendingPopup) return;

    List<ApprovalTicketModel> pendingTickets = tickets.where((t) {
      final isPending =
          (t.approvalActorStatus ?? '').toLowerCase() == 'pending' ||
          (t.approvalStatus ?? '').toLowerCase() == 'pending';
      return isPending;
    }).toList();

    // If we have postponed tickets (remind me again was pressed), only show those!
    if (invitationController.postponedTicketIds.isNotEmpty) {
      pendingTickets = pendingTickets.where((t) {
        final id = t.approvalTicketId ?? t.ticketId;
        return id != null && invitationController.postponedTicketIds.contains(id);
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
                              key: ValueKey(currentTickets.length), // Rebuild PageView on item removal to avoid index mismatches
                              controller: pageController,
                              itemCount: currentTickets.length,
                              onPageChanged: (index) {
                                setState(() {
                                  currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                 final ticket = currentTickets[index];
                                 invitationController.fetchVisitorNameForTicket(ticket);
                                 final host = ticket.hostName ?? 'Unknown Host';
                                 final agenda = ticket.agenda ?? 'Meeting';
                                 final type = ticket.visitorTypeName ?? 'Visitor';
                                 final start = ticket.visitorPeriodStart;
                                 final startStr = start != null
                                     ? DateFormat('dd MMMM yyyy, HH:mm').format(start)
                                     : '-';

                                 return Container(
                                   margin: EdgeInsets.symmetric(horizontal: rw(context, 4)),
                                   padding: EdgeInsets.symmetric(
                                     horizontal: rw(context, 12),
                                     vertical: rh(context, 12),
                                   ),
                                   decoration: BoxDecoration(
                                     color: const Color(0xFFF5F7FB),
                                     borderRadius: BorderRadius.circular(rw(context, 16)),
                                     border: Border.all(color: Colors.grey.shade200),
                                   ),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
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
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Obx(() {
                                               final ticketId = ticket.approvalTicketId ?? ticket.ticketId ?? '';
                                               final displayName = invitationController.ticketVisitorNames[ticketId] ?? host;
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
                                                         fontSize: rfs(context, 15),
                                                         fontWeight: FontWeight.bold,
                                                         color: Colors.black,
                                                       ),
                                                     ),
                                                     TextSpan(
                                                       text: ' requested approval for ',
                                                       style: TextStyle(
                                                         fontSize: rfs(context, 15),
                                                         color: Colors.black87,
                                                       ),
                                                     ),
                                                     TextSpan(
                                                       text: agenda,
                                                       style: TextStyle(
                                                         fontSize: rfs(context, 15),
                                                         fontWeight: FontWeight.bold,
                                                         color: Colors.black,
                                                       ),
                                                     ),
                                                     TextSpan(
                                                       text: '.',
                                                       style: TextStyle(
                                                         fontSize: rfs(context, 15),
                                                         color: Colors.black87,
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                               );
                                             }),vSpace(context, 4),
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
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
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
                                    final ticketId = ticket.approvalTicketId ?? ticket.ticketId ?? '';
                                    _runFlyingAnimation(setRedDot: true);
                                    
                                    setState(() {
                                      hasPressedRemindMe = true;
                                      invitationController.startReminderTimer(
                                        30,
                                        ticketId,
                                        () {
                                          invitationController.fetchApprovalTickets();
                                        },
                                      );

                                      currentTickets.removeAt(currentPage);
                                      if (currentPage >= currentTickets.length) {
                                        currentPage = currentTickets.length - 1;
                                      }
                                      if (currentPage < 0) currentPage = 0;
                                      pageController = PageController(initialPage: currentPage);
                                    });

                                    if (currentTickets.isEmpty) {
                                      Navigator.of(dialogCtx).pop();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.grey700,
                                    side: const BorderSide(color: AppColors.grey400),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(rw(context, 12)),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: rh(context, 10)),
                                  ),
                                  child: Text(
                                    'Remind me again',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: rfs(context, 13.5), fontWeight: FontWeight.bold),
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
                                      if (currentPage >= currentTickets.length) {
                                        currentPage = currentTickets.length - 1;
                                      }
                                      if (currentPage < 0) currentPage = 0;
                                      pageController = PageController(initialPage: currentPage);
                                    });

                                    if (currentTickets.isEmpty) {
                                      Navigator.of(dialogCtx).pop();
                                      if (!hasPressedRemindMe) {
                                        invitationController.cancelReminderTimer();
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary500,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(rw(context, 12)),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: rh(context, 10)),
                                  ),
                                  child: Text(
                                    'Yes, I Know',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: rfs(context, 13.5), fontWeight: FontWeight.bold),
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

  void _scrollToDate(DateTime date, {bool animate = true}) {
    final startDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).subtract(const Duration(days: 60));

    final index = date.difference(startDate).inDays;
    if (index >= 0 && index < 1095) {
      final itemWidth = rw(context, 62) + rw(context, 8);
      final screenWidth = MediaQuery.of(context).size.width;
      final calendarButtonWidth = rw(context, 46) + rw(context, 12);
      final parentPadding = rw(context, 24) * 2;
      final viewportWidth = screenWidth - parentPadding - calendarButtonWidth;
      final targetOffset =
          (index * itemWidth) - (viewportWidth / 2) + (itemWidth / 2);

      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final clampedOffset = targetOffset.clamp(0.0, maxScroll);

        if (animate) {
          _scrollController.animateTo(
            clampedOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.jumpTo(clampedOffset);
        }
      }
    }
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
        _isSelectingFromCalendar = true;
        invitationController.selectedDashboardDate.value = normalized;
      } else {
        _scrollToDate(normalized, animate: true);
        setState(() {});
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
        children: [
          // 1. Full background gradient
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
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
            onTap: () => Get.to(() => const ProfilePage()),
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
            showNotificationDialog(context);
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
                    if (_showBellRedDot)
                      Positioned(
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
                      ),
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
          'onTap': () => showAccessPassDialog(
            context: context,
            name: UserController.to.fullName,
            date: 'Mon, 19 Jul 2025',
            time: '10:00 - 13:00',
            invitationCode: '729038',
            cardNumber: '6789209930',
            vehiclePlateNo: 'B1245K',
            parkingSlot: 'Slot A1',
            buildingName: 'Gedung HQ',
            visitorId: '7E20A56D62B',
            profileImagePath: 'assets/images/Endru.png',
            isTracked: true,
            isLowBattery: true,
          ),
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
          'label': 'alarm'.tr,
          'icon': Icons.notifications_active_outlined,
          'bgColor': const Color(0xFFFFEBEB),
          'iconColor': const Color(0xFFD32F2F),
          'onTap': () => context.push(const AlarmListPage()),
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
          // 1. Date Selection (Moved to the very top)
          Obx(() {
            debugPrint(
              "BUILD DatePicker: date=${invitationController.selectedDashboardDate.value}",
            );
            return Row(
              children: [
                Expanded(
                  child: HorizontalDatePicker(
                    startDate: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    ).subtract(const Duration(days: 60)),
                    daysCount: 1095,
                    selectedDate:
                        invitationController.selectedDashboardDate.value,
                    scrollController: _scrollController,
                    onDateChange: (date) {
                      invitationController.selectedDashboardDate.value =
                          DateTime(date.year, date.month, date.day);
                    },
                  ),
                ),
                hSpace(context, 12),
                GestureDetector(
                  onTap: () => _selectDateFromCalendar(context),
                  child: Container(
                    padding: EdgeInsets.all(rw(context, 12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(rw(context, 12)),
                      border: Border.all(color: AppColors.primary100),
                    ),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary500,
                      size: rw(context, 22),
                    ),
                  ),
                ),
              ],
            );
          }),

          vSpace(context, 24),

          // 2. Section Header: Invitation
          _buildSectionHeader(
            context,
            'Invitation',
            onShowMoreTap: () => Get.to(() => const SendInvitationPage(initialTab: 0)),
          ),
          vSpace(context, 16),

          // 3. Invitation Data List
          const InvitationHomeList(),

          vSpace(context, 24),

          // 4. Section Header: Approval
          _buildSectionHeader(
            context,
            'Approval',
            onShowMoreTap: () => Get.to(() => const ApprovalPage()),
          ),
          vSpace(context, 16),

          // 5. Approval Data List
          const IteneraryList(),

          vSpace(context, 24),

          // 6. Section Header: Share Link
          _buildSectionHeader(
            context,
            'Share Link',
            onShowMoreTap: () => Get.to(() => const SendInvitationPage(initialTab: 1)),
          ),
          vSpace(context, 16),

          // 7. Share Link Data List
          const ShareLinkHomeList(),

          vSpace(context, 24),

          // 8. Section Header: Quick Access
          _buildSectionHeader(
            context,
            'Quick Access',
            onShowMoreTap: () => Get.to(() => const SendInvitationPage(initialTab: 2)),
          ),
          vSpace(context, 16),

          // 9. Quick Access Data List
          const QuickAccessHomeList(),

          vSpace(context, 20),
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
                          DateFormat("MMM").format(date).toUpperCase(),
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
