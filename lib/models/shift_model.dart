class ShiftModel {
  String id;
  String employeeId;
  String startTime;
  String endTime;

  ShiftModel({required this.id, required this.employeeId, required this.startTime, required this.endTime});

  factory ShiftModel.fromFirestore(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      employeeId: json['employeeId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'employeeId': employeeId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
