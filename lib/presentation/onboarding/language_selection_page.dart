import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controller/language_controller.dart';
import '../../core/helper/responsive_helper.dart';
import '../auth/login_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.to;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1976D2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * 0.40;

          return Stack(
            children: [
              // 1. Blue Header Background (Gradient)
              Container(
                width: double.infinity,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF0E5DB5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 2. Decorative Circles (For depth)
              Positioned(
                top: -sw * 0.2,
                right: -sw * 0.1,
                child: Container(
                  width: sw * 0.5,
                  height: sw * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.55,
                left: -sw * 0.15,
                child: Container(
                  width: sw * 0.4,
                  height: sw * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 3. Hero Content
              Container(
                width: double.infinity,
                height: heroHeight,
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Circle
                    SizedBox(
                      width: sw * 0.28,
                      height: sw * 0.28,
                      child: Image.asset(
                        'assets/images/VMS.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: sw * 0.05),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'VISITOR MANAGEMENT SYSTEM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rfs(context, 20),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.015),
                    Text(
                      'select_language_tagline'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. White Content Card
              Positioned(
                top: heroHeight * 0.92, // Slight overlap
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.06,
                        vertical: sw * 0.07,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'choose_language'.tr,
                              style: TextStyle(
                                fontSize: rfs(context, 16),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          SizedBox(height: sw * 0.06),

                          // English Option
                          Obx(
                            () => _LanguageOption(
                              title: 'English',
                              flagCode: 'us',
                              isSelected: langCtrl.selectedLang.value == 'en',
                              onTap: () => langCtrl.changeLanguage('en'),
                              sw: sw,
                            ),
                          ),

                          SizedBox(height: sw * 0.04),

                          // Indonesia Option
                          Obx(
                            () => _LanguageOption(
                              title: 'Indonesia',
                              flagCode: 'id',
                              isSelected: langCtrl.selectedLang.value == 'id',
                              onTap: () => langCtrl.changeLanguage('id'),
                              sw: sw,
                            ),
                          ),

                          const Spacer(),

                          // Confirm Button
                          GestureDetector(
                            onTap: () => Get.to(() => const LoginPage()),
                            child: Container(
                              width: double.infinity,
                              height: sw * 0.135,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1976D2), Color(0xFF0E5DB5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(sw * 0.035),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1976D2)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'next'.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: rfs(context, 15),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom > 0
                                ? 0
                                : sw * 0.02,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String flagCode;
  final bool isSelected;
  final VoidCallback onTap;
  final double sw;

  const _LanguageOption({
    required this.title,
    required this.flagCode,
    required this.isSelected,
    required this.onTap,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: sw * 0.16,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F1FD) : Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade100,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          children: [

            // Flag
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                'https://flagcdn.com/w80/${flagCode.toLowerCase()}.png',
                width: sw * 0.08,
                height: sw * 0.055,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.flag),
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: rfs(context, 14),
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF1976D2)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            Container(
              width: sw * 0.055,
              height: sw * 0.055,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1976D2)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: sw * 0.04,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
