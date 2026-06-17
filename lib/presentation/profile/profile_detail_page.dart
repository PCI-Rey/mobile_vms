import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/helper/responsive_helper.dart';
import '../../core/core.dart';
import 'controller/detail_profile_controller.dart';

class DetailProfilePage extends StatelessWidget {
  const DetailProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetailProfileController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Account'),
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.isSaving.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }
            if (controller.isEditing.value) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => controller.saveProfile(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => controller.cancelEditing(),
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: Icon(Icons.edit, color: context.theme.primaryColor),
                onPressed: () => controller.startEditing(),
              );
            }
          }),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: rw(context, 20),
              right: rw(context, 20),
              top: rw(context, 20),
              bottom: rh(context, 40),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(rw(context, 4)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.theme.primaryColor.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: CustomCircleImage(
                          image: Assets.images.avaPerson1.image(fit: BoxFit.cover),
                          size: rw(context, 100),
                          scale: 1.5,
                        ),
                      ),
                      vSpace(context, 16),
                      Obx(() => Text(
                            controller.namaHeader.value,
                            style: TextStyle(
                              fontSize: rfs(context, 20),
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Obx(() => controller.roleLabel.value.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                vSpace(context, 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: rw(context, 12), vertical: rh(context, 4)),
                                  decoration: BoxDecoration(
                                    color: context.theme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(rw(context, 20)),
                                  ),
                                  child: Text(
                                    controller.roleLabel.value.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: context.theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                    ],
                  ),
                ),
                vSpace(context, 32),
                Obx(() => GestureDetector(
                  onTap: () {
                    if (!controller.isEditing.value) {
                      controller.showEditInfo();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AbsorbPointer(
                    absorbing: !controller.isEditing.value,
                    child: CustomTextField(
                      controller: controller.namaController,
                      label: 'Name',
                      readOnly: !controller.isEditing.value,
                      hintText: 'Your Name',
                    ),
                  ),
                )),
                Obx(() => GestureDetector(
                  onTap: () {
                    if (!controller.isEditing.value) {
                      controller.showEditInfo();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AbsorbPointer(
                    absorbing: !controller.isEditing.value,
                    child: CustomTextField(
                      controller: controller.emailController,
                      label: 'Email',
                      readOnly: !controller.isEditing.value,
                      hintText: 'name@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                )),
                Obx(() => GestureDetector(
                  onTap: () {
                    if (!controller.isEditing.value) {
                      controller.showEditInfo();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AbsorbPointer(
                    absorbing: !controller.isEditing.value,
                    child: CustomTextField(
                      controller: controller.nomorHpController,
                      label: 'Phone Number',
                      readOnly: !controller.isEditing.value,
                      hintText: '0812 3456 7890',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                )),
                Obx(() => GestureDetector(
                  onTap: () {
                    if (!controller.isEditing.value) {
                      controller.showEditInfo();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AbsorbPointer(
                    absorbing: !controller.isEditing.value,
                    child: CustomTextField(
                      controller: controller.alamatController,
                      label: 'Home Address',
                      readOnly: !controller.isEditing.value,
                      hintText: 'Jl. Melati No. 123',
                    ),
                  ),
                )),

                vSpace(context, 16),
                Text(
                  'Gender',
                  style: TextStyle(fontSize: rfs(context, 14), fontWeight: FontWeight.w600),
                ),
                vSpace(context, 12),
                Obx(() => GestureDetector(
                  onTap: () {
                    if (!controller.isEditing.value) {
                      controller.showEditInfo();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AbsorbPointer(
                    absorbing: !controller.isEditing.value,
                    child: GenderToggleButton(
                      selectedGender: controller.selectedGender.value,
                      onChanged: (gender) {
                        controller.selectedGender.value = gender;
                      },
                    ),
                  ),
                )),
                vSpace(context, 20),
              ],
            ),
          );
        }),
      ),
    );
  }
}
