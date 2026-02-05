import 'package:flutter/material.dart';
import '../../../../presentation/auth/forgot_password/change_password_page.dart';
import 'package:pinput/pinput.dart';
import '../../../core/core.dart';

class OtpConfirmationPage extends StatefulWidget {
  const OtpConfirmationPage({super.key});

  @override
  State<OtpConfirmationPage> createState() => _OtpConfirmationPageState();
}

class _OtpConfirmationPageState extends State<OtpConfirmationPage> {
  String otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Lupa Kata Sandi'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceHeight(20),
            Text('Konfirmasi Kode', style: TextStyles.headline4),
            const Text(
              'Kami telah mengirimkan kode konfirmasi untuk mengatur ulang kata sandi ke user@email.com',
            ),
            const SpaceHeight(30),
            Text(
              'Kode Verifikasi',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SpaceHeight(10),
            SizedBox(
              width: double.infinity,
              child: Pinput(
                length: 6,
                defaultPinTheme: PinTheme(
                  width: 48,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 48,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                ),
                separatorBuilder: (index) => const SizedBox(width: 10),
                onChanged: (value) {
                  otpCode = value;
                },
                onCompleted: (value) {
                  debugPrint('Kode OTP: $value');
                },
              ),
            ),

            const SpaceHeight(30),
            Button.filled(
              onPressed: () {
                context.push(ChangePasswordPage());
              },
              label: 'Atur Password',
              borderColor: AppColors.grey900,
              textColor: AppColors.grey900,
            ),
            SpaceHeight(20),
            Button.outlined(
              onPressed: () {
                context.push(ChangePasswordPage());
              },
              label: 'Kirim ulang email',
            ),
          ],
        ),
      ),
    );
  }
}
