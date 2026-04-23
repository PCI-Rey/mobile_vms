import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final selectedLang = 'id'.obs;
  late Box _box;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box('authBox');
    final savedLang = _box.get('language', defaultValue: 'id');
    selectedLang.value = savedLang;
    
    // Set initial locale
    _updateLocale(savedLang);
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
