import 'package:flutter/material.dart';
import '../../../../presentation/auth/forgot_password/change_password_page.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/helper/responsive_helper.dart';
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
        padding: EdgeInsets.all(rw(context, 20.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vSpace(context, 20),
            Text('Konfirmasi Kode', style: TextStyles.headline4.copyWith(
              fontSize: rfs(context, 23),
            )),
            const Text(
              'Kami telah mengirimkan kode konfirmasi untuk mengatur ulang kata sandi ke user@email.com',
            ),
            vSpace(context, 30),
            Text(
              'Kode Verifikasi',
              style: TextStyle(fontSize: rfs(context, 14), fontWeight: FontWeight.w600),
            ),
            vSpace(context, 10),
            SizedBox(
              width: double.infinity,
              child: Pinput(
                length: 6,
                defaultPinTheme: PinTheme(
                  width: rw(context, 48),
                  height: rh(context, 56),
                  textStyle: TextStyle(
                    fontSize: rfs(context, 20),
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(rw(context, 8)),
                    border: Border.all(color: Colors.transparent),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: rw(context, 48),
                  height: rh(context, 56),
                  textStyle: TextStyle(
                    fontSize: rfs(context, 20),
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[200],
                    borderRadius: BorderRadius.circular(rw(context, 8)),
                    border: Border.all(color: Colors.blue),
                  ),
                ),
                separatorBuilder: (index) => hSpace(context, 10),
                onChanged: (value) {
                  otpCode = value;
                },
                onCompleted: (value) {
                  debugPrint('Kode OTP: $value');
                },
              ),
            ),

            vSpace(context, 30),
            Button.filled(
              onPressed: () {
                context.push(ChangePasswordPage());
              },
              label: 'Atur Password',
              borderColor: AppColors.grey900,
              textColor: AppColors.grey900,
            ),
            vSpace(context, 20),
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
