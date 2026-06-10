import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/controller/user_controller.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/profile/profile_detail_page.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'profile'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        final user = UserController.to.user.value;
        return Column(
          children: [
            // Header section
            Container(
              color: const Color(0xFFE3F3FB),
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 16)),
              child: Row(
                children: [
                  CustomCircleImage(
                    image: Assets.images.avaPerson1.image(),
                    size: rw(context, 60),
                  ),
                  hSpace(context, 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullname ?? 'User',
                          style: TextStyle(
                            fontSize: rfs(context, 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? 'mail@example.com',
                          style: TextStyle(fontSize: rfs(context, 14)),
                        ),
                        vSpace(context, 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(context, 8),
                            vertical: rh(context, 2),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffD6F0FF),
                            borderRadius: BorderRadius.circular(rw(context, 30)),
                          ),
                          child: Text(
                            user?.roleAccess?.toUpperCase() ?? 'GUEST',
                            style: TextStyle(
                              fontSize: rfs(context, 12),
                              color: const Color(0xff1976D2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            vSpace(context, 16),

            // Menu section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
              child: Column(
                children: [
                  TileMenu(
                    icon: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: rw(context, 25),
                    ),
                    label: 'account'.tr,
                    onTap: () {
                      context.push(DetailProfilePage());
                    },
                  ),
                  vSpace(context, 12),
                  TileMenu(
                    icon: Icon(Icons.lock, color: Colors.white, size: rw(context, 25)),
                    label: 'security'.tr,
                    onTap: () {},
                  ),
                  vSpace(context, 12),
                  TileMenu(
                    icon: Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: rw(context, 25),
                    ),
                    label: 'Pemberitahuan'.tr,
                    onTap: () {},
                  ),
                  vSpace(context, 12),
                  TileMenu(
                    icon: Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: rw(context, 25),
                    ),
                    label: 'Help Center'.tr,
                    onTap: () {},
                  ),
                  vSpace(context, 12),
                  TileMenu(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: rw(context, 25),
                    ),
                    label: 'Barcode'.tr,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const Spacer(),

            Text(
              'Versi 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: rfs(context, 12)),
            ),
            vSpace(context, 8),

            // Logout button
            Container(
              width: double.infinity,
              height: rh(context, 41),
              margin: EdgeInsets.all(rw(context, 20)),
              child: Obx(() {
                final isLoading = UserController.to.isLoggingOut.value;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                           if (Get.isDialogOpen == true) return;

                           final confirm = await Get.dialog<bool>(
                             AlertDialog(
                               title: Text('confirm_exit'.tr),
                               content: Text('confirm_logout'.tr),
                               actions: [
                                 TextButton(
                                   onPressed: () => Get.back(result: false),
                                   child: Text('cancel'.tr),
                                 ),
                                 ElevatedButton(
                                   onPressed: () => Get.back(result: true),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: Colors.red,
                                     elevation: 0,
                                   ),
                                   child: Text(
                                     'logout'.tr,
                                     style: const TextStyle(color: Colors.white),
                                   ),
                                 ),
                               ],
                             ),
                           );
                           if (confirm == true) {
                             await UserController.to.clearUser();
                             Get.offAll(() => LoginPage());
                           }
                         },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rw(context, 10)),
                      side: const BorderSide(
                        color: AppColors.error500,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: rw(context, 20),
                          height: rw(context, 20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error500,
                          ),
                        )
                      : Text(
                          'logout'.tr,
                          style: const TextStyle(color: AppColors.error500),
                        ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
