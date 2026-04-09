import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var fullName = ''.obs;
  var phoneNumber = ''.obs;
  var avatarUrl = ''.obs;
  var isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  RxString avatarBase64 = ''.obs;

  // নতুন ফিল্ড
  var createdAt = Rxn<DateTime>(); // Nullable DateTime
  var isPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
    loadProfileImage();
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

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImage = prefs.getString('profile_pic') ?? '';
    avatarBase64.value = savedImage;
  }

  Future<void> updateProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    final bytes = await imageFile.readAsBytes();
    final encoded = base64Encode(bytes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_pic', encoded);

    avatarBase64.value = encoded;
  }
}