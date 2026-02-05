import 'package:flutter/material.dart';
import '../../presentation/auth/informasi_umum_page.dart';
import '../../core/core.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  TextEditingController invitationCode = TextEditingController();
  String? codeError;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
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
                              'Verifikasi Kode',
                              style: TextStyles.headline4,
                            ),
                            const Text('Masukkan kode undangan Anda.'),
                            const SpaceHeight(10),

                            CustomTextField(
                              controller: invitationCode,
                              label: 'Kode Undangan',
                              errorText: codeError,
                            ),

                            const SpaceHeight(20),
                            Spacer(),

                            Button.filled(
                              onPressed: () {
                                context.push(InformasiUmumPage());
                              },
                              label: 'Verifikasi',
                            ),

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
    );
  }
}
