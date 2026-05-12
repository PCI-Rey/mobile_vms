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
                    const GuestHeader(),
                    
                    // --- SCROLLABLE BODY ---
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Column(
                          children: [
                            vSpace(context, 16),
                            const GuestMenuGrid(),
                            vSpace(context, 24),
                            AccessPassSection(
                              onTap: (item) => AccessPassModal.show(context, item),
                            ),
                            vSpace(context, 24),

                            // --- BOTTOM CONTENT ---
                            _buildBottomContent(context),
                          ],
                        ),
                      ),
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

  Widget _buildBottomContent(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(rw(context, 32))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: rw(context, 12),
            offset: Offset(0, rh(context, -4)),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        rw(context, 20),
        rh(context, 32),
        rw(context, 20),
        rh(context, 20),
      ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 12),
                    vertical: rh(context, 6),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary500.withValues(alpha: 0.1),
                        AppColors.primary500.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(rw(context, 12)),
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
          vSpace(context, 16),
          Obx(() {
            if (guestCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (guestCtrl.accessPasses.isEmpty) {
              return _buildEmptyVisits(context);
            }
            return Column(
              children: [
                for (int i = 0; i < guestCtrl.accessPasses.length; i++) ...[
                  Obx(() => VisitSummaryCard(
                    item: guestCtrl.accessPasses[i],
                    isSelected: guestCtrl.selectedPassIndex.value == i,
                    onTap: () => guestCtrl.selectPass(i),
                  )),
                  if (i < guestCtrl.accessPasses.length - 1)
                    vSpace(context, 10),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyVisits(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(context, 40)),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(rw(context, 20)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: rw(context, 40),
                color: Colors.grey[400],
              ),
            ),
            vSpace(context, 12),
            Text(
              'no_active_visits'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rfs(context, 15),
              ),
            ),
            vSpace(context, 4),
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
