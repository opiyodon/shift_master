import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email, String firstName, String lastName) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> checkUserExists(String email) async {
    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final docSnapshot = await _db.collection('users').doc(uid).get();
    return docSnapshot.data();
  }
}
