import 'package:flutter/material.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/models/shift_model.dart';

class ShiftDetailsModal extends StatelessWidget {
  final ShiftData shift;
  final Employee employee;

  const ShiftDetailsModal({
    super.key,
    required this.shift,
    required this.employee,
  });

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shift Details',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Employee Details Section
            _DetailItem(
              icon: Icons.person,
              label: 'Name',
              value: employee.name,
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.email,
              label: 'Email',
              value: employee.email,
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.business,
              label: 'Department',
              value: employee.department,
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.work,
              label: 'Position',
              value: employee.position,
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.badge,
              label: 'Role',
              value: employee.role,
            ),
            const SizedBox(height: 24),
            
            // Shift Time Details
            Text(
              'Shift Time',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.access_time,
              label: 'Start Time',
              value: _formatDateTime(shift.startTime),
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.access_time_filled,
              label: 'End Time',
              value: _formatDateTime(shift.endTime),
            ),
            const SizedBox(height: 16),
            
            _DetailItem(
              icon: Icons.info,
              label: 'Status',
              value: shift.status,
            ),
            const SizedBox(height: 24),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}