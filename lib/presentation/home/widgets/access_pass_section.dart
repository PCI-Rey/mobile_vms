import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/user_controller.dart';
import '../../auth/controller/language_controller.dart';
import '../controllers/guest_home_controller.dart';

class AccessPassSection extends StatelessWidget {
  final double sw;
  final Function(dynamic item) onTap;

  const AccessPassSection({
    super.key,
    required this.sw,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final guestCtrl = GuestHomeController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
          child: Obx(() {
            // Trigger rebuild when language changes
            LanguageController.to.selectedLang.value;
            return Text(
              'access_pass'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: rfs(context, 16),
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ),
        SizedBox(height: sw * 0.03),
        Obx(() {
          // Trigger rebuild when language changes
          LanguageController.to.selectedLang.value;
          if (guestCtrl.isLoading.value) {
            return _buildPassPlaceholder(sw);
          }
          if (guestCtrl.accessPasses.isEmpty) {
            return _buildPassEmpty(sw, context);
          }
          if (guestCtrl.accessPasses.length == 1) {
            return AccessPassCard(
              item: guestCtrl.accessPasses[0],
              sw: sw,
              onTap: () => onTap(guestCtrl.accessPasses[0]),
            );
          }
          return CarouselSlider(
            options: CarouselOptions(
              height: sw * 0.36,
              viewportFraction: 0.90,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
            ),
            items: guestCtrl.accessPasses
                .map(
                  (item) => AccessPassCard(
                    item: item,
                    sw: sw,
                    onTap: () => onTap(item),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPassPlaceholder(double sw) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.04),
      height: sw * 0.28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(sw * 0.05),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildPassEmpty(double sw, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.04),
      padding: EdgeInsets.symmetric(vertical: sw * 0.06),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(sw * 0.05),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.qr_code_2_outlined,
              color: Colors.white54,
              size: sw * 0.09,
            ),
            SizedBox(height: sw * 0.02),
            Text(
              'no_access_pass'.tr,
              style: TextStyle(
                color: Colors.white70,
                fontSize: rfs(context, 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccessPassCard extends StatelessWidget {
  final dynamic item;
  final double sw;
  final VoidCallback onTap;

  const AccessPassCard({
    super.key,
    required this.item,
    required this.sw,
    required this.onTap,
  });

  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0E5DB5);

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'status_active'.tr;
      case 'checkin':
        return 'status_checkin'.tr;
      case 'checkout':
        return 'status_checkout'.tr;
      case 'expired':
        return 'status_expired'.tr;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userCtrl = UserController.to;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: sw * 0.04),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.05,
          vertical: sw * 0.04,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_blue, _blueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'guest_pass'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 10),
                      ),
                    ),
                  ),
                  SizedBox(height: sw * 0.02),
                  Obx(
                    () => Text(
                      userCtrl.fullName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: sw * 0.015),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: sw * 0.012),
                      Expanded(
                        child: Text(
                          '${_translateStatus(item.visitorStatus)} · ${item.sitePlaceName}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: rfs(context, 11),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.04),
            Container(
              width: sw * 0.135,
              height: sw * 0.135,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(sw * 0.03),
              ),
              padding: const EdgeInsets.all(4),
              child: QrImageView(
                data: item.visitorNumber,
                version: QrVersions.auto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
