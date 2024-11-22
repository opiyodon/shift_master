import 'package:flutter/material.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/models/shift_model.dart';

class ShiftCard extends StatefulWidget {
  final ShiftData shift;
  final String employeeName;
  final VoidCallback onDelete;

  const ShiftCard({
    super.key,
    required this.shift,
    required this.employeeName,
    required this.onDelete,
  });

  @override
  State<ShiftCard> createState() => _ShiftCardState();
}

class _ShiftCardState extends State<ShiftCard> {
  @override
  Widget build(BuildContext context) {
    // Format the date and time for display
    String formattedStartTime =
        "${widget.shift.startTime.hour}:${widget.shift.startTime.minute.toString().padLeft(2, '0')}";
    String formattedEndTime =
        "${widget.shift.endTime.hour}:${widget.shift.endTime.minute.toString().padLeft(2, '0')}";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.employeeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$formattedStartTime - $formattedEndTime',
                    style: const TextStyle(color: AppTheme.textColor),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete, color: AppTheme.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
