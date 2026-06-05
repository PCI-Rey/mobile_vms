import 'package:flutter/material.dart';
import '../../../../presentation/auth/forgot_password/otp_confirmation_page.dart';
// import '../../../../presentation/auth/verification_code_page.dart';
import '../../../../core/helper/responsive_helper.dart';
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
          padding: EdgeInsets.all(rw(context, 20.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSpace(context, 20),
              Text('Ubah Kata Sandi', style: TextStyles.headline4.copyWith(
                fontSize: rfs(context, 20), // default for headline4 or custom? Let's keep it responsive if we specify font size, but since headline4 has its own font size in TextStyles, wait: if we use TextStyles.headline4, we should check if its fontSize is hardcoded. Wait! If the user wants to scale ALL font sizes, we should check what TextStyles does or if we copyWith and scale. But wait, if text style is pre-defined in TextStyles, we can copyWith(fontSize: rfs(context, TextStyles.headline4.fontSize)). But does headline4 have a size? Let's check TextStyles definition.
              )),
              const Text(
                'Masukkan alamat email yang terdaftar dan kami akan mengirimkan tautan pemulihan.',
              ),
              vSpace(context, 30),
              CustomTextField(
                controller: emailController,
                label: 'Email',
                errorText: emailError,
              ),

              vSpace(context, 30),
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

