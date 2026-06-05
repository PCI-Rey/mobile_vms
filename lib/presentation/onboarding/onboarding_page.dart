import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import '../../core/constants/colors.dart';
import '../../core/extensions/extensions.dart';
import '../../core/gen/assets.gen.dart';
import '../../core/helper/responsive_helper.dart';
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
          borderRadius: BorderRadius.circular(rw(context, 16)), // buat rounded
        ),
        foregroundColor: Colors.white,
      ),
      skipTextButton: Text(
        'Lewati',
        style: TextStyle(
          fontSize: rfs(context, 16),
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),

      trailing: Text(
        'Login',
        style: TextStyle(
          fontSize: rfs(context, 16),
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
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 40),
              vertical: rh(context, 40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Assets.images.onboarding1.image(height: rh(context, 300)),
                vSpace(context, 40),
                Text(
                  'Registrasi Sekali,\nKunjungan Mudah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontSize: rfs(context, 22),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.15,
                  ),
                ),
                vSpace(context, 16),
                Text(
                  "Isi data diri dan unggah dokumen,\nsistem akan mengatur sisanya",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: rfs(context, 16),
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
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 40),
              vertical: rh(context, 40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Assets.images.onboarding2.image(height: rh(context, 300)),
                vSpace(context, 40),
                Text(
                  'Undangan Digital \n& QR Pass',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontSize: rfs(context, 22),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                vSpace(context, 16),
                Text(
                  'Dapatkan undangan kunjungan dan akses masuk hanya dengan kode QR.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: rfs(context, 16),
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
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 40),
              vertical: rh(context, 40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Assets.images.onboarding3.image(height: rh(context, 300)),
                vSpace(context, 40),
                Text(
                  'Pantau \nKunjungan Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontSize: rfs(context, 22),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                vSpace(context, 16),
                Text(
                  'Lihat jadwal, status check-in/out, dan riwayat kunjungan Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: rfs(context, 16),
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

