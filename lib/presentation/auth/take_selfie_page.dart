import 'dart:io';
import 'package:flutter/material.dart';
import '../../presentation/auth/take_ktp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/core.dart';

class TakeSelfiePage extends StatefulWidget {
  const TakeSelfiePage({super.key});

  @override
  State<TakeSelfiePage> createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends State<TakeSelfiePage> {
  File? selfieImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> takeSelfie() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        selfieImage = File(photo.path);
      });
    }
  }

  void goToNextStep() {
    if (selfieImage != null) {
      context.push(TakeKtpPage());
    } else {
      context.push(TakeKtpPage());

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Silakan ambil selfie terlebih dahulu')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto Selfie'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  selfieImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selfieImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                          ),
                          child: Assets.images.person.image(height: 142),
                        ),
                  const SizedBox(height: 16),
                  const Text(
                    'Foto Selfie',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Diwajibkan oleh hukum untuk memverifikasi identitas Anda sebagai pengguna baru.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: takeSelfie,
                    icon: const FaIcon(
                      FontAwesomeIcons.cameraRetro,
                      color: Colors.blue,
                    ),
                    label: const Text(
                      'Take a selfie',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sebelumnya',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Selanjutnya',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
