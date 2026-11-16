import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final selectedLang = 'en'.obs;
  late Box _box;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box('authBox');
    
    // Prioritize English as the default language every time entering the app
    selectedLang.value = 'en';
    _box.put('language', 'en');
    _updateLocale('en');
  }

  void changeLanguage(String langCode) {
    selectedLang.value = langCode;
    _box.put('language', langCode);
    _updateLocale(langCode);
  }

  void _updateLocale(String langCode) {
    if (langCode == 'id') {
      Get.updateLocale(const Locale('id', 'ID'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}
