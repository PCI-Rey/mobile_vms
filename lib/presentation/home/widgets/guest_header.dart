import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/language_controller.dart';
import '../../auth/controller/user_controller.dart';
import '../../profile/profile_page.dart';

class GuestHeader extends StatelessWidget {
  final double sw;

  const GuestHeader({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageController.to;
    final userCtrl = UserController.to;

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.04, sw * 0.05, 0),
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
              size: sw * 0.11,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome'.tr,
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    color: Colors.white70,
                  ),
                ),
                Obx(
                  () => Text(
                    userCtrl.fullName,
                    style: TextStyle(
                      fontSize: rfs(context, 17),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLangSelector(context, langCtrl, sw),
        ],
      ),
    );
  }

  Widget _buildLangSelector(
    BuildContext context,
    LanguageController langCtrl,
    double sw,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: langCtrl.selectedLang.value == 'id' ? 'id' : 'en',
            icon: const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.white,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
