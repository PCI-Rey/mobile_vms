import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      label: 'Kecamatan / Daerah',
                      readOnly: true,
                      hintText: 'Kecamatan ABC',
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
                    const SpaceHeight(16),
                    const Text(
                      'Jenis Kelamin',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SpaceHeight(12),
                    Obx(() => IgnorePointer(
                      child: GenderToggleButton(
                        selectedGender: controller.selectedGender.value,
                        onChanged: (gender) {},
                      ),
                    )),
                    const SpaceHeight(20),
                  ],
                ),
              );
            }),
          ),
          
          // Sticky Bottom Button
          Padding(
            padding: const EdgeInsets.all(20),
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

