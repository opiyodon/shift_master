import 'package:flutter/material.dart';
import 'package:shift_master/widgets/shift_card.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/custom_sidebar.dart';
import 'package:shift_master/widgets/custom_app_bar.dart';
import 'package:shift_master/services/firestore_service.dart';
import 'package:shift_master/models/shift_model.dart';
import 'package:shift_master/models/employee_model.dart';
import 'dart:math';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Employee> _employees = [];
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String? _selectedEmployeeId;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      // Use the new method from FirestoreService
      final initialEmployees = await _firestoreService.fetchInitialEmployees();

      if (mounted) {
        setState(() {
          _employees = initialEmployees;
          _isInitialized = true;
        });
      }

      // Then set up stream for real-time updates
      _firestoreService.getEmployees().listen((employees) {
        if (mounted) {
          setState(() {
            _employees = employees;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching employees: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  Future<void> _createShift() async {
    if (_selectedEmployeeId == null ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      return;
    }

    try {
      String employeeId = _selectedEmployeeId!;
      DateTime startTime = DateTime.parse(_startTimeController.text);
      DateTime endTime = DateTime.parse(_endTimeController.text);

      await _firestoreService.createShift(ShiftData(
        employeeId: employeeId,
        startTime: startTime,
        endTime: endTime,
        status: 'Scheduled',
      ));

      _startTimeController.clear();
      _endTimeController.clear();
      setState(() {
        _selectedEmployeeId = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift created successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating shift: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  void _generateAutomaticShifts() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still loading employees, please wait...'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      return;
    }

    // Filter employees to only include those with role 'employee'
    final nonAdminEmployees =
        _employees.where((emp) => emp.role == 'employee').toList();

    if (nonAdminEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No non-admin employees available to create shifts'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (var employee in nonAdminEmployees) {
        DateTime now = DateTime.now();
        DateTime shiftStart = DateTime(
          now.year,
          now.month,
          now.day,
          Random().nextInt(10) + 8, // Start between 8 AM and 5 PM
          0,
        );
        DateTime shiftEnd = shiftStart.add(const Duration(hours: 8));

        await _firestoreService.createShift(ShiftData(
          employeeId: employee.id,
          startTime: shiftStart,
          endTime: shiftEnd,
          status: 'Automatically Generated',
        ));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Automatic shifts generated for ${nonAdminEmployees.length} employees',
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating automatic shifts: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteShift(String shiftId) async {
    try {
      await _firestoreService.deleteShift(shiftId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift deleted successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting shift: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "Shift Management"),
      drawer: const CustomSidebar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          children: [
            // Automatic Shift Generation Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateAutomaticShifts,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_fix_high, color: Colors.white),
                label: Text(
                  _isLoading
                      ? 'Generating Shifts...'
                      : 'Generate Automatic Shifts',
                  style: theme.textTheme.labelLarge,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Shifts List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor2,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: StreamBuilder<List<ShiftData>>(
                  stream: _firestoreService.getShifts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No shifts created yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      );
                    }

                    List<ShiftData> shifts = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: shifts.length,
                      itemBuilder: (context, index) {
                        ShiftData shift = shifts[index];
                        Employee employee = _employees.firstWhere(
                              (e) => e.id == shift.employeeId,
                          orElse: () => Employee(
                            id: '',
                            name: 'Unknown Employee',
                            email: 'unknown@example.com',
                            role: 'employee',
                            department: '',
                            position: '',
                          ),
                        );

                        return Dismissible(
                          key: Key(shift.id ?? index.toString()),
                          background: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteShift(shift.id!),
                          child: ShiftCard(
                            shift: shift,
                            employeeName: employee.name,
                            employee: employee, // Pass the full employee object
                            onDelete: () => _deleteShift(shift.id!),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Manual Shift Creation Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor2,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _showCreateShiftDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(
                      'Create Manual Shift',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateShiftDialog() {
    // Filter out admin employees
    final nonAdminEmployees =
        _employees.where((emp) => emp.role == 'employee').toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Create Shift',
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Employee',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
                value: _selectedEmployeeId,
                items: nonAdminEmployees.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.name),
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
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                  hintText: 'YYYY-MM-DD HH:MM',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _endTimeController,
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                  hintText: 'YYYY-MM-DD HH:MM',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _createShift();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}
