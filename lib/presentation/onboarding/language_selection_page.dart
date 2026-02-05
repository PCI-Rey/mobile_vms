import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import '../../presentation/onboarding/onboarding_page.dart';
import '../../core/core.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? selectedLanguage;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                width: double.infinity,
                color: AppColors.primary500,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.images.iconApp.image(height: 122),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Pilih Bahasa Anda",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Agar pengalaman penggunaan lebih nyaman dan mudah dimengerti",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  _languageButton(
                    flag: CountryFlag.fromCountryCode(
                      'ID',
                      width: 32,
                      height: 24,
                      shape: const RoundedRectangle(8),
                    ),
                    label: 'Indonesia',
                    isSelected: selectedLanguage == 'Indonesia',
                    onTap: () {
                      setState(() {
                        selectedLanguage = 'Indonesia';
                      });

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _languageButton(
                    flag: CountryFlag.fromCountryCode(
                      'US',
                      width: 32,
                      height: 24,
                      shape: const RoundedRectangle(8),
                    ),
                    label: 'English',
                    isSelected: selectedLanguage == 'English',
                    onTap: () {
                      setState(() {
                        selectedLanguage = 'English';
                      });

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageButton({
    required Widget flag,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.1)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            flag,
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary500 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
