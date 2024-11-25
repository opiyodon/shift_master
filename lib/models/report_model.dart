import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;
  final bool fileUrl; // Using bool instead of String
  final int totalRecords;

  Report({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.fileUrl, // Accepting a bool value
    required this.totalRecords,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'generatedAt': generatedAt,
      'fileUrl': fileUrl, // Storing a bool value
      'totalRecords': totalRecords,
    };
  }

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    return Report(
      id: id,
      type: map['type'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      generatedAt: (map['generatedAt'] as Timestamp).toDate(),
      fileUrl: map['fileUrl'] ?? false, // Handle missing or incorrect values
      totalRecords: map['totalRecords'],
    );
  }
}
