import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/extensions/build_context_ext.dart';
import '../../presentation/auth/forgot_password/input_email_page.dart';
import '../../presentation/auth/verification_code_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'controller/login_controller.dart';
import '../../core/core.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller manually since we are not using GetX routing with Bindings yet
    Get.put(LoginController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header section - fixed height
          ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(
              width: double.infinity,
              height:
                  MediaQuery.of(context).size.height * 0.30, // Reduced slightly
              color: AppColors.primary500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.images.iconApp.image(height: 80), // Reduced size
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Content section - takes remaining space and adapts to keyboard
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate available height minus keyboard
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final availableHeight = constraints.maxHeight - keyboardHeight;

                return Container(
                  height: availableHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ).copyWith(top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title section
                      Text(
                        'Masuk',
                        style: TextStyles.headline4,
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Masukkan username dan kata sandi Anda',
                        textAlign: TextAlign.center,
                      ),

                      // Flexible spacing
                      SizedBox(height: keyboardHeight > 0 ? 15 : 20),

                      // Form section
                      Obx(
                        () => CustomTextField(
                          controller: controller.usernameController,
                          label: 'Username',
                          errorText: controller.usernameError.value,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => CustomTextField(
                          controller: controller.passwordController,
                          label: 'Password',
                          isObscure: controller.obscurePassword.value,
                          suffixIconData: controller.obscurePassword.value
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.eye,
                          onTapSuffixIcon: () {
                            controller.togglePasswordVisibility();
                          },
                          errorText: controller.passwordError.value,
                        ),
                      ),

                      // Flexible spacing
                      SizedBox(height: keyboardHeight > 0 ? 10 : 15),

                      GestureDetector(
                        onTap: () {
                          context.push(InputEmailPage());
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Lupa kata sandi',
                            style: TextStyles.subtitle3,
                          ),
                        ),
                      ),

                      // Spacer to push buttons to bottom when keyboard is not showing
                      if (keyboardHeight == 0) const Spacer(),

                      // Flexible spacing before buttons
                      SizedBox(height: keyboardHeight > 0 ? 20 : 40),

                      // Login button
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary500,
                            ),
                          );
                        }
                        return Button.filled(
                          height: 41,
                          onPressed: () {
                            controller.login();
                          },
                          label: 'Masuk',
                        );
                      }),

                      const SizedBox(height: 15), // Reduced spacing
                      // Guest button
                      Button.outlined(
                        height: 41,
                        onPressed: () {
                          context.push(VerificationCodePage());
                        },
                        label: 'Masuk sebagai Guest/Visitor',
                      ),

                      // Bottom padding when keyboard is showing
                      if (keyboardHeight > 0) const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
