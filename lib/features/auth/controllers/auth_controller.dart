
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/home/ui/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;

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

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'phone': phone,
        'createdAt': Timestamp.now(),
      });
      Get.snackbar('Success', 'Account created successfully',);
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offAll(() => const HomeScreen());
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
      await _auth.sendPasswordResetEmail(
        email: '$phone@app.com',
      );
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('Success', 'Reset email sent');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

