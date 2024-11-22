import 'package:flutter/material.dart';
import 'package:shift_master/widgets/shift_card.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/custom_sidebar.dart';
import 'package:shift_master/widgets/custom_app_bar.dart';
import 'package:shift_master/services/firestore_service.dart';
import 'package:shift_master/models/shift_model.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _employees = [];
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    _employees = (_firestoreService.getEmployees()) as List<Map<String, dynamic>>;
    setState(() {});
  }

  Future<void> _createShift() async {
    String employeeId = _selectedEmployeeId ?? '';
    DateTime startTime = DateTime.parse(_startTimeController.text);
    DateTime endTime = DateTime.parse(_endTimeController.text);
    await _firestoreService.createShift(ShiftData(
      employeeId: employeeId,
      startTime: startTime,
      endTime: endTime,
      status: '',
    ));
    _startTimeController.clear();
    _endTimeController.clear();
    _selectedEmployeeId = null;
  }

  Future<void> _deleteShift(String id) async {
    await _firestoreService.deleteShift(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Manage Shifts"),
      drawer: const CustomSidebar(),
      body: StreamBuilder<List<ShiftData>>(
        stream: _firestoreService.getShifts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ShiftData> shifts = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: shifts.length,
                  itemBuilder: (context, index) {
                    ShiftData shift = shifts[index];
                    String employeeName = _getEmployeeName(shift.employeeId);
                    return ShiftCard(
                      shift: shift,
                      employeeName: employeeName,
                      onDelete: () => _deleteShift(shift.id!),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showCreateShiftDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: const Text(
                    'Create Shift',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getEmployeeName(String employeeId) {
    Map<String, dynamic>? employee = _employees.firstWhere(
          (e) => e['id'] == employeeId,
      orElse: () => {},
    );
    return '${employee['firstName']} ${employee['lastName']}';
  }

  void _showCreateShiftDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              hint: const Text('Select Employee'),
              value: _selectedEmployeeId,
              items: _employees.map((e) {
                return DropdownMenuItem<String>(
                  value: e['id'],
                  child: Text('${e['firstName']} ${e['lastName']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start Time',
                border: OutlineInputBorder(),
                hintText: 'YYYY-MM-DD HH:MM',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endTimeController,
              decoration: const InputDecoration(
                labelText: 'End Time',
                border: OutlineInputBorder(),
                hintText: 'YYYY-MM-DD HH:MM',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _createShift();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}