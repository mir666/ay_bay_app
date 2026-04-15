
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ay_bay_app/app/app_routes.dart';

class ChangePasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var currentPassword = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;
  var isLoading = false.obs;

  var showCurrent = true.obs;
  var showNew = true.obs;
  var showConfirm = true.obs;

  Future<void> changePassword() async {
    if (newPassword.value != confirmPassword.value) {
      Get.snackbar('Error', 'New passwords do not match');
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // ✅ correct email from Firebase user
      final email = user.email;

      // 🔐 Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: email!,
        password: currentPassword.value,
      );

      await user.reauthenticateWithCredential(cred);

      // 🔑 Update password
      await user.updatePassword(newPassword.value);

      Get.snackbar('Success', 'Password updated successfully');

      await _auth.signOut();
      Get.offAllNamed(AppRoutes.login);

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Auth error');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}