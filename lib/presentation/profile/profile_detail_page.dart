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
        automaticallyImplyLeading: false, // Hapus icon back kiri atas
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(rw(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
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
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(rw(context, 6)),
                                  decoration: BoxDecoration(
                                    color: context.theme.primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: rw(context, 16),
                                  ),
                                ),
                              ),
                            ],
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
                    CustomTextField(
                      controller: controller.namaController,
                      label: 'Name',
                      readOnly: true,
                      hintText: 'Your Name',
                      suffixIconData: Icons.edit_outlined,
                    ),
                    CustomTextField(
                      controller: controller.emailController,
                      label: 'Email',
                      readOnly: true,
                      hintText: 'name@email.com',
                      keyboardType: TextInputType.emailAddress,
                      suffixIconData: Icons.edit_outlined,
                    ),
                    CustomTextField(
                      controller: controller.nomorHpController,
                      label: 'Phone Number',
                      readOnly: true,
                      hintText: '0812 3456 7890',
                      keyboardType: TextInputType.phone,
                      suffixIconData: Icons.edit_outlined,
                    ),
                    CustomTextField(
                      controller: controller.alamatController,
                      label: 'Home Address',
                      readOnly: true,
                      hintText: 'Jl. Melati No. 123',
                      suffixIconData: Icons.edit_outlined,
                    ),
                    CustomTextField(
                      controller: controller.districtController,
                      label: 'District Name',
                      readOnly: true,
                      hintText: 'District Name',
                      suffixIconData: Icons.edit_outlined,
                    ),
                    CustomTextField(
                      controller: controller.organisasiController,
                      label: 'Organization',
                      readOnly: true,
                      hintText: 'PT Maju Jaya',
                      suffixIconData: Icons.edit_outlined,
                    ),
                    CustomTextField(
                      controller: controller.departemenController,
                      label: 'Department',
                      readOnly: true,
                      hintText: 'IT Support',
                      suffixIconData: Icons.edit_outlined,
                    ),
                    vSpace(context, 16),
                    Text(
                      'Gender',
                      style: TextStyle(fontSize: rfs(context, 14), fontWeight: FontWeight.w600),
                    ),
                    vSpace(context, 12),
                    Obx(() => IgnorePointer(
                      child: GenderToggleButton(
                        selectedGender: controller.selectedGender.value,
                        onChanged: (gender) {},
                      ),
                    )),
                    vSpace(context, 20),
                  ],
                ),
              );
            }),
          ),
          
          // Sticky Bottom Button
          Padding(
            padding: EdgeInsets.all(rw(context, 20)),
            child: Button.filled(
              label: 'Back',
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
