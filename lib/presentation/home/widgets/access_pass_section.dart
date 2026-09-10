import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/language_controller.dart';
import '../controllers/guest_home_controller.dart';

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
        // ── 1. Minimalist Title Row ────────────────────────────────
        Obx(() {
          LanguageController.to.selectedLang.value;
          final title = 'access_pass'.tr;
          final int total = guestCtrl.accessPasses.length;
          final int currentIndex = guestCtrl.selectedPassIndex.value;
          final int safeIndex =
              (currentIndex >= 0 && currentIndex < total) ? currentIndex : 0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rfs(context, 20),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (total > 1)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 10),
                      vertical: rh(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(rw(context, 12)),
                    ),
                    child: Text(
                      '${safeIndex + 1} / $total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),

        vSpace(context, 12),

        // ── 2. Card Content Area ──────────────────────────────────
        Obx(() {
          LanguageController.to.selectedLang.value;
          if (guestCtrl.isLoading.value) {
            return _buildPassPlaceholder(context);
          }
          if (guestCtrl.accessPasses.isEmpty) {
            return _buildPassEmpty(context);
          }

          final int total = guestCtrl.accessPasses.length;
          final int currentIndex = guestCtrl.selectedPassIndex.value;
          final int safeIndex =
              (currentIndex >= 0 && currentIndex < total) ? currentIndex : 0;
          final item = guestCtrl.accessPasses[safeIndex];

          final bool hasPrev = safeIndex > 0;
          final bool hasNext = safeIndex < total - 1;

          // If multiple passes exist, show carousel with subtle side arrows
          if (total > 1) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavArrow(
                    context: context,
                    icon: Icons.chevron_left_rounded,
                    isEnabled: hasPrev,
                    onTap: () {
                      if (hasPrev) {
                        guestCtrl.selectPass(safeIndex - 1);
                      }
                    },
                  ),
                  hSpace(context, 6),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -100 && hasNext) {
                            guestCtrl.selectPass(safeIndex + 1);
                          } else if (details.primaryVelocity! > 100 && hasPrev) {
                            guestCtrl.selectPass(safeIndex - 1);
                          }
                        }
                      },
                      child: AccessPassCard(
                        item: item,
                        onTap: () => onTap(item),
                      ),
                    ),
                  ),
                  hSpace(context, 6),
                  _buildNavArrow(
                    context: context,
                    icon: Icons.chevron_right_rounded,
                    isEnabled: hasNext,
                    onTap: () {
                      if (hasNext) {
                        guestCtrl.selectPass(safeIndex + 1);
                      }
                    },
                  ),
                ],
              ),
            );
          }

          // Single pass: takes clean 20px padding matching the grid above
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
            child: AccessPassCard(
              item: item,
              onTap: () => onTap(item),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNavArrow({
    required BuildContext context,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.25,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: rw(context, 32),
          height: rw(context, 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: rw(context, 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassPlaceholder(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(context, 20)),
      height: rh(context, 130),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rw(context, 20)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildPassEmpty(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(context, 20)),
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
              size: rw(context, 40),
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    final String startStr = item.visitorPeriodStart != null
        ? dateFormat.format(item.visitorPeriodStart)
        : '-';
    final String endStr = item.visitorPeriodEnd != null
        ? dateFormat.format(item.visitorPeriodEnd)
        : '-';

    final String agenda = (item.agenda != null &&
            item.agenda.toString().trim().isNotEmpty)
        ? item.agenda.toString().trim()
        : '-';

    final String visitorType = () {
      if (item.visitorTypeName != null &&
          item.visitorTypeName.toString().trim().isNotEmpty) {
        return item.visitorTypeName.toString().trim();
      }
      if (item.visitorRole != null &&
          item.visitorRole.toString().trim().isNotEmpty) {
        return item.visitorRole.toString().trim();
      }
      return 'Visitor';
    }();

    // Resolve QR Code data (strictly invitation code)
    final String qrData = () {
      if (item.invitationCode != null &&
          item.invitationCode.toString().trim().isNotEmpty) {
        return item.invitationCode.toString().trim();
      }
      if (item.initialTrxCode != null &&
          item.initialTrxCode.toString().trim().isNotEmpty) {
        return item.initialTrxCode.toString().trim();
      }
      return '-';
    }();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(rw(context, 18)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: rw(context, 18),
              offset: Offset(0, rh(context, 6)),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: Agenda, Type Visitor, Visit Start, Visit End ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nama Agenda
                  Text(
                    agenda,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: rfs(context, 18),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  vSpace(context, 4),

                  // Type Visitor
                  Text(
                    visitorType,
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  vSpace(context, 12),

                  // Visit Start
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: rw(context, 14),
                        color: const Color(0xFF64748B),
                      ),
                      hSpace(context, 6),
                      Expanded(
                        child: Text(
                          'Start : $startStr',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 4),

                  // Visit End
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: rw(context, 14),
                        color: const Color(0xFF64748B),
                      ),
                      hSpace(context, 6),
                      Expanded(
                        child: Text(
                          'End   : $endStr',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            hSpace(context, 14),

            // ── Right: Barcode / QR Code ──
            Container(
              width: rw(context, 76),
              height: rw(context, 76),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 12)),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: rw(context, 6),
                    offset: Offset(0, rh(context, 2)),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: rw(context, 76),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
