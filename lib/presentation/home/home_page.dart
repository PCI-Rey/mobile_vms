import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../presentation/home/alarm/list_alarm_page.dart';
import '../../presentation/notification/notification_page.dart';
import '../../presentation/profile/profile_page.dart';

import 'invitation/widgets/share_link_home_list.dart';
import '../../presentation/home/invitation/send_invitation_page.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';
import 'agenda/widgets/itenerary_list.dart';

import '../../core/core.dart';
import 'access_pass/access_pass_page.dart';
import 'approval/approval_page.dart';
import 'invitation/controller/invitation_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final langCtrl = LanguageController.to;
  final InvitationController invitationController =
      Get.isRegistered<InvitationController>()
      ? Get.find<InvitationController>()
      : Get.put(InvitationController());

  final ScrollController _scrollController = ScrollController();
  bool _isSelectingFromCalendar = false;

  Worker? _dateScrollWorker;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _scrollToDate(
          invitationController.selectedDashboardDate.value,
          animate: false,
        );
      }
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
  }

  @override
  void dispose() {
    _dateScrollWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDate(DateTime date, {bool animate = true}) {
    final startDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).subtract(const Duration(days: 60));

    final index = date.difference(startDate).inDays;
    if (index >= 0 && index < 1095) {
      final itemWidth = rw(context, 60) + rw(context, 8);
      final screenWidth = MediaQuery.of(context).size.width;
      final targetOffset =
          (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

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
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const ProfilePage()),
            child: CustomCircleImage(
              image: Assets.images.avaPerson1.image(fit: BoxFit.cover),
              size: rw(context, 48),
            ),
          ),
          hSpace(context, 16),
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome'.tr,
                  style: TextStyle(
                    fontSize: rfs(context, 12),
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
          onTap: () => showNotificationDialog(context),
          child: Container(
            padding: EdgeInsets.all(rw(context, 9)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: rw(context, 22),
                ),
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
            profileImagePath: 'assets/images/ava_person1.png',
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

          // 2. Section Header: Approval
          _buildSectionHeader(context, 'Approval'),
          vSpace(context, 16),

          // 3. Approval Data List
          const IteneraryList(),

          vSpace(context, 24),

          // 4. Section Header: Share Link
          _buildSectionHeader(context, 'Share Link'),
          vSpace(context, 16),

          // 5. Share Link Data List
          const ShareLinkHomeList(),

          vSpace(context, 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool showLinkIcon = false,
    VoidCallback? onLinkTap,
  }) {
    return Row(
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
        if (showLinkIcon) ...[
          const Spacer(),
          IconButton(
            onPressed: onLinkTap,
            icon: Container(
              padding: EdgeInsets.all(rw(context, 6)),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(rw(context, 8)),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Icon(
                Icons.link,
                color: AppColors.grey600,
                size: rw(context, 20),
              ),
            ),
          ),
        ],
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
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade500,
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
