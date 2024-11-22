class ShiftData {
  String? id; // Optional ID field
  String employeeId;
  DateTime startTime;
  DateTime endTime;
  String status;
  // Add other relevant fields

  ShiftData({
    this.id,
    required this.employeeId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  // Convert ShiftData to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
    };
  }

  // Create ShiftData from a Map
  factory ShiftData.fromMap(Map<String, dynamic> map) {
    return ShiftData(
      id: map['id'],
      employeeId: map['employeeId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      status: map['status'],
    );
  }
}