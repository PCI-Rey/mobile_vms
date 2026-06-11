import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/controller/user_controller.dart';
import '../../presentation/auth/login_page.dart';
import 'profile_dummy_pages.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'profile'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        final user = UserController.to.user.value;
        return Column(
          children: [
            // Header section
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: rh(context, 80),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(rw(context, 30)),
                      bottomRight: Radius.circular(rw(context, 30)),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: rh(context, 20),
                    left: rw(context, 20),
                    right: rw(context, 20),
                  ),
                  padding: EdgeInsets.all(rw(context, 20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rw(context, 16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CustomCircleImage(
                        image: UserController.to.faceUrl != null &&
                                UserController.to.faceUrl!.isNotEmpty
                            ? Image.network(
                                UserController.to.faceUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFFE2E8F0),
                                  child: Icon(
                                    Icons.person,
                                    color: const Color(0xFF94A3B8),
                                    size: rw(context, 36),
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFE2E8F0),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF94A3B8),
                                  size: rw(context, 36),
                                ),
                              ),
                        size: rw(context, 65),
                        scale: 1.5,
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
                            vSpace(context, 2),
                            Text(
                              user?.email ?? 'mail@example.com',
                              style: TextStyle(
                                fontSize: rfs(context, 14),
                                color: Colors.grey.shade600,
                              ),
                            ),
                            vSpace(context, 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(context, 12),
                                vertical: rh(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F3FB),
                                borderRadius: BorderRadius.circular(rw(context, 30)),
                              ),
                              child: Text(
                                user?.roleAccess?.toUpperCase() ?? 'GUEST',
                                style: TextStyle(
                                  fontSize: rfs(context, 12),
                                  color: const Color(0xff1976D2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            vSpace(context, 24),

            // Menu section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
              child: Column(
                children: [
                  TileMenu(
                    icon: Icon(Icons.lock, color: Colors.white, size: rw(context, 25)),
                    label: 'security'.tr,
                    onTap: () {
                      context.push(const SecurityPage());
                    },
                  ),
                  vSpace(context, 12),
                  TileMenu(
                    icon: Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: rw(context, 25),
                    ),
                    label: 'Notification',
                    onTap: () {
                      context.push(const PemberitahuanPage());
                    },
                  ),
                  vSpace(context, 12),
                  TileMenu(
                    icon: Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: rw(context, 25),
                    ),
                    label: 'Help Center'.tr,
                    onTap: () {
                      context.push(const HelpCenterPage());
                    },
                  ),
                  vSpace(context, 12),
                  TileMenu(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: rw(context, 25),
                    ),
                    label: 'Barcode'.tr,
                    onTap: () {
                      context.push(const BarcodePage());
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            Text(
              'Version 1.0.0',
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
