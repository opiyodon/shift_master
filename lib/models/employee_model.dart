import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String role;
  final Timestamp? createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.role,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'position': position,
      'role': role,
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      department: map['department'],
      position: map['position'],
      role: map['role'] ?? 'employee',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
