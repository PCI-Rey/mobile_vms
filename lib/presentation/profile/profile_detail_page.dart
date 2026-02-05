import 'dart:io';

import 'package:flutter/material.dart';
import '../../presentation/auth/take_selfie_page.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/core.dart';

class DetailProfilePage extends StatefulWidget {
  const DetailProfilePage({super.key});

  @override
  State<DetailProfilePage> createState() => _DetailProfilePageState();
}

class _DetailProfilePageState extends State<DetailProfilePage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nomorHpController = TextEditingController();
  TextEditingController organisasiController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController nikController = TextEditingController();
  Gender selectedGender = Gender.male;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Akun'),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  // Foto profil utama
                  CircleAvatar(
                    radius: 40, // 80 / 2
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/images/ava_person1.png')
                              as ImageProvider,
                  ),
                  // Ikon kamera di pojok kanan bawah
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomTextField(
              controller: namaController,
              label: 'Nama',
              hintText: 'Nama Anda',
            ),
            CustomTextField(
              controller: emailController,
              label: 'Email',
              hintText: 'nama@email.com',
            ),
            CustomTextField(
              controller: nomorHpController,
              label: 'Nomor HP',
              hintText: '0812 3456 7890',
            ),
            CustomTextField(
              controller: organisasiController,
              label: 'Organisasi',
              hintText: 'PT Maju Jaya, Universitas ABC...',
            ),
            const SpaceHeight(16),
            const Text(
              'Jenis Kelamin',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SpaceHeight(12),
            GenderToggleButton(
              selectedGender: selectedGender,
              onChanged: (gender) {
                setState(() {
                  selectedGender = gender;
                });
              },
            ),
            CustomTextField(
              controller: nikController,
              label: 'NIK KTP',
              hintText: '3201234567890001',
            ),

            const SpaceHeight(32),
            Button.filled(
              label: 'Simpan',
              onPressed: () {
                context.pop();
              },
            ),
            const SpaceHeight(20),
          ],
        ),
      ),
    );
  }
}
