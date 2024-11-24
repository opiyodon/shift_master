import 'package:flutter/material.dart';
import 'package:shift_master/screens/loading_screen_dart.dart';
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
  State<ShiftManagementScreen> createState() => ShiftManagementScreenState();
}

class ShiftManagementScreenState extends State<ShiftManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Employee> _employees = [];
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String? _selectedEmployeeId;
  bool isLoading = false;
  String loadingMessage = '';
  bool _isInitialized = false;
  DateTime _currentWeekStart = DateTime.now();

  // Define shift times
  final Map<String, Map<String, int>> shiftTimes = {
    'morning': {'start': 6, 'end': 14},
    'afternoon': {'start': 14, 'end': 22},
    'evening': {'start': 22, 'end': 6},
    'night': {'start': 18, 'end': 2},
    'midnight': {'start': 0, 'end': 8},
  };

  void _showLoading(String message) {
    setState(() {
      isLoading = true;
      loadingMessage = message;
    });
  }

  void _hideLoading() {
    setState(() {
      isLoading = false;
      loadingMessage = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _currentWeekStart = _getWeekStart(DateTime.now());
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _fetchEmployees() async {
    try {
      final initialEmployees = await _firestoreService.fetchInitialEmployees();

      if (mounted) {
        setState(() {
          _employees = initialEmployees;
          _isInitialized = true;
        });
      }

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

  Map<String, List<Employee>> _groupEmployeesByDepartment(
      List<Employee> employees) {
    Map<String, List<Employee>> grouped = {};
    for (var employee in employees) {
      if (employee.role == 'employee') {
        if (!grouped.containsKey(employee.department)) {
          grouped[employee.department] = [];
        }
        grouped[employee.department]!.add(employee);
      }
    }
    return grouped;
  }

  Map<String, List<Employee>> _groupEmployeesByPosition(
      List<Employee> employees) {
    Map<String, List<Employee>> grouped = {};
    for (var employee in employees) {
      if (!grouped.containsKey(employee.position)) {
        grouped[employee.position] = [];
      }
      grouped[employee.position]!.add(employee);
    }
    return grouped;
  }

  Future<void> _generateWeeklyShifts() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still loading employees, please wait...'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      return;
    }

    _showLoading('Generating weekly shifts...');

    try {
      // Group employees by department
      Map<String, List<Employee>> departmentGroups =
          _groupEmployeesByDepartment(_employees);

      // Generate shifts for each department
      for (var department in departmentGroups.keys) {
        // Further group by position within department
        Map<String, List<Employee>> positionGroups =
            _groupEmployeesByPosition(departmentGroups[department]!);

        // Generate shifts for each position group
        for (var position in positionGroups.keys) {
          List<Employee> employees = positionGroups[position]!;

          // Generate shifts for 7 days
          for (int day = 0; day < 7; day++) {
            DateTime currentDay = _currentWeekStart.add(Duration(days: day));

            // Distribute employees across shifts
            int employeesPerShift =
                (employees.length / shiftTimes.length).ceil();
            List<Employee> availableEmployees = List.from(employees);

            // Create shifts for each shift type
            for (var shiftType in shiftTimes.keys) {
              if (availableEmployees.isEmpty) {
                availableEmployees =
                    List.from(employees); // Reset if we need to reuse employees
              }

              // Select employees for this shift
              for (int i = 0;
                  i < employeesPerShift && availableEmployees.isNotEmpty;
                  i++) {
                int randomIndex = Random().nextInt(availableEmployees.length);
                Employee selectedEmployee = availableEmployees[randomIndex];
                availableEmployees.removeAt(randomIndex);

                // Create shift times
                DateTime shiftStart = DateTime(
                  currentDay.year,
                  currentDay.month,
                  currentDay.day,
                  shiftTimes[shiftType]!['start']!,
                );

                DateTime shiftEnd = DateTime(
                  currentDay.year,
                  currentDay.month,
                  currentDay.day,
                  shiftTimes[shiftType]!['end']!,
                );

                // Adjust end time if it's next day
                if (shiftTimes[shiftType]!['end']! <
                    shiftTimes[shiftType]!['start']!) {
                  shiftEnd = shiftEnd.add(const Duration(days: 1));
                }

                // Create the shift
                await _firestoreService.createShift(ShiftData(
                  employeeId: selectedEmployee.id,
                  startTime: shiftStart,
                  endTime: shiftEnd,
                  status: 'Scheduled',
                  department: department,
                  position: position,
                  shiftType: shiftType,
                  weekStart: _currentWeekStart,
                ));
              }
            }
          }
        }
      }

      // Move to next week for future generations
      setState(() {
        _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
      });

      _hideLoading();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weekly shifts generated successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      _hideLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating shifts: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  Future<void> _clearAllShifts() async {
    try {
      _showLoading('Clearing all shifts...');
      await _firestoreService.clearAllShifts();
      setState(() {
        _currentWeekStart = _getWeekStart(DateTime.now());
      });
      _hideLoading();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All shifts cleared successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      _hideLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing shifts: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  Widget _buildWeeklyShiftGroup(List<ShiftData> shifts, String weekLabel) {
    final theme = Theme.of(context);

    // Sort shifts by date within each week
    shifts.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Group shifts by department
    Map<String, List<ShiftData>> departmentShifts = {};
    for (var shift in shifts) {
      if (!departmentShifts.containsKey(shift.department)) {
        departmentShifts[shift.department] = [];
      }
      departmentShifts[shift.department]!.add(shift);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            weekLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...departmentShifts.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Department: ${entry.key}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...entry.value.map((shift) {
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
                  key: Key(shift.id ?? UniqueKey().toString()),
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
                    employee: employee,
                    onDelete: () => _deleteShift(shift.id!),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: const CustomAppBar(title: "Shift Management"),
          drawer: const CustomSidebar(),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              children: [
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _generateWeeklyShifts,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_fix_high,
                                  color: Colors.white),
                          label: Text(
                            isLoading
                                ? 'Generating...'
                                : 'Generate Weekly Shifts',
                            style: theme.textTheme.labelLarge,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _clearAllShifts,
                        icon: const Icon(Icons.clear_all, color: Colors.white),
                        label: Text(
                          'Clear All',
                          style: theme.textTheme.labelLarge,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
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

                        List<ShiftData> allShifts = snapshot.data!;

                        // Group shifts by week
                        Map<DateTime, List<ShiftData>> weeklyShifts = {};
                        for (var shift in allShifts) {
                          DateTime weekStart = shift.weekStart ?? _getWeekStart(shift.startTime);
                          if (!weeklyShifts.containsKey(weekStart)) {
                            weeklyShifts[weekStart] = [];
                          }
                          weeklyShifts[weekStart]!.add(shift);
                        }

                        // Sort weeks in descending order (latest week first)
                        List<DateTime> sortedWeeks = weeklyShifts.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: sortedWeeks.length,
                          itemBuilder: (context, index) {
                            DateTime weekStart = sortedWeeks[index];
                            String weekLabel = 'Week of ${weekStart.month}/${weekStart.day}/${weekStart.year}';
                            return _buildWeeklyShiftGroup(
                              weeklyShifts[weekStart]!,
                              weekLabel,
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
        ),
        if (isLoading)
          LoadingScreen(
            message: loadingMessage,
          ),
      ],
    );
  }

  Future<void> _deleteShift(String shiftId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this shift? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        _showLoading('Deleting shift...');
        await _firestoreService.deleteShift(shiftId);
        _hideLoading();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift deleted successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      } catch (e) {
        _hideLoading();
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
  }

  void _showCreateShiftDialog() {
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
      _showLoading('Creating new shift...');

      String employeeId = _selectedEmployeeId!;
      DateTime startTime = DateTime.parse(_startTimeController.text);
      DateTime endTime = DateTime.parse(_endTimeController.text);

      // Find employee details
      Employee employee = _employees.firstWhere((e) => e.id == employeeId);

      await _firestoreService.createShift(ShiftData(
        employeeId: employeeId,
        startTime: startTime,
        endTime: endTime,
        status: 'Manual',
        department: employee.department,
        position: employee.position,
        weekStart: _getWeekStart(startTime),
      ));

      _hideLoading();

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
      _hideLoading();
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

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}
