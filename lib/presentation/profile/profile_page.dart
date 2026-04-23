import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/controller/user_controller.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/profile/profile_detail_page.dart';
import '../../core/core.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F3FB),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('profile'.tr, style: const TextStyle(color: Colors.black)),
      ),
      body: Obx(() {
        final user = UserController.to.user.value;
        return Column(
          children: [
            // Header section
            Container(
              color: const Color(0xFFE3F3FB),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  CustomCircleImage(
                    image: Assets.images.avaPerson1.image(),
                    size: 60,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullname ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? 'mail@example.com',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffD6F0FF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            user?.roleAccess?.toUpperCase() ?? 'GUEST',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff1976D2),
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

            const SizedBox(height: 16),

            // Menu section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TileMenu(
                    icon: const Icon(Icons.person, color: Colors.white, size: 25),
                    label: 'account'.tr,
                    onTap: () {
                      context.push(DetailProfilePage());
                    },
                  ),
                  const SizedBox(height: 12),
                  TileMenu(
                    icon: const Icon(Icons.lock, color: Colors.white, size: 25),
                    label: 'security'.tr,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Logout button
            Container(
              width: double.infinity,
              height: 41,
              margin: const EdgeInsets.all(20),
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
                              content: Text(
                                'confirm_logout'.tr,
                              ),
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
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: AppColors.error500,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
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
