import 'package:flutter/material.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/models/shift_model.dart';
import 'package:shift_master/utils/theme.dart';

class ShiftDetailsModal extends StatelessWidget {
  final ShiftData shift;
  final Employee employee;

  const ShiftDetailsModal({
    super.key,
    required this.shift,
    required this.employee,
  });

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Format time
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final formattedTime =
        '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';

    // Format date based on conditions
    String formattedDate;
    if (dateToCheck == today) {
      formattedDate = 'Today';
    } else if (dateToCheck == yesterday) {
      formattedDate = 'Yesterday';
    } else {
      // Format date for dates beyond yesterday
      final List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      formattedDate =
          '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    }

    return '$formattedDate at $formattedTime';
  }

  Widget _buildDetailField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shift Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Employee Details
                _buildDetailField(
                  label: 'Name',
                  value: employee.name,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  label: 'Email',
                  value: employee.email,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  label: 'Department',
                  value: employee.department,
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  label: 'Position',
                  value: employee.position,
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  label: 'Role',
                  value: employee.role,
                  icon: Icons.admin_panel_settings_outlined,
                ),
                const SizedBox(height: 32),

                // Shift Time Details
                const Text(
                  'Shift Time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  label: 'Start Time',
                  value: _formatDateTime(shift.startTime),
                  icon: Icons.access_time_outlined,
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  label: 'End Time',
                  value: _formatDateTime(shift.endTime),
                  icon: Icons.access_time_filled,
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  label: 'Status',
                  value: shift.status,
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 32),

                // Close Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
