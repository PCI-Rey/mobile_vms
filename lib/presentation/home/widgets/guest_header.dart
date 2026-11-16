import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/language_controller.dart';
import '../../auth/controller/user_controller.dart';
import '../controllers/guest_home_controller.dart';
import '../../profile/profile_page.dart';

class GuestHeader extends StatelessWidget {
  const GuestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.to;
    final userCtrl = UserController.to;
    final guestCtrl = Get.isRegistered<GuestHomeController>()
        ? GuestHomeController.to
        : Get.put(GuestHomeController());

    return Padding(
      padding: EdgeInsets.fromLTRB(
        rw(context, 16),
        rh(context, 6),
        rw(context, 16),
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const ProfilePage()),
            child: Obx(() {
              final activeImageUrl = guestCtrl.currentSelfieUrl;
              return CustomCircleImage(
                image: activeImageUrl != null && activeImageUrl.isNotEmpty
                    ? Image.network(
                        activeImageUrl,
                        key: ValueKey(activeImageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: Icon(
                            Icons.person,
                            color: const Color(0xFF94A3B8),
                            size: rw(context, 22),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE2E8F0),
                        child: Icon(
                          Icons.person,
                          color: const Color(0xFF94A3B8),
                          size: rw(context, 22),
                        ),
                      ),
                size: rw(context, 40),
              );
            }),
          ),
          hSpace(context, 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'welcome'.tr,
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Obx(
                  () => Text(
                    userCtrl.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: rfs(context, 15),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildActionButtons(context, langCtrl),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    LanguageController langCtrl,
  ) {
    return _buildLangSelector(context, langCtrl);
  }

  Widget _buildLangSelector(BuildContext context, LanguageController langCtrl) {
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
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: langCtrl.selectedLang.value == 'id' ? 'id' : 'en',
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
            onChanged: (v) {
              if (v != null) langCtrl.changeLanguage(v);
            },
          ),
        ),
      ),
    );
  }
}
