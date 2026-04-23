import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/auth/forgot_password/input_email_page.dart';
import '../../presentation/auth/verification_code_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'controller/login_controller.dart';
import '../../core/core.dart';

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
    // Register controller once — safe even if already registered
    controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header section - fixed height
                    ClipPath(
                      clipper: BottomWaveClipper(),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.35,
                        color: AppColors.primary500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Assets.images.iconApp.image(height: 100),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    // Content section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title section
                            Text(
                              'welcome_back'.tr,
                              style: TextStyles.headline4,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'login_subtitle'.tr,
                              textAlign: TextAlign.center,
                            ),
                            const SpaceHeight(20),

                            // Form section
                            Obx(
                              () => CustomTextField(
                                controller: controller.usernameController,
                                label: 'username'.tr,
                                isRequired: true,
                                errorText: controller.usernameError.value,
                              ),
                            ),
                            const SpaceHeight(10),
                            Obx(
                              () => CustomTextField(
                                controller: controller.passwordController,
                                label: 'password'.tr,
                                isRequired: true,
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

                            const SpaceHeight(15),

                            GestureDetector(
                              onTap: () {
                                context.push(InputEmailPage());
                              },
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'forgot_password'.tr,
                                  style: TextStyles.subtitle3,
                                ),
                              ),
                            ),

                            // Push buttons to the bottom
                            const Spacer(),
                            const SpaceHeight(20),

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
                                label: 'login'.tr,
                              );
                            }),

                            const SpaceHeight(15),
                            
                            // Guest button
                            Button.outlined(
                              height: 41,
                              onPressed: () {
                                context.push(VerificationCodePage());
                              },
                              label: 'login_as_guest'.tr,
                            ),
                            
                            const SpaceHeight(10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
