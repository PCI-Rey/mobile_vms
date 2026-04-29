import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../presentation/auth/controller/language_controller.dart';
import '../../presentation/auth/controller/user_controller.dart';
import 'controllers/guest_home_controller.dart';
import 'widgets/visit_summary_card.dart';
import 'widgets/access_pass_section.dart';
import 'widgets/access_pass_modal.dart';
import 'widgets/guest_header.dart';
import 'widgets/guest_menu_grid.dart';
import '../../core/helper/responsive_helper.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  final guestCtrl = Get.put(GuestHomeController());
  final langCtrl = LanguageController.to;
  final userCtrl = UserController.to;

  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0E5DB5);
  static const _bgPage = Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final bottom = mq.padding.bottom; // safe area below navbar

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Full background gradient
              Container(
                width: double.infinity,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_blue, _blueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // --- TOP FIXED SECTION ---
                    GuestHeader(sw: sw),
                    SizedBox(height: sw * 0.04),
                    GuestMenuGrid(sw: sw),
                    SizedBox(height: sw * 0.06),
                    AccessPassSection(
                      sw: sw,
                      onTap: (item) => AccessPassModal.show(context, item, sw),
                    ),
                    SizedBox(height: sw * 0.06),

                    // --- BOTTOM SCROLLABLE SECTION ---
                    Expanded(
                      child: _buildBottomContent(context, sw, bottom),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomContent(
    BuildContext context,
    double sw,
    double bottomInset,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      // Bottom padding = safe-area inset + extra room for premium feel
      padding: EdgeInsets.fromLTRB(
        sw * 0.05,
        sw * 0.08,
        sw * 0.05,
        sw * 0.05,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'active_visit'.tr,
                        style: TextStyle(
                          fontSize: rfs(context, 16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'active_visits_desc'.tr,
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary500.withValues(alpha: 0.1),
                          AppColors.primary500.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary500.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '${guestCtrl.accessPasses.length} ${'records'.tr}',
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.04),
            Obx(() {
              if (guestCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (guestCtrl.accessPasses.isEmpty) {
                return _buildEmptyVisits(context, sw);
              }
              return Column(
                children: [
                  for (int i = 0; i < guestCtrl.accessPasses.length; i++) ...[
                    VisitSummaryCard(item: guestCtrl.accessPasses[i], sw: sw),
                    if (i < guestCtrl.accessPasses.length - 1)
                      SizedBox(height: sw * 0.025),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVisits(BuildContext context, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.1),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.05),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: sw * 0.1,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: sw * 0.03),
            Text(
              'no_active_visits'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rfs(context, 15),
              ),
            ),
            SizedBox(height: sw * 0.01),
            Text(
              'no_active_visits_desc'.tr,
              style: TextStyle(color: Colors.grey, fontSize: rfs(context, 12)),
            ),
          ],
        ),
      ),
    );
  }
}
