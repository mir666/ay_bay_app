import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get uid => _auth.currentUser!.uid;

  static CollectionReference get transactionRef =>
      _db.collection('users').doc(uid).collection('transactions');

  /// ADD TRANSACTION
  static Future<void> addTransaction(Map<String, dynamic> data) async {
    await transactionRef.add(data);
  }

  /// STREAM TRANSACTIONS
  static Stream<QuerySnapshot> transactionStream() {
    return transactionRef.orderBy('date', descending: true).snapshots();
  }


}
