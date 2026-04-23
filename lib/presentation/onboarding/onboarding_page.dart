import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import '../../core/constants/colors.dart';
import '../../core/extensions/extensions.dart';
import '../../core/gen/assets.gen.dart';
import '../../presentation/auth/login_page.dart';

class OnboardingPage extends StatelessWidget {
  final Color kDarkBlueColor = const Color(0xFF053149);

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      finishButtonText: 'Masuk',
      onFinish: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const LoginPage()),
        );
      },
      finishButtonStyle: FinishButtonStyle(
        backgroundColor: AppColors.primary500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // buat rounded
        ),
        foregroundColor: Colors.white,
      ),
      skipTextButton: Text(
        'Lewati',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),

      trailing: Text(
        'Login',
        style: TextStyle(
          fontSize: 16,
          color: kDarkBlueColor,
          fontWeight: FontWeight.w600,
        ),
      ),

      trailingFunction: () {
        context.push(LoginPage());
      },
      controllerColor: kDarkBlueColor,
      totalPage: 3,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      background: [Container(), Container(), Container()],

      speed: 1.8,
      pageBodies: [
        SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Assets.images.onboarding1.image(height: 300),
                const SizedBox(height: 40),
                Text(
                  'Registrasi Sekali,\nKunjungan Mudah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Isi data diri dan unggah dokumen,\nsistem akan mengatur sisanya",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),

        SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Assets.images.onboarding2.image(height: 300),
                const SizedBox(height: 40),
                Text(
                  'Undangan Digital \n& QR Pass',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dapatkan undangan kunjungan dan akses masuk hanya dengan kode QR.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Assets.images.onboarding3.image(height: 300),
                const SizedBox(height: 40),
                Text(
                  'Pantau \nKunjungan Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lihat jadwal, status check-in/out, dan riwayat kunjungan Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
