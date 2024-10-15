import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  final CollectionReference _shifts =
  FirebaseFirestore.instance.collection('shifts');

  Widget _buildReportItem(DocumentSnapshot doc) {
    final startTime = DateTime.parse(doc['startTime']);
    final endTime = DateTime.parse(doc['endTime']);
    final duration = endTime.difference(startTime).inHours;

    return ListTile(
      title: Text('Employee ID: ${doc['employeeId']}'),
      subtitle: Text('Hours Worked: $duration'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Reports'),
      ),
      body: StreamBuilder(
        stream: _shifts.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return _buildReportItem(doc);
            }).toList(),
          );
        },
      ),
    );
  }
}
