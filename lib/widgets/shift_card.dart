import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShiftCard extends StatefulWidget {
  const ShiftCard({super.key, QueryDocumentSnapshot<Map<String, dynamic>>? shift});

  @override
  State<ShiftCard> createState() => _ShiftCardState();
}

class _ShiftCardState extends State<ShiftCard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('shift card'),
    );
  }
}
