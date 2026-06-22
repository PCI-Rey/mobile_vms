import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/language_controller.dart';
import '../../auth/controller/user_controller.dart';
import '../../notification/notification_page.dart';

import '../../profile/profile_page.dart';

class GuestHeader extends StatelessWidget {
  const GuestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.to;
    final userCtrl = UserController.to;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        rw(context, 20),
        rh(context, 16),
        rw(context, 20),
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const ProfilePage()),
            child: CustomCircleImage(
              image: userCtrl.faceUrl != null && userCtrl.faceUrl!.isNotEmpty
                  ? Image.network(
                      userCtrl.faceUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFE2E8F0),
                        child: Icon(
                          Icons.person,
                          color: const Color(0xFF94A3B8),
                          size: rw(context, 26),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFE2E8F0),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF94A3B8),
                        size: rw(context, 26),
                      ),
                    ),
              size: rw(context, 48),
            ),
          ),
          hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome'.tr,
                  style: TextStyle(
                    fontSize: rfs(context, 22),
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
          _buildActionButtons(context, langCtrl),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    LanguageController langCtrl,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLangSelector(context, langCtrl),
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
