import 'package:ay_bay_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;
  Rx<Color> primaryColor = AppColors.loginTextButtonColor.obs;

  final Color defaultColor = Colors.teal;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  /// Load saved theme from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    int colorValue = prefs.getInt('primaryColor') ?? AppColors.loginTextButtonColor.value;
    primaryColor.value = Color(colorValue);
  }

  /// Toggle Dark/Light mode
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _savePrefs();
  }

  /// Change primary color
  Future<void> changePrimaryColor(Color color) async {
    primaryColor.value = color;
    await _savePrefs();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
    await prefs.setInt('primaryColor', primaryColor.value.value);
  }

  /// Build ThemeData based on current settings
  ThemeData get themeData {
    return ThemeData(
      brightness: isDarkMode.value ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor.value,
      scaffoldBackgroundColor:
      isDarkMode.value ? Colors.grey[900] : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor:
        isDarkMode.value ? Colors.grey[900] : primaryColor.value,
        foregroundColor:
        ThemeData.estimateBrightnessForColor(primaryColor.value) ==
            Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor.value),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle:
        TextStyle(color: isDarkMode.value ? Colors.grey[300] : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.value),
        ),
      ),
    );
  }
}
