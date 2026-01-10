import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString photoUrl = ''.obs;

  String? get uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    if (uid == null) return;

    _db.collection('users').doc(uid).snapshots().listen((doc) {
      name.value = doc['name'] ?? '';
      email.value = doc['email'] ?? '';
      photoUrl.value = doc['photoUrl'] ?? '';
    });
  }


  void updateName(String newName) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'name': newName});
    name.value = newName;
  }

  Future<void> changeProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final ref = _storage.ref().child('profile_photos/$uid.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await _db.collection('users').doc(uid).update({'photoUrl': url});
    photoUrl.value = url;
  }

  Future<void> changePassword(String newPassword) async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updatePassword(newPassword);
      Get.snackbar('Success', 'Password updated successfully');
    }
  }
}
