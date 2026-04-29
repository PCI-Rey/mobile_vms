import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import 'controller/verification_code_controller.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  late final VerificationCodeController controller;

  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0E5DB5);
  static const _bgPage = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<VerificationCodeController>()
        ? Get.find<VerificationCodeController>()
        : Get.put(VerificationCodeController());

    controller.invitationCodeController.clear();
    controller.codeError.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final bottom = mq.padding.bottom;

    return Scaffold(
      backgroundColor: _blue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // ── Blue top zone (Gradient) ───────────────────────
              Container(
                height: constraints.maxHeight * 0.42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_blue, _blueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // ── Decorative circles ────────────────────────────
              Positioned(
                top: -sw * 0.2,
                right: -sw * 0.15,
                child: Container(
                  width: sw * 0.6,
                  height: sw * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.15,
                left: -sw * 0.1,
                child: Container(
                  width: sw * 0.4,
                  height: sw * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // ── Main content ──────────────────────────────────
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Hero zone
                    SizedBox(
                      height: constraints.maxHeight * 0.42 - mq.padding.top,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Circle
                          Container(
                            width: sw * 0.28,
                            height: sw * 0.28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(sw * 0.05),
                            child: Image.asset(
                              'assets/images/VMS.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(height: sw * 0.05),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'VIRTUAL MANAGEMENT SYSTEM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: rfs(context, 20),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          SizedBox(height: sw * 0.015),

                          Text(
                            'verify_code'.tr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: rfs(context, 13),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── White bottom card ─────────────────────────
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _bgPage,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            sw * 0.06,
                            sw * 0.07,
                            sw * 0.06,
                            bottom + sw * 0.06,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section title
                              Center(
                                child: Text(
                                  'enter_invitation_code'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: rfs(context, 20),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              SizedBox(height: sw * 0.015),
                              Center(
                                child: Text(
                                  'enter_invitation_code_desc'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: rfs(context, 13),
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),

                              SizedBox(height: sw * 0.08),

                              // Code input field label
                              Text(
                                'invitation_code'.tr,
                                style: TextStyle(
                                  fontSize: rfs(context, 13),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: sw * 0.02),

                              // Input field — styled to match login page
                              Obx(
                                () => TextFormField(
                                  controller:
                                      controller.invitationCodeController,
                                  style: TextStyle(
                                    fontSize: rfs(context, 14),
                                    color: const Color(0xFF1E293B),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'enter_code_hint'.tr,
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: rfs(context, 14),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.vpn_key_outlined,
                                      color: _blue,
                                      size: sw * 0.055,
                                    ),
                                    errorText: controller.codeError.value,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.04,
                                      vertical: sw * 0.04,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.035,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.035,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.035,
                                      ),
                                      borderSide: const BorderSide(
                                        color: _blue,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.035,
                                      ),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE24B4A),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.035,
                                      ),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE24B4A),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: sw * 0.06),

                              // Info hint box
                              Container(
                                padding: EdgeInsets.all(sw * 0.04),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F1FD),
                                  borderRadius: BorderRadius.circular(
                                    sw * 0.03,
                                  ),
                                  border: Border.all(
                                    color: _blue.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: _blue,
                                      size: sw * 0.05,
                                    ),
                                    SizedBox(width: sw * 0.03),
                                    Expanded(
                                      child: Text(
                                        'invitation_code_hint'.tr,
                                        style: TextStyle(
                                          fontSize: rfs(context, 12),
                                          color: _blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sw * 0.08),

                              // Verify button — gradient primary style
                              Obx(() {
                                if (controller.isLoading.value) {
                                  return Container(
                                    width: double.infinity,
                                    height: sw * 0.135,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [_blue, _blueDark],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.035,
                                      ),
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
                                return GestureDetector(
                                  onTap: () => controller.verifyCode(),
                                  child: Container(
                                    width: double.infinity,
                                    height: sw * 0.135,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [_blue, _blueDark],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.035,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _blue.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'verify'.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: rfs(context, 15),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Back button ───────────────────────────────────
              Positioned(
                top: mq.padding.top + sw * 0.02,
                left: sw * 0.02,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
