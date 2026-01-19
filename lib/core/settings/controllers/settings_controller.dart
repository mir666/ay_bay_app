import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  RxBool notificationsEnabled = true.obs;
  RxString defaultCurrency = '৳'.obs;
  RxBool isAppLockEnabled = false.obs;

  RxString fullName = ''.obs;
  RxString phoneNumber = ''.obs;
  RxString avatarUrl = ''.obs; // যদি অ্যাভাটার Firebase বা URL থাকে

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load local settings
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value = prefs.getBool('notificationsEnabled') ?? true;
    defaultCurrency.value = prefs.getString('defaultCurrency') ?? '৳';
    isAppLockEnabled.value = prefs.getBool('isAppLockEnabled') ?? false;

    fullName.value = prefs.getString('fullName') ?? '';
    phoneNumber.value = prefs.getString('phoneNumber') ?? '';
    avatarUrl.value = prefs.getString('avatarUrl') ?? '';
  }

  /// Save local settings
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', notificationsEnabled.value);
    await prefs.setString('defaultCurrency', defaultCurrency.value);
    await prefs.setBool('isAppLockEnabled', isAppLockEnabled.value);

    await prefs.setString('fullName', fullName.value);
    await prefs.setString('phoneNumber', phoneNumber.value);
    await prefs.setString('avatarUrl', avatarUrl.value);
  }

  /// Backup data to Firebase
  Future<void> backupData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> localData = {
        'notificationsEnabled': prefs.getBool('notificationsEnabled') ?? true,
        'defaultCurrency': prefs.getString('defaultCurrency') ?? '৳',
        'isAppLockEnabled': prefs.getBool('isAppLockEnabled') ?? false,
        'fullName': prefs.getString('fullName') ?? '',
        'phoneNumber': prefs.getString('phoneNumber') ?? '',
        'avatarUrl': prefs.getString('avatarUrl') ?? '',
      };

      await _firestore.collection('users').doc(userId).set({
        'backupData': localData,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Backup', 'Data backed up successfully!');
    } catch (e) {
      Get.snackbar('Backup Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Restore data from Firebase
  Future<void> restoreData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists &&
          doc.data() != null &&
          doc.data()!['backupData'] != null) {
        Map<String, dynamic> backup =
        Map<String, dynamic>.from(doc.data()!['backupData']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notificationsEnabled', backup['notificationsEnabled'] ?? true);
        await prefs.setString('defaultCurrency', backup['defaultCurrency'] ?? '৳');
        await prefs.setBool('isAppLockEnabled', backup['isAppLockEnabled'] ?? false);

        await prefs.setString('fullName', backup['fullName'] ?? '');
        await prefs.setString('phoneNumber', backup['phoneNumber'] ?? '');
        await prefs.setString('avatarUrl', backup['avatarUrl'] ?? '');

        // Update controllers
        notificationsEnabled.value = backup['notificationsEnabled'] ?? true;
        defaultCurrency.value = backup['defaultCurrency'] ?? '৳';
        isAppLockEnabled.value = backup['isAppLockEnabled'] ?? false;

        fullName.value = backup['fullName'] ?? '';
        phoneNumber.value = backup['phoneNumber'] ?? '';
        avatarUrl.value = backup['avatarUrl'] ?? '';

        Get.snackbar('Restore', 'Data restored successfully!');
      } else {
        Get.snackbar('Restore', 'No backup found.');
      }
    } catch (e) {
      Get.snackbar('Restore Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Clear all local data
  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notificationsEnabled.value = true;
    defaultCurrency.value = '৳';
    isAppLockEnabled.value = false;
    fullName.value = '';
    phoneNumber.value = '';
    avatarUrl.value = '';

    Get.snackbar('Data', 'All local data cleared!');
  }
}
