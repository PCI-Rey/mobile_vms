import 'package:flutter/material.dart';
import '../../../presentation/auth/forgot_password/otp_confirmation_page.dart';
import '../../../presentation/auth/login_page.dart';
import '../../../presentation/auth/verification_code_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/core.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Lupa Kata Sandi'),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceHeight(20),
            Text('Ubah Password', style: TextStyles.headline4),
            const Text(
              'Masukkan kata sandi baru dan konfirmasi kata sandi baru Anda.',
            ),
            const SpaceHeight(30),
            CustomTextField(
              controller: passwordController,
              label: 'Kata sandi baru',
              isObscure: _obscurePassword,
              suffixIconData: _obscurePassword
                  ? FontAwesomeIcons.eyeSlash
                  : FontAwesomeIcons.eye,
              onTapSuffixIcon: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              errorText: passwordError,
            ),

            CustomTextField(
              controller: passwordController,
              label: 'Konfirmasi kata sandi',
              isObscure: _obscurePassword,
              suffixIconData: _obscurePassword
                  ? FontAwesomeIcons.eyeSlash
                  : FontAwesomeIcons.eye,
              onTapSuffixIcon: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              errorText: passwordError,
            ),

            const SpaceHeight(30),
            Button.filled(
              onPressed: () {
                context.push(LoginPage());
              },
              label: 'Ganti Password',
            ),
          ],
        ),
      ),
    );
  }
}
