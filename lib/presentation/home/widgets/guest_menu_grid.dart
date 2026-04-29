import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/language_controller.dart';
import '../../notification/notification_page.dart';
import '../invitation/guest_invitation_page.dart';
import '../report/guest_report_page.dart';
import '../../history/history_page.dart';
import '../../parking/as_guest/guest_parking_page.dart';
import '../../profile/profile_page.dart';

class GuestMenuGrid extends StatelessWidget {
  final double sw;

  const GuestMenuGrid({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.to;
    final iconBoxSize = sw * 0.135;
    final iconSize = sw * 0.068;
    final boxRadius = sw * 0.038;


    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.04),
      padding: EdgeInsets.symmetric(vertical: sw * 0.05, horizontal: sw * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Obx(() {
        // Trigger rebuild when language changes
        langCtrl.selectedLang.value;

        final List<GuestMenuItemModel> items = [
          GuestMenuItemModel(
            label: 'invitation'.tr,
            icon: Icons.calendar_month_outlined,
            bgColor: const Color(0xFFE8F1FD),
            iconColor: const Color(0xFF1976D2),
            onTap: () => Get.to(() => const GuestInvitationPage()),
          ),
          GuestMenuItemModel(
            label: 'history'.tr,
            icon: Icons.history_rounded,
            bgColor: const Color(0xFFEAF3DE),
            iconColor: const Color(0xFF3B6D11),
            onTap: () => Get.to(() => const HistoryPage()),
          ),
          GuestMenuItemModel(
            label: 'parking'.tr,
            icon: Icons.local_parking_rounded,
            bgColor: const Color(0xFFFAEEDA),
            iconColor: const Color(0xFF854F0B),
            onTap: () => Get.to(() => const GuestParkingPage()),
          ),
          GuestMenuItemModel(
            label: 'report'.tr,
            icon: Icons.bar_chart_rounded,
            bgColor: const Color(0xFFF3EEFE),
            iconColor: const Color(0xFF534AB7),
            onTap: () => Get.to(() => const GuestReportPage()),
          ),
          GuestMenuItemModel(
            label: 'notification'.tr,
            icon: Icons.notifications_outlined,
            bgColor: const Color(0xFFFBEAF0),
            iconColor: const Color(0xFF993556),
            onTap: () => showNotificationDialog(context),
            badgeCount: 3,
          ),
          GuestMenuItemModel(
            label: 'profile'.tr,
            icon: Icons.person_outline_rounded,
            bgColor: const Color(0xFFE1F5EE),
            iconColor: const Color(0xFF0F6E56),
            onTap: () => Get.to(() => const ProfilePage()),
          ),
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: items
                  .take(3)
                  .map(
                    (m) => Expanded(
                      child: _buildMenuItem(
                        context,
                        m,
                        iconBoxSize,
                        iconSize,
                        boxRadius,
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: sw * 0.05),
            Row(
              children: items
                  .skip(3)
                  .map(
                    (m) => Expanded(
                      child: _buildMenuItem(
                        context,
                        m,
                        iconBoxSize,
                        iconSize,
                        boxRadius,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    GuestMenuItemModel item,
    double boxSize,
    double iconSize,
    double radius,
  ) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Icon(item.icon, color: item.iconColor, size: iconSize),
              ),
              if ((item.badgeCount ?? 0) > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE24B4A),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: boxSize * 0.15),
          Text(
            item.label,
            style: TextStyle(
              fontSize: rfs(context, 11),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF444441),
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class GuestMenuItemModel {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;
  final int? badgeCount;

  const GuestMenuItemModel({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
    this.badgeCount,
  });
}
