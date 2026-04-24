import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import 'controller/verification_code_controller.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  late final VerificationCodeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<VerificationCodeController>()
        ? Get.find<VerificationCodeController>()
        : Get.put(VerificationCodeController());

    // Clear the code and error every time we enter the page
    controller.invitationCodeController.clear();
    controller.codeError.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        ClipPath(
                          clipper: BottomWaveClipper(),
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.45,
                            color: AppColors.primary500,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.images.iconApp.image(height: 122),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SpaceHeight(20),
                                Text(
                                  'verify_code'.tr,
                                  style: TextStyles.headline4,
                                ),
                                Text('enter_invitation_code'.tr),
                                const SpaceHeight(10),

                                Obx(
                                  () => CustomTextField(
                                    controller:
                                        controller.invitationCodeController,
                                    label: 'invitation_code'.tr,
                                    errorText: controller.codeError.value,
                                  ),
                                ),

                                const SpaceHeight(20),
                                const Spacer(),

                                Obx(() {
                                  if (controller.isLoading.value) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary500,
                                      ),
                                    );
                                  }
                                  return Button.filled(
                                    onPressed: () {
                                      controller.verifyCode();
                                    },
                                    label: 'verify'.tr,
                                  );
                                }),

                                const SizedBox(height: 30),
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}
