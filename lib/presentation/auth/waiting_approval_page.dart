import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/constants/colors.dart';
import '../../data/datasources/auth_datasource.dart';
import '../dashboard.dart';
import 'controller/user_controller.dart';
import '../home/controllers/guest_home_controller.dart';
import '../../core/services/notification_service.dart';

class WaitingApprovalPage extends StatefulWidget {
  final String invitationCode;
  final String message;

  const WaitingApprovalPage({
    super.key,
    required this.invitationCode,
    required this.message,
  });

  @override
  State<WaitingApprovalPage> createState() => _WaitingApprovalPageState();
}

class _WaitingApprovalPageState extends State<WaitingApprovalPage> {
  final AuthDatasource _authDatasource = AuthDatasource();
  final RxBool _isChecking = false.obs;

  Future<void> _checkCurrentStatus() async {
    _isChecking.value = true;
    try {
      final (userModel, isPraregisterDone, rawData, message, title) =
          await _authDatasource.checkVisitorCode(widget.invitationCode);

      if (userModel != null && isPraregisterDone) {
        // Automatically login the user
        await _authDatasource.saveAuthData(userModel);
        final userCtrl = Get.isRegistered<UserController>()
            ? Get.find<UserController>()
            : Get.put(UserController());
        await userCtrl.loadUser();

        Get.snackbar(
          (title ?? 'success').capitalizeFirst ?? 'Success',
          message ?? 'Pendaftaran disetujui! Anda berhasil masuk.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );

        // Ensure guest home data is fresh
        Get.delete<GuestHomeController>(force: true);
        
        Get.offAll(() => const Dashboard());

        // Subscribe to user topic
        if (userModel.id.isNotEmpty) {
          NotificationService.instance.subscribeToUserTopic(userModel.id);
        }
      } else {
        // Still pending or not approved yet
        final displayMsg = message ?? 'Permohonan Anda masih dalam proses peninjauan.';
        Get.snackbar(
          'Info Status',
          displayMsg,
          backgroundColor: AppColors.primary500,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Koneksi Error',
        'Gagal memeriksa status terbaru. Silakan coba sesaat lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isChecking.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 24),
                  vertical: rh(context, 24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    vSpace(context, 40),

                    // Glowing Illustration
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft outer glow circle
                        Container(
                          width: rw(context, 160),
                          height: rw(context, 160),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary500.withValues(alpha: 0.08),
                          ),
                        ),
                        // Inner glow circle
                        Container(
                          width: rw(context, 120),
                          height: rw(context, 120),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary500.withValues(alpha: 0.12),
                          ),
                        ),
                        // Premium gold-themed hourglass container
                        Container(
                          width: rw(context, 85),
                          height: rw(context, 85),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.history_toggle_off_rounded,
                            color: AppColors.primary500,
                            size: rw(context, 45),
                          ),
                        ),
                      ],
                    ),

                    vSpace(context, 32),

                    // Badge status
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 16),
                        vertical: rh(context, 6),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(rw(context, 20)),
                        border: Border.all(
                          color: AppColors.primary100,
                        ),
                      ),
                      child: Text(
                        'process_status'.tr == 'process_status'
                            ? 'DALAM PROSES / IN PROCESS'
                            : 'process_status'.tr,
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    vSpace(context, 20),

                    // Main title (Indonesian & English)
                    Text(
                      'Mohon Bersabar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rfs(context, 24),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    vSpace(context, 4),
                    Text(
                      'Please Wait a Moment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rfs(context, 15),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    vSpace(context, 20),

                    // Description card (shows dynamic API response)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(rw(context, 16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(context, 16)),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: rfs(context, 13.5),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),

                    vSpace(context, 28),

                    // Step Tracker Card (Beautiful timeline explanation)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(rw(context, 20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(context, 18)),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alur Pendaftaran / Registration Flow:',
                            style: TextStyle(
                              fontSize: rfs(context, 13),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          vSpace(context, 16),
                          _buildTimelineStep(
                            context: context,
                            icon: Icons.check_circle_rounded,
                            iconColor: Colors.green,
                            title: 'Formulir Terkirim / Form Submitted',
                            subtitle: 'Pendaftaran kunjungan Anda berhasil kami terima.',
                            isLast: false,
                          ),
                          _buildTimelineStep(
                            context: context,
                            icon: Icons.hourglass_top_rounded,
                            iconColor: Colors.orange,
                            title: 'Proses Peninjauan / Under Review',
                            subtitle: 'Host (tuan rumah) sedang memeriksa permohonan kunjungan Anda.',
                            isLast: false,
                          ),
                          _buildTimelineStep(
                            context: context,
                            icon: Icons.mark_email_unread_rounded,
                            iconColor: Colors.grey.shade400,
                            title: 'Notifikasi Keputusan / Final Notification',
                            subtitle: 'Hasil persetujuan akan dikirimkan otomatis ke email Anda.',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Actions
            Container(
              padding: EdgeInsets.fromLTRB(
                rw(context, 24),
                rh(context, 16),
                rw(context, 24),
                bottomPadding + rh(context, 16),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Refresh/Check Status Button
                  Obx(() {
                    if (_isChecking.value) {
                      return Container(
                        width: double.infinity,
                        height: rh(context, 48),
                        decoration: BoxDecoration(
                          color: AppColors.primary500,
                          borderRadius: BorderRadius.circular(rw(context, 12)),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      );
                    }
                    return ElevatedButton.icon(
                      onPressed: _checkCurrentStatus,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      label: const Text(
                        'Periksa Status / Check Status',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, rh(context, 48)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rw(context, 12)),
                        ),
                        elevation: 0,
                      ),
                    );
                  }),

                  vSpace(context, 12),

                  // Back to verification page button
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: BorderSide(color: Colors.grey.shade300),
                      minimumSize: Size(double.infinity, rh(context, 48)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 12)),
                      ),
                    ),
                    child: const Text(
                      'Kembali / Back',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(rw(context, 2)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: rw(context, 20), color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: rh(context, 35),
                color: Colors.grey.shade200,
              ),
          ],
        ),
        hSpace(context, 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: rfs(context, 12.5),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
              vSpace(context, 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: rfs(context, 11),
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              vSpace(context, 12),
            ],
          ),
        ),
      ],
    );
  }
}
