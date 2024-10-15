import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shift_master/widgets/shift_card.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Shifts")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('shifts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var shifts = snapshot.data?.docs;
          return ListView.builder(
            itemCount: shifts?.length,
            itemBuilder: (context, index) {
              var shift = shifts?[index];
              return ShiftCard(shift: shift);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add shift functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
