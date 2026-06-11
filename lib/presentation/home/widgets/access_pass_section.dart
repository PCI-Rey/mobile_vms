import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/user_controller.dart';
import '../../auth/controller/language_controller.dart';
import '../controllers/guest_home_controller.dart';
import '../../../core/components/custom_circle_image.dart';
import '../../../core/gen/assets.gen.dart';

class AccessPassSection extends StatelessWidget {
  final Function(dynamic item) onTap;

  const AccessPassSection({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final guestCtrl = GuestHomeController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
          child: Obx(() {
            // Trigger rebuild when language changes
            LanguageController.to.selectedLang.value;
            String title = 'access_pass'.tr;

            if (guestCtrl.accessPasses.isNotEmpty &&
                guestCtrl.selectedPassIndex.value <
                    guestCtrl.accessPasses.length) {
              final selectedItem =
                  guestCtrl.accessPasses[guestCtrl.selectedPassIndex.value];
              title = '${'access_pass'.tr} • ${selectedItem.agenda}';
            }

            return Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: rfs(context, 20),
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            );
          }),
        ),
        vSpace(context, 12),
        Obx(() {
          // Trigger rebuild when language changes
          LanguageController.to.selectedLang.value;
          if (guestCtrl.isLoading.value) {
            return _buildPassPlaceholder(context);
          }
          if (guestCtrl.accessPasses.isEmpty) {
            return _buildPassEmpty(context);
          }

          final int index = guestCtrl.selectedPassIndex.value;
          final item = guestCtrl.accessPasses[
              index < guestCtrl.accessPasses.length ? index : 0];

          return AccessPassCard(
            item: item,
            onTap: () => onTap(item),
          );
        }),
      ],
    );
  }

  Widget _buildPassPlaceholder(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(context, 16)),
      height: rh(context, 130),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rw(context, 20)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildPassEmpty(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(context, 16)),
      padding: EdgeInsets.symmetric(vertical: rh(context, 28)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rw(context, 20)),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.qr_code_2_outlined,
              color: Colors.white54,
              size: rw(context, 44),
            ),
            vSpace(context, 8),
            Text(
              'no_access_pass'.tr,
              style: TextStyle(
                color: Colors.white70,
                fontSize: rfs(context, 14),
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
  final VoidCallback onTap;

  const AccessPassCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  static const _blue = Color(0xFF1565C0);
  static const _blueDark = Color(0xFF0D47A1);

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
        margin: EdgeInsets.symmetric(horizontal: rw(context, 16)),
        padding: EdgeInsets.all(rw(context, 20)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_blue, _blueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(rw(context, 24)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.45),
              blurRadius: rw(context, 20),
              offset: Offset(0, rh(context, 8)),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: badge + name + status ───────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Guest Pass" badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 10),
                      vertical: rh(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'guest_pass'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  vSpace(context, 10),

                  // Visitor name
                  Obx(() {
                    final String defaultName = userCtrl.fullName;
                    final String displayName =
                        (item.visitorName as String).isNotEmpty
                            ? item.visitorName
                            : defaultName;
                    return Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 22),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    );
                  }),
                  vSpace(context, 8),

                  // Status dot + site name
                  Row(
                    children: [
                      Container(
                        width: rw(context, 8),
                        height: rw(context, 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4ADE80).withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      hSpace(context, 7),
                      Expanded(
                        child: Text(
                          '${_translateStatus(item.visitorStatus)} · ${item.sitePlaceName}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.w500,
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
            hSpace(context, 16),

            // ── Right: photo stacked above QR ─────────────
            Column(
              children: [
                CustomCircleImage(
                  image: userCtrl.faceUrl != null
                      ? Image.network(
                          userCtrl.faceUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Assets.images.avaPerson1.image(
                            fit: BoxFit.cover,
                          ),
                        )
                      : Assets.images.avaPerson1.image(fit: BoxFit.cover),
                  size: rw(context, 52),
                  borderWidth: 2,
                ),
                vSpace(context, 10),
                Container(
                  width: rw(context, 62),
                  height: rw(context, 62),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rw(context, 12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: QrImageView(
                    data: item.visitorNumber,
                    version: QrVersions.auto,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
