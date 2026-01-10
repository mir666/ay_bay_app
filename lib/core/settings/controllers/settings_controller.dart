import 'package:ay_bay_app/app/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxString name = ''.obs;
  RxString email = ''.obs;
  RxBool darkMode = false.obs;
  RxBool notifications = true.obs;

  String? get uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    if (uid == null) return;

    // 🔹 Listen for live updates
    _db.collection('users').doc(uid).snapshots().listen((doc) {
      if (!doc.exists) return;
      name.value = doc['name'] ?? '';
      email.value = doc['email'] ?? '';
      darkMode.value = doc['darkMode'] ?? false;
      notifications.value = doc['notifications'] ?? true;
    });
  }

  void toggleDarkMode(bool val) {
    darkMode.value = val;
    if (uid != null) {
      _db.collection('users').doc(uid).update({'darkMode': val});
    }
  }

  void toggleNotifications(bool val) {
    notifications.value = val;
    if (uid != null) {
      _db.collection('users').doc(uid).update({'notifications': val});
    }
  }

  void signOut() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login); // Login route
  }
}
