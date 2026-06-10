import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/language_controller.dart';
import '../../auth/controller/user_controller.dart';
import '../../profile/profile_page.dart';

class GuestHeader extends StatelessWidget {
  const GuestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.to;
    final userCtrl = UserController.to;

    return Padding(
      padding: EdgeInsets.fromLTRB(rw(context, 20), rh(context, 16), rw(context, 20), 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const ProfilePage()),
            child: CustomCircleImage(
              image: userCtrl.faceUrl != null
                  ? Image.network(
                      userCtrl.faceUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Assets.images.avaPerson1.image(fit: BoxFit.cover),
                    )
                  : Assets.images.avaPerson1.image(fit: BoxFit.cover),
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
          _buildLangSelector(context, langCtrl),
        ],
      ),
    );
  }

  Widget _buildLangSelector(
    BuildContext context,
    LanguageController langCtrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(rw(context, 20)),
        color: Colors.white.withValues(alpha: 0.18),
      ),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 10), vertical: rh(context, 2)),
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
