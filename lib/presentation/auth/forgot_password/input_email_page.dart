import 'package:flutter/material.dart';
import '../../../../presentation/auth/forgot_password/otp_confirmation_page.dart';
// import '../../../../presentation/auth/verification_code_page.dart';
import '../../../core/core.dart';

class InputEmailPage extends StatefulWidget {
  const InputEmailPage({super.key});

  @override
  State<InputEmailPage> createState() => _InputEmailPageState();
}

class _InputEmailPageState extends State<InputEmailPage> {
  TextEditingController emailController = TextEditingController();
  String? emailError;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      if (emailError != null) {
        setState(() => emailError = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Lupa Kata Sandi'),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceHeight(20),
              Text('Ubah Kata Sandi', style: TextStyles.headline4),
              const Text(
                'Masukkan alamat email yang terdaftar dan kami akan mengirimkan tautan pemulihan.',
              ),
              const SpaceHeight(30),
              CustomTextField(
                controller: emailController,
                label: 'Email',
                errorText: emailError,
              ),

              const SpaceHeight(30),
              Button.filled(
                onPressed: () {
                  context.push(OtpConfirmationPage());
                },
                label: 'Kirim',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
