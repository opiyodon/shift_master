import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftData {
  final String? id;
  final String employeeId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String department;
  final String position;
  final String? shiftType;
  final DateTime? weekStart;

  // Add computed property for shift status
  String get shiftStatus {
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      return 'Pending';
    } else if (now.isAfter(endTime)) {
      return 'Completed';
    } else {
      return 'Active';
    }
  }

  ShiftData({
    this.id,
    required this.employeeId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.department = '',
    this.position = '',
    this.shiftType,
    this.weekStart,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'department': department,
      'position': position,
      'shiftType': shiftType,
      'weekStart': weekStart,
    };
  }

  static ShiftData fromMap(String id, Map<String, dynamic> map) {
    return ShiftData(
      id: id,
      employeeId: map['employeeId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      status: map['status'] ?? '',
      department: map['department'] ?? '',
      position: map['position'] ?? '',
      shiftType: map['shiftType'],
      weekStart: map['weekStart'] != null
          ? (map['weekStart'] as Timestamp).toDate()
          : null,
    );
  }
}
