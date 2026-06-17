import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/forgot_password/input_email_page.dart';
import '../../presentation/auth/verification_code_page.dart';
import 'controller/login_controller.dart';
import '../../core/core.dart';
import '../../core/helper/responsive_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1976D2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * 0.40;

          return Stack(
            children: [
              // 1. Blue Header Background (Gradient)
              Container(
                width: double.infinity,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF0E5DB5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 2. Decorative Circles (For depth)
              Positioned(
                top: -sw * 0.2,
                right: -sw * 0.1,
                child: Container(
                  width: sw * 0.5,
                  height: sw * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.55,
                left: -sw * 0.15,
                child: Container(
                  width: sw * 0.4,
                  height: sw * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 3. Hero Content
              Container(
                width: double.infinity,
                height: heroHeight,
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Circle
                    SizedBox(
                      width: sw * 0.28,
                      height: sw * 0.28,
                      child: Image.asset(
                        'assets/images/VMS.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: sw * 0.05),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'VISITOR MANAGEMENT SYSTEM',
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
                      'login_hero_tagline'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. White Content Card
              Positioned(
                top: heroHeight * 0.92, // Slight overlap
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.06,
                      vertical: sw * 0.07,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: sw * 0.02),
                        Text(
                          'welcome_back'.tr,
                          style: TextStyle(
                            fontSize: rfs(context, 18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: sw * 0.01),
                        Text(
                          'login_subtitle'.tr,
                          style: TextStyle(
                            fontSize: rfs(context, 14),
                            color: const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: sw * 0.08),

                        // Form Fields
                        Obx(
                          () => _buildTextField(
                            controller: controller.usernameController,
                            label: 'username'.tr,
                            hintText: 'login_username_hint'.tr,
                            prefixIcon: Icons.person_outline,
                            errorText: controller.usernameError.value,
                            sw: sw,
                            context: context,
                          ),
                        ),
                        SizedBox(height: sw * 0.04),
                        Obx(
                          () => _buildTextField(
                            controller: controller.passwordController,
                            label: 'password'.tr,
                            hintText: 'login_password_hint'.tr,
                            prefixIcon: Icons.lock_outline,
                            isObscure: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  controller.togglePasswordVisibility(),
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF64748B),
                                size: sw * 0.05,
                              ),
                            ),
                            errorText: controller.passwordError.value,
                            sw: sw,
                            context: context,
                          ),
                        ),

                        SizedBox(height: sw * 0.03),
                        GestureDetector(
                          onTap: () => context.push(const InputEmailPage()),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'forgot_password'.tr,
                              style: TextStyle(
                                color: const Color(0xFF1976D2),
                                fontSize: rfs(context, 13),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: sw * 0.08),

                        // Login Button
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1976D2),
                              ),
                            );
                          }
                          return _buildPrimaryButton(
                            onPressed: () => controller.login(),
                            label: 'login'.tr,
                            sw: sw,
                            context: context,
                          );
                        }),

                        SizedBox(height: sw * 0.04),

                        // Guest Button
                        GestureDetector(
                          onTap: () =>
                              context.push(const VerificationCodePage()),
                          child: Container(
                            width: double.infinity,
                            height: sw * 0.135,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(sw * 0.035),
                              border: Border.all(
                                color: const Color(
                                  0xFF1976D2,
                                ).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'login_as_guest'.tr,
                                style: TextStyle(
                                  color: const Color(0xFF1976D2),
                                  fontSize: rfs(context, 15),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required double sw,
    required BuildContext context,
    bool isObscure = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: sw * 0.01, bottom: sw * 0.02),
          child: Text(
            label,
            style: TextStyle(
              fontSize: rfs(context, 14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: rfs(context, 14),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF1976D2),
              size: sw * 0.05,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF4F7FB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.04,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.035),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.035),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 1.5,
              ),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(height: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    required double sw,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: sw * 0.135,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0E5DB5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.035),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: rfs(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
