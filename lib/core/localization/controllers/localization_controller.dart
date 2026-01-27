import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class LocaleController extends GetxController {
  final _box = GetStorage();
  final _key = 'languageCode';

  Locale get initialLocale {
    final code = _box.read(_key) ?? 'en';
    return Locale(code);
  }

  void toggleLanguage() {
    final current = Get.locale?.languageCode ?? 'en';
    final newLocale = current == 'bn'
        ? const Locale('en')
        : const Locale('bn');

    Get.updateLocale(newLocale);
    _box.write(_key, newLocale.languageCode);
  }
}
