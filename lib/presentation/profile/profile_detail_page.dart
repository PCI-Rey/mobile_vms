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
        title: const Text('Akun'),
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
                              image: Assets.images.avaPerson1.image(),
                              size: rw(context, 100),
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
                    CustomTextField(
                      controller: controller.namaController,
                      label: 'Nama',
                      readOnly: true,
                      hintText: 'Nama Anda',
                    ),
                    CustomTextField(
                      controller: controller.emailController,
                      label: 'Email',
                      readOnly: true,
                      hintText: 'nama@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: controller.nomorHpController,
                      label: 'Nomor Handphone',
                      readOnly: true,
                      hintText: '0812 3456 7890',
                      keyboardType: TextInputType.phone,
                    ),
                    CustomTextField(
                      controller: controller.alamatController,
                      label: 'Alamat Rumah',
                      readOnly: true,
                      hintText: 'Jl. Melati No. 123',
                    ),
                    CustomTextField(
                      controller: controller.districtController,
                      label: 'Nama Distrik',
                      readOnly: true,
                      hintText: 'Nama Distrik',
                    ),
                    CustomTextField(
                      controller: controller.organisasiController,
                      label: 'Organisasi',
                      readOnly: true,
                      hintText: 'PT Maju Jaya',
                    ),
                    CustomTextField(
                      controller: controller.departemenController,
                      label: 'Departemen',
                      readOnly: true,
                      hintText: 'IT Support',
                    ),
                    vSpace(context, 16),
                    Text(
                      'Jenis Kelamin',
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
              label: 'Kembali',
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
