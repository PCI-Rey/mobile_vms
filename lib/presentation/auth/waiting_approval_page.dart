import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/constants/colors.dart';
import '../../data/datasources/auth_datasource.dart';
import '../dashboard.dart';
import 'controller/user_controller.dart';
import '../home/controllers/guest_home_controller.dart';
import '../../core/services/notification_service.dart';
import '../../data/datasources/hive_service.dart';
import 'verification_code_page.dart';

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

class _WaitingApprovalPageState extends State<WaitingApprovalPage>
    with TickerProviderStateMixin {
  final AuthDatasource _authDatasource = AuthDatasource();
  final RxBool _isChecking = false.obs;
  final RxBool _isApproved = false.obs;

  // Flag: true kalau form sudah disimpan/selesai (minimize atau approved)
  // Kalau false saat dispose(), auto-save ke Hive
  bool _alreadySavedOrDone = false;

  late final AnimationController _animationController;
  late final AnimationController _pulseController;
  late final AnimationController _successController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    // Auto-save ke Hive kalau form belum disimpan (e.g. back button / Get.offAll)
    if (!_alreadySavedOrDone) {
      _autoSaveToHive();
    }
    _animationController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  /// Simpan form ke Hive secara sinkron (dipanggil dari dispose)
  void _autoSaveToHive() {
    final hive = HiveService();
    final forms = hive.getMinimizedForms();
    final index = forms.indexWhere((e) => e['code'] == widget.invitationCode);
    final entry = {
      'code': widget.invitationCode,
      'message': widget.message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    if (index >= 0) {
      forms[index] = entry;
    } else {
      forms.add(entry);
    }
    // Gunakan fire-and-forget, dispose() tidak bisa await
    hive.saveMinimizedForms(forms);
  }

  Future<void> _minimizeForm() async {
    _alreadySavedOrDone = true; // Tandai sudah disimpan manual
    final hive = HiveService();
    final forms = hive.getMinimizedForms();

    final index = forms.indexWhere((e) => e['code'] == widget.invitationCode);
    if (index >= 0) {
      forms[index]['message'] = widget.message;
      forms[index]['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    } else {
      forms.add({
        'code': widget.invitationCode,
        'message': widget.message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await hive.saveMinimizedForms(forms);
    Get.offAll(() => const VerificationCodePage());
  }

  Future<void> _checkCurrentStatus() async {
    if (_isApproved.value) return;
    _isChecking.value = true;
    try {
      final (userModel, isPraregisterDone, rawData, message, title) =
          await _authDatasource.checkVisitorCode(widget.invitationCode);

      if (userModel != null && isPraregisterDone) {
        // Trigger success animations and redirecting button state
        _animationController.stop();
        _isApproved.value = true;
        _alreadySavedOrDone = true; // Tandai sudah selesai (approved)
        _pulseController.repeat(reverse: true);
        _successController.forward();

        Get.snackbar(
          (title ?? 'success').capitalizeFirst ?? 'Success',
          message ?? 'Pendaftaran disetujui! Anda berhasil masuk.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );

        // Wait exactly 3 seconds to let user see checkmark animation and redirecting state
        await Future.delayed(const Duration(seconds: 3));

        // Automatically login the user
        await _authDatasource.saveAuthData(userModel);
        final userCtrl = Get.isRegistered<UserController>()
            ? Get.find<UserController>()
            : Get.put(UserController());
        await userCtrl.loadUser();

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
                    vSpace(context, 10),

                    // Glowing Illustration
                    Obx(() {
                      final isApproved = _isApproved.value;
                      final primaryColor = isApproved ? Colors.green : AppColors.primary500;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft outer glow circle (with pulsing animation when approved!)
                          isApproved
                              ? ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: rw(context, 125),
                                    height: rw(context, 125),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green.withValues(alpha: 0.08),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: rw(context, 125),
                                  height: rw(context, 125),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary500.withValues(alpha: 0.08),
                                  ),
                                ),
                          // Inner glow circle
                          Container(
                            width: rw(context, 92),
                            height: rw(context, 92),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withValues(alpha: 0.12),
                            ),
                          ),
                          // Premium themed container
                          Container(
                            width: rw(context, 65),
                            height: rw(context, 65),
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
                            child: isApproved
                                ? ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Colors.green.shade600,
                                      size: rw(context, 38),
                                    ),
                                  )
                                : RotationTransition(
                                    turns: _animationController,
                                    child: Icon(
                                      Icons.history_toggle_off_rounded,
                                      color: AppColors.primary500,
                                      size: rw(context, 35),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    }),

                    vSpace(context, 15),

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

                    vSpace(context, 10),

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

                    vSpace(context, 10),

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

                    vSpace(context, 15),

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
                          vSpace(context, 10),
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
                    if (_isApproved.value) {
                      return ElevatedButton.icon(
                        onPressed: null, // Disable actions while redirecting
                        icon: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                        label: const Text(
                          'Redirecting...',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.green.shade600,
                          minimumSize: Size(double.infinity, rh(context, 48)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 12)),
                          ),
                          elevation: 0,
                        ),
                      );
                    }

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

                  // Minimize button
                  OutlinedButton(
                    onPressed: _minimizeForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: BorderSide(color: Colors.grey.shade300),
                      minimumSize: Size(double.infinity, rh(context, 48)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 12)),
                      ),
                    ),
                    child: const Text(
                      'Minimize / Sembunyikan',
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
