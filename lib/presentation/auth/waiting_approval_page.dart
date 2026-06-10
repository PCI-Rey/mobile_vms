import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/constants/colors.dart';
import '../../data/datasources/auth_datasource.dart';
import '../dashboard.dart';
import 'controller/user_controller.dart';
import '../home/controllers/guest_home_controller.dart';
import '../../core/services/notification_service.dart';
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
    _animationController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _closePage() {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 28),
                  vertical: rh(context, 32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    vSpace(context, 24),

                    // ── Animated Icon (unchanged logic) ──────────────
                    Obx(() {
                      final isApproved = _isApproved.value;
                      final primaryColor =
                          isApproved ? Colors.green : AppColors.primary500;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          isApproved
                              ? ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: rw(context, 120),
                                    height: rw(context, 120),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green.withValues(alpha: 0.08),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: rw(context, 120),
                                  height: rw(context, 120),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary500.withValues(alpha: 0.08),
                                  ),
                                ),
                          Container(
                            width: rw(context, 88),
                            height: rw(context, 88),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withValues(alpha: 0.12),
                            ),
                          ),
                          Container(
                            width: rw(context, 60),
                            height: rw(context, 60),
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
                                      size: rw(context, 32),
                                    ),
                                  )
                                : RotationTransition(
                                    turns: _animationController,
                                    child: Icon(
                                      Icons.history_toggle_off_rounded,
                                      color: AppColors.primary500,
                                      size: rw(context, 30),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    }),

                    vSpace(context, 28),

                    // ── Title ─────────────────────────────────────────
                    Text(
                      'Waiting for Approval',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rfs(context, 20),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),

                    vSpace(context, 12),

                    // ── Status message from API ───────────────────────
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        height: 1.55,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    vSpace(context, 24),

                    // ── Invitation code chip ──────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 16),
                        vertical: rh(context, 10),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: rw(context, 16),
                            color: AppColors.primary500,
                          ),
                          hSpace(context, 8),
                          Text(
                            widget.invitationCode,
                            style: TextStyle(
                              fontSize: rfs(context, 13),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Spacer pushes steps to center ─────────────────
                    const Spacer(),

                    // ── Progress steps (minimal) ─────────────────────
                    _buildMinimalStep(
                      context,
                      number: '1',
                      label: 'Form submitted successfully',
                      done: true,
                    ),
                    _buildStepDivider(context),
                    _buildMinimalStep(
                      context,
                      number: '2',
                      label: 'Under review by host',
                      done: false,
                      active: true,
                    ),
                    _buildStepDivider(context),
                    _buildMinimalStep(
                      context,
                      number: '3',
                      label: 'Decision notification via email',
                      done: false,
                    ),
                    _buildStepDivider(context),
                    _buildMinimalStep(
                      context,
                      number: '4',
                      label: 'You can log in again using the code provided',
                      done: false,
                    ),

                    // ── Spacer balances steps in center ───────────────
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // ── Bottom Actions ───────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                rw(context, 24),
                rh(context, 16),
                rw(context, 24),
                bottomPadding + rh(context, 16),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Check Status / Redirecting button
                  Obx(() {
                    if (_isApproved.value) {
                      return ElevatedButton.icon(
                        onPressed: null,
                        icon: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                        label: const Text(
                          'Redirecting...',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.green.shade600,
                          minimumSize: Size(double.infinity, rh(context, 48)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 10)),
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
                          borderRadius: BorderRadius.circular(rw(context, 10)),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
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
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Check Status',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, rh(context, 48)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rw(context, 10)),
                        ),
                        elevation: 0,
                      ),
                    );
                  }),

                  vSpace(context, 8),

                  // Close button
                  TextButton(
                    onPressed: _closePage,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      minimumSize: Size(double.infinity, rh(context, 44)),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: rfs(context, 13.5),
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildMinimalStep(
    BuildContext context, {
    required String number,
    required String label,
    required bool done,
    bool active = false,
  }) {
    Color iconBg = const Color(0xFFF1F5F9);
    Color textColor = const Color(0xFF64748B);
    Color numberColor = const Color(0xFF94A3B8);
    FontWeight fontWeight = FontWeight.w400;

    if (done) {
      iconBg = Colors.green.withValues(alpha: 0.1);
      textColor = const Color(0xFF334155);
      fontWeight = FontWeight.w500;
    } else if (active) {
      iconBg = AppColors.primary500.withValues(alpha: 0.1);
      textColor = const Color(0xFF0F172A);
      numberColor = AppColors.primary500;
      fontWeight = FontWeight.w600;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
      child: Row(
        children: [
          Container(
            width: rw(context, 26),
            height: rw(context, 26),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
            ),
            child: Center(
              child: done
                  ? Icon(Icons.check_rounded, size: rw(context, 14), color: Colors.green)
                  : Text(
                      number,
                      style: TextStyle(
                        fontSize: rfs(context, 11),
                        fontWeight: FontWeight.w700,
                        color: numberColor,
                      ),
                    ),
            ),
          ),
          hSpace(context, 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: rw(context, 29)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 1.5,
          height: rh(context, 16),
          color: const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}
