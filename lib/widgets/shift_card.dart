import 'package:flutter/material.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/models/shift_model.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/shift_details_modal.dart';

enum ShiftStatus {
  pending,
  active,
  completed;

  String get displayName => name.toUpperCase();

  static ShiftStatus fromDateTime(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    if (now.isBefore(startTime)) return ShiftStatus.pending;
    if (now.isAfter(endTime)) return ShiftStatus.completed;
    return ShiftStatus.active;
  }

  Color get color {
    switch (this) {
      case ShiftStatus.pending:
        return const Color(0xFFFF9800);
      case ShiftStatus.active:
        return const Color(0xFF4CAF50);
      case ShiftStatus.completed:
        return const Color(0xFF2196F3);
    }
  }
}

class ShiftCard extends StatelessWidget {
  final ShiftData shift;
  final String employeeName;
  final VoidCallback onDelete;
  final Employee employee;

  const ShiftCard({
    super.key,
    required this.shift,
    required this.employeeName,
    required this.onDelete,
    required this.employee,
  });

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  ShiftStatus get status =>
      ShiftStatus.fromDateTime(shift.startTime, shift.endTime);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ShiftDetailsModal(
                shift: shift,
                employee: employee,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: status.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    employeeName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusBadge(status: status),
                              ],
                            ),
                          ),
                          _DeleteButton(onDelete: onDelete),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDateTime(shift.startTime)} - ${_formatDateTime(shift.endTime)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          _GenerationBadge(isManual: shift.status == 'Manual'),
                        ],
                      ),
                    ],
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

class _StatusBadge extends StatelessWidget {
  final ShiftStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.delete_outline,
          size: 20,
          color: AppTheme.accentColor,
        ),
        onPressed: onDelete,
        padding: const EdgeInsets.all(4),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _GenerationBadge extends StatelessWidget {
  final bool isManual;

  const _GenerationBadge({required this.isManual});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isManual ? 'MANUAL' : 'AUTOMATICALLY GENERATED',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
