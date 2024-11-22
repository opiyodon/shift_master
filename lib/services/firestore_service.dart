import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/models/shift_model.dart'; // Added import for ShiftData

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Changed * to _

  Future<void> createUser(
      String uid, String email, String firstName, String lastName) async {
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

  Future<void> addEmployee(Employee employee) async {
    try {
      await _db.collection('employees').doc(employee.id).set(employee.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await _db.collection('employees').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Employee>> getEmployees() {
    return _db.collection('employees').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Employee.fromMap(doc.data())).toList());
  }

  Future<List<Map<String, dynamic>>> fetchEmployeesList() async {
    QuerySnapshot snapshot = await _db.collection('employees').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> createShift(ShiftData shift) async {
    try {
      await _db.collection('shifts').add(shift.toMap());
    } catch (e) {
      // Optionally log the error
      print('Error creating shift: $e');
    }
  }

  Future<void> deleteShift(String id) async {
    try {
      await _db.collection('shifts').doc(id).delete();
    } catch (e) {
      // Optionally log the error
      print('Error deleting shift: $e');
    }
  }

  Stream<List<ShiftData>> getShifts() {
    return _db.collection('shifts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ShiftData.fromMap(doc.data())).toList());
  }
}