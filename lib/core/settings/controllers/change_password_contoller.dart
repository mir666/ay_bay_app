import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChangePasswordController extends GetxController {
  final currentPassword = ''.obs;
  final newPassword = ''.obs;
  final confirmPassword = ''.obs;

  /// 👁 Password visibility
  final showCurrent = true.obs;
  final showNew = true.obs;
  final showConfirm = true.obs;

  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword() async {
    if (isLoading.value) return;

    /// 🧪 Validation
    if (currentPassword.value.isEmpty ||
        newPassword.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (newPassword.value.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (newPassword.value != confirmPassword.value) {
      _showError('Passwords do not match');
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        _showError('User not logged in');
        return;
      }

      /// 🔐 Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.value,
      );

      await user.reauthenticateWithCredential(credential);

      /// 🔄 Update password
      await user.updatePassword(newPassword.value);

      Get.back();

      Get.snackbar(
        'Success',
        'Password updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🎯 Firebase error mapping
  void _handleFirebaseError(FirebaseAuthException e) {
    String message = 'Authentication failed';

    switch (e.code) {
      case 'wrong-password':
        message = 'Current password is incorrect';
        break;
      case 'weak-password':
        message = 'New password is too weak';
        break;
      case 'requires-recent-login':
        message = 'Please login again and retry';
        break;
    }

    _showError(message);
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
