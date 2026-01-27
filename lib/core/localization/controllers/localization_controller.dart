import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class LocaleController extends GetxController {
  static LocaleController get to => Get.find(); // Easy access

  final _box = GetStorage();
  final _key = 'languageCode';

  /// Get initial locale from storage or default to English
  Locale get initialLocale {
    final code = _box.read(_key) ?? 'en';
    return Locale(code);
  }

  /// Toggle between English and Bangla
  void toggleLanguage() {
    final current = Get.locale?.languageCode ?? 'en';
    final newLocale = current == 'bn' ? const Locale('en') : const Locale('bn');

    Get.updateLocale(newLocale);
    _box.write(_key, newLocale.languageCode);
  }

  /// Check if current language is Bangla
  bool get isBangla => Get.locale?.languageCode == 'bn';
}
