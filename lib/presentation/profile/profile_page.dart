import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/controller/user_controller.dart';
import '../../presentation/auth/login_page.dart';
import 'profile_dummy_pages.dart';
import 'profile_detail_page.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import 'package:url_launcher/url_launcher.dart';

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
        final bool isEmployee =
            (user?.roleAccess?.toLowerCase() == 'employee' ||
                user?.roleAccess?.toLowerCase() == 'admin') &&
            (user?.invitationCode == null || user!.invitationCode!.isEmpty) &&
            (user?.visitorCode == null || user!.visitorCode!.isEmpty);
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
                        image: isEmployee
                            ? Assets.images.avaPerson1.image(fit: BoxFit.cover)
                            : (UserController.to.faceUrl != null &&
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
                                    )),
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
                                borderRadius: BorderRadius.circular(
                                  rw(context, 30),
                                ),
                              ),
                              child: Text(
                                isEmployee
                                    ? (user?.roleAccess?.toUpperCase() ??
                                          'EMPLOYEE')
                                    : 'VISITOR',
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
            if (isEmployee)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: rw(context, 20),
                    right: rw(context, 20),
                    bottom: rh(context, 16),
                  ),
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
                          context.push(const DetailProfilePage());
                        },
                      ),
                      vSpace(context, 12),
                      TileMenu(
                        icon: Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: rw(context, 25),
                        ),
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
                        label: 'notification'.tr,
                        onTap: () {
                          context.push(const PemberitahuanPage());
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
                      vSpace(context, 12),
                      TileMenu(
                        icon: Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: rw(context, 25),
                        ),
                        label: 'help_center'.tr,
                        onTap: () {
                          context.push(const HelpCenterPage());
                        },
                      ),
                      vSpace(context, 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Related Products from Bio Experience',
                          style: TextStyle(
                            fontSize: rfs(context, 14),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      vSpace(context, 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductItem(
                              context,
                              Icons.meeting_room,
                              'Meeting\nRoom',
                            ),
                            hSpace(context, 16),
                            _buildProductItem(
                              context,
                              Icons.connected_tv,
                              'Hospitality\nTV',
                            ),
                            hSpace(context, 16),
                            _buildProductItem(
                              context,
                              Icons.person_pin_circle,
                              'Tracking\nPeople',
                            ),
                            hSpace(context, 16),
                            _buildProductItem(
                              context,
                              Icons.auto_mode,
                              'Automation',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
                child: Column(
                  children: [
                    TileMenu(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: rw(context, 25),
                      ),
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
                      label: 'notification'.tr,
                      onTap: () {
                        context.push(const PemberitahuanPage());
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
                    vSpace(context, 12),
                    TileMenu(
                      icon: Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: rw(context, 25),
                      ),
                      label: 'help_center'.tr,
                      onTap: () {
                        context.push(const HelpCenterPage());
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],

            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: rfs(context, 12)),
            ),
            vSpace(context, 12),

            // Logout button
            Container(
              width: double.infinity,
              height: rh(context, 41),
              margin: EdgeInsets.only(
                left: rw(context, 20),
                right: rw(context, 20),
                bottom: rw(context, 20),
              ),
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

  Widget _buildProductItem(BuildContext context, IconData icon, String label) {
    return SizedBox(
      width: rw(context, 85),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse('https://bio-experience.com/');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                Get.snackbar('Error', 'Could not launch product page.');
              }
            },
            canRequestFocus: false,
            customBorder: const CircleBorder(),
            child: Container(
              width: rw(context, 52),
              height: rw(context, 52),
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2), // Flat color matching VMS menu icons
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: rw(context, 24)),
            ),
          ),
          vSpace(context, 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rfs(context, 11),
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
