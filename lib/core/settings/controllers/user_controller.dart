import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var fullName = ''.obs;
  var phoneNumber = ''.obs;
  var avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  /// Firebase থেকে ইউজারের তথ্য নাও
  Future<void> loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        fullName.value = doc['name'] ?? '';
        phoneNumber.value = doc['phone'] ?? '';
        avatarUrl.value = doc['avatarUrl'] ?? '';
      }
    }
  }

  /// নতুন ইউজার সাইন আপ হলে ডেটা আপডেট
  void setUser({required String name, required String phone, String? avatar}) {
    fullName.value = name;
    phoneNumber.value = phone;
    if (avatar != null) avatarUrl.value = avatar;
  }
}
