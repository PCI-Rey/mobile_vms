import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/models/user_model.dart';
import '../../presentation/auth/take_selfie_page.dart';
import '../../../core/core.dart';

class InformasiUmumPage extends StatefulWidget {
  const InformasiUmumPage({super.key});

  @override
  State<InformasiUmumPage> createState() => _InformasiUmumPageState();
}

class _InformasiUmumPageState extends State<InformasiUmumPage> {
  TextEditingController kodeUndanganController = TextEditingController();
  TextEditingController tipeKunjunganController = TextEditingController();
  TextEditingController selectedTipeKunjunganController =
      TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nomorHpController = TextEditingController();
  TextEditingController organisasiController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController nikController = TextEditingController();
  Gender selectedGender = Gender.male;

  final List<String> tipeKunjunganOptions = [
    'Rapat',
    'Kunjungan Bisnis',
    'Seminar',
    'Training',
    'Inspeksi',
    'Audit',
    'Maintenance',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Informasi Umum'),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: kodeUndanganController,
              label: 'Kode Undangan',
              hintText: 'Contoh: UND-2025-XYZ',
            ),
            const SpaceHeight(16),
            const Divider(color: AppColors.grey400, thickness: 1),
            const SpaceHeight(16),
            SearchableDropdownField(
              label: 'Tipe Undangan',
              hintText: 'Ketik untuk cari...',
              controller: tipeKunjunganController,
              items: ['Rapat', 'Seminar', 'Training', 'Audit', 'Maintenance'],
              onSelected: (selected) {
                selectedTipeKunjunganController.text = selected;
              },
            ),

            const SpaceHeight(16),
            CustomTextField(
              controller: nameController,
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
            const SpaceHeight(16),
            CustomTextField(
              controller: nikController,
              label: 'NIK KTP',
              hintText: '3201234567890001',
            ),

            const SpaceHeight(32),
            Button.filled(
              label: 'Selanjutnya',
              onPressed: () async {
                final email = emailController.text.trim();
                final phone = nomorHpController.text.trim();
                final user = UserModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text.trim(),
                  username: email.isNotEmpty ? email : 'guest',
                  email: email,
                  phone: phone,
                  role: 'guest',
                  password: '123456',
                );

                try {
                  await AuthDatasource().saveAuthData(user);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data tersimpan sebagai guest. Lanjut ke selfie',
                      ),
                    ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TakeSelfiePage()),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menyimpan data: $e')),
                  );
                }
              },
            ),
            const SpaceHeight(20),
          ],
        ),
      ),
    );
  }
}
