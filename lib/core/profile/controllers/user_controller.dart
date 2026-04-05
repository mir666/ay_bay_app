import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var fullName = ''.obs;
  var phoneNumber = ''.obs;
  var avatarUrl = ''.obs;

  // নতুন ফিল্ড
  var createdAt = Rxn<DateTime>(); // Nullable DateTime
  var isPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  /// Firebase থেকে ইউজারের তথ্য নাও
  Future<void> loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data();

      fullName.value = data?['name'] ?? '';
      phoneNumber.value = data?['phone'] ?? '';
      avatarUrl.value = data?['avatarUrl'] ?? '';

      // Account creation date
      if (data?['createdAt'] != null) {
        createdAt.value = (data?['createdAt'] as Timestamp).toDate();
      }

      // Premium status
      isPremium.value = data?['isPremium'] ?? false;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    }
  }

  /// Local state update
  void setUser({
    required String name,
    required String phone,
    String? avatar,
    DateTime? created,
    bool? premium,
  }) {
    fullName.value = name;
    phoneNumber.value = phone;
    if (avatar != null) avatarUrl.value = avatar;
    if (created != null) createdAt.value = created;
    if (premium != null) isPremium.value = premium;
  }

  /// Update profile in Firebase + local state
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? avatar,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      await _db.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        if (avatar != null) 'avatarUrl': avatar,
      });

      // Update local state
      setUser(name: name, phone: phone, avatar: avatar);

      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }
}