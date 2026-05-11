
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../presentation/home/alarm/list_alarm_page.dart';
import '../../presentation/home/evacuate/evacuate_page.dart';
import '../../presentation/notification/notification_page.dart';
import '../../presentation/parking/as_operator/parking_page.dart';
import '../../presentation/home/report/report_page.dart';
import '../../presentation/home/agenda/widgets/visitor_list.dart';
import '../../presentation/home/invitation/send_invitation_page.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';
import '../../presentation/parking/as_guest/guest_parking_page.dart';
import '../../presentation/home/visitor/visitor_page.dart';
import 'agenda/widgets/itenerary_list.dart';

import '../../core/core.dart';
import 'access_pass/access_pass_page.dart';
import 'invitation/widgets/share_link_list_dialog.dart';
import 'invitation/controller/invitation_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final langCtrl = LanguageController.to;

  // Design constants
  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0D47A1);
  static const _bgPage = Color(0xFFF8FAFF);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Scaffold(
      backgroundColor: _bgPage,
      body: Stack(
        children: [
          // 1. Full background gradient (Menutupi seluruh layar)
          Container(
            width: double.infinity,
            height: mq.size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_blue, _blueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- HEADER ---
                  _buildHeader(context, sw),
                  
                  SizedBox(height: sw * 0.06),

                  // --- MENU GRID ---
                  _buildMenuGrid(context, sw),

                  SizedBox(height: sw * 0.08),

                  // --- BOTTOM CONTENT (SCHEDULE & AGENDA) ---
                  _buildBottomContent(context, sw),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sw * 0.02),
      child: Row(
        children: [
          CustomCircleImage(
            image: Assets.images.avaPerson1.image(fit: BoxFit.cover),
            size: sw * 0.12,
          ),
          SizedBox(width: sw * 0.04),
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
                Obx(() => Text(
                  UserController.to.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: rfs(context, 18),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                )),
              ],
            ),
          ),
          // Actions
          _buildActionButtons(context, sw),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double sw) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLanguageDropdown(context, sw),
        SizedBox(width: sw * 0.03),
        GestureDetector(
          onTap: () => showNotificationDialog(context),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, double sw) {
    return Obx(() {
      final isId = langCtrl.selectedLang.value == 'id';
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: isId ? 'id' : 'en',
            icon: const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.white,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildMenuGrid(BuildContext context, double sw) {
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
          'bgColor': const Color(0xFFFAEEDA),
          'iconColor': const Color(0xFF854F0B),
          'onTap': () => debugPrint('Approval clicked'),
        },
        {
          'label': 'report'.tr,
          'icon': Icons.bar_chart_rounded,
          'bgColor': const Color(0xFFF3EEFE),
          'iconColor': const Color(0xFF534AB7),
          'onTap': () => context.push(const VisitorReportPage()),
        },
        {
          'label': 'parking'.tr,
          'icon': Icons.local_parking_rounded,
          'bgColor': const Color(0xFFFBEAF0),
          'iconColor': const Color(0xFF993556),
          'onTap': () => context.push(
                UserController.to.user.value?.roleAccess == 'guest'
                    ? const GuestParkingPage()
                    : const ParkingPage(),
              ),
        },
        {
          'label': 'visitor'.tr,
          'icon': Icons.person_search_outlined,
          'bgColor': const Color(0xFFE1F5EE),
          'iconColor': const Color(0xFF0F6E56),
          'onTap': () => context.push(const VisitorPage()),
        },
        {
          'label': 'alarm'.tr,
          'icon': Icons.notifications_active_outlined,
          'bgColor': const Color(0xFFFFEBEB),
          'iconColor': const Color(0xFFD32F2F),
          'onTap': () => context.push(const AlarmListPage()),
        },
        {
          'label': 'evacuate'.tr,
          'icon': Icons.run_circle_outlined,
          'bgColor': const Color(0xFFF5F5F5),
          'iconColor': const Color(0xFF616161),
          'onTap': () => context.push(const EvacuatePage()),
        },
      ];

      return Container(
        margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
        padding: EdgeInsets.symmetric(vertical: sw * 0.06, horizontal: sw * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.07),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1 (4 items)
            Row(
              children: items.take(4).map((item) => Expanded(
                child: _buildMenuItem(context, sw, item),
              )).toList(),
            ),
            SizedBox(height: sw * 0.06),
            // Row 2 (4 items)
            Row(
              children: items.skip(4).map((item) => Expanded(
                child: _buildMenuItem(context, sw, item),
              )).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuItem(BuildContext context, double sw, Map<String, dynamic> item) {
    final boxSize = sw * 0.13;
    final iconSize = sw * 0.065;

    return InkWell(
      onTap: item['onTap'],
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: item['bgColor'],
              borderRadius: BorderRadius.circular(sw * 0.035),
            ),
            child: Icon(item['icon'], color: item['iconColor'], size: iconSize),
          ),
          const SizedBox(height: 8),
          Text(
            item['label'],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: rfs(context, 10.5),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF444441),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContent(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(sw * 0.06, sw * 0.08, sw * 0.06, sw * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Share Link (formerly Schedule)
          _buildSectionHeader(
            context,
            'Share Link',
            showLinkIcon: true,
            onLinkTap: () {
              if (!Get.isRegistered<InvitationController>()) {
                Get.put(InvitationController());
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const ShareLinkListDialog(),
              );
            },
          ),
          const SizedBox(height: 16),
          DatePicker(
            DateTime.now(),
            initialSelectedDate: DateTime.now(),
            daysCount: 30,
            selectionColor: AppColors.primary500,
            selectedTextColor: Colors.white,
            deactivatedColor: Colors.grey.shade400,
            dayTextStyle: TextStyle(fontSize: rfs(context, 11), fontWeight: FontWeight.w600),
            dateTextStyle: TextStyle(fontSize: rfs(context, 16), fontWeight: FontWeight.w800),
            monthTextStyle: TextStyle(fontSize: rfs(context, 10), fontWeight: FontWeight.w500),
            onDateChange: (date) => debugPrint("Tanggal dipilih: $date"),
          ),
          
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 24),

          // List of Visitor List (Agenda)
          const VisitorList(),

          const SizedBox(height: 32),
          
          // Section: Active Visit
          _buildSectionHeader(context, 'active_visit'.tr),
          const SizedBox(height: 16),

          // Itinerary List
          const IteneraryList(),

          const SizedBox(height: 20),
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
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary500,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: rfs(context, 17),
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey300),
              ),
              child: const Icon(Icons.link, color: AppColors.grey600, size: 20),
            ),
          ),
        ],
      ],
    );
  }
}
