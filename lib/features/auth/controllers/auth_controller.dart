import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
import 'package:ay_bay_app/core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;


  /// 🔹 Save FCM token (fire-and-forget)
  Future<void> saveFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final uid = _auth.currentUser?.uid;
      if (uid != null && token != null) {
        await _db.collection('users').doc(uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) print("FCM token error: $e");
    }
  }


  // SIGN UP
  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$phone@app.com',
        password: password,
      );

      final _ = userCredential.user!.uid;

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'phone': phone,
        'createdAt': Timestamp.now(),
      });

      final userController = Get.find<UserController>();
      userController.setUser(name: name, phone: phone);

      saveFcmToken(); // fire-and-forget

      Get.snackbar('Success', 'Account created successfully');
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAllNamed(AppRoutes.home);
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // LOGIN
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: '$phone@app.com',
        password: password,
      );

      final box = GetStorage();

      try {
        if (box.read('daily_9pm_set') != true) {
          await NotificationService.scheduleDaily9PMNotification(
            title: "dailyReminder".tr,
            body: "dailyReminderBody".tr,);
          box.write('daily_9pm_set', true);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Notification scheduling failed: $e");
        }
      }


      saveFcmToken(); // fire-and-forget
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Login Failed', 'Invalid credentials');
    } finally {
      isLoading.value = false;
    }
  }

  // FORGET PASSWORD
  Future<void> resetPassword(String phone) async {
    try {
      await _auth.sendPasswordResetEmail(email: '$phone@app.com');
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('Success', 'Reset email sent');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
    final box = GetStorage();
    box.remove('daily_9pm_set');
  }
}
