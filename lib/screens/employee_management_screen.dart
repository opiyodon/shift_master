import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shift_master/screens/loading_screen_dart.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/custom_app_bar.dart';
import 'package:shift_master/widgets/custom_sidebar.dart';
import 'package:shift_master/widgets/employee_list_item.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/services/firestore_service.dart';

// Utility function to convert string to sentence case
String toSentenceCase(String text) {
  if (text.isEmpty) return text;
  return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
}

// Add enums for departments and positions
enum Department {
  management,
  supportTeam,
  grocery,
  produce,
  delivery,
  bakery,
  meat,
  seafood,
  dairy,
  frozenFoods,
  cashier,
  customerService,
  inventory,
  maintenance,
  receiving,
  wineSpirits,
  preparedFoods,
  floral
}

enum Position {
  admin,
  developer,
  storeManager,
  departmentManager,
  assistantManager,
  supervisor,
  teamLead,
  associate,
  cashier,
  customerServiceRep,
  stoker,
  inventorySpecialist,
  preparedFoodSpecialist,
  butcher,
  baker,
  pastryChef,
  deliverySpecialist,
  produceSpecialist,
  wineSpecialist,
  floralDesigner,
  maintenanceTechnician
}

enum Role {
  employee,
  admin;

  String get value {
    return name
        .toString(); // This will return 'employee' or 'admin' as a string
  }
}

// Extension methods to get display names
extension DepartmentExtension on Department {
  String get displayName {
    return name.split('_').map((word) => toSentenceCase(word)).join(' ');
  }
}

extension PositionExtension on Position {
  String get displayName {
    return name.split('_').map((word) => toSentenceCase(word)).join(' ');
  }
}

class EmployeeDetailsDialog extends StatelessWidget {
  final DocumentSnapshot employee;

  const EmployeeDetailsDialog({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Setting a constrained width that's wider than default AlertDialog
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
        constraints: const BoxConstraints(maxWidth: 450), // Maximum width
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Employee Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailField(
                label: 'Name',
                value: employee['name'],
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: 'Email',
                value: employee['email'],
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: 'Department',
                value: employee['department'] ?? 'Not Specified',
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: 'Position',
                value: employee['position'] ?? 'Not Specified',
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: 'Role',
                value: employee['role'] ?? 'employee',
                icon: Icons.admin_panel_settings_outlined,
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
    );
  }

  Widget _buildDetailField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
}

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  EmployeeManagementScreenState createState() =>
      EmployeeManagementScreenState();
}

class EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  Department? selectedDepartment;
  Position? selectedPosition;
  String selectedRole = 'employee';
  bool isLoading = false;
  String loadingMessage = '';

  final FirestoreService _firestoreService = FirestoreService();
  final CollectionReference employees =
      FirebaseFirestore.instance.collection('employees');

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

  void _showPasswordDialog(String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Employee Password',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Save this password now. You won\'t be able to see it again!',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      password,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: password));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addEmployee() async {
    try {
      if (selectedDepartment == null || selectedPosition == null) {
        throw Exception('Department and Position are required');
      }

      // Close the add employee modal before showing loading
      if (mounted) {
        Navigator.of(context).pop(); // Close the add employee dialog
      }

      _showLoading('Adding new employee...');

      final employee = Employee(
        id: '', // Will be set by Firestore
        name: nameController.text,
        email: emailController.text,
        department:
            selectedDepartment!.displayName, // Use the selected department
        position: selectedPosition!.displayName, // Use the selected position
        role: selectedRole,
      );

      final password = await _firestoreService.addEmployeeWithAuth(employee);

      // Clear form
      nameController.clear();
      emailController.clear();
      setState(() {
        selectedDepartment = null;
        selectedPosition = null;
        selectedRole = 'employee';
      });

      _hideLoading();

      if (mounted) {
        _showPasswordDialog(password); // Show the password dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee added successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      _hideLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding employee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      // Show confirmation dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete this employee? This action cannot be undone.',
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
        _showLoading('Deleting employee...');
        await _firestoreService.deleteEmployee(id);
        _hideLoading();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee deleted successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      _hideLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting employee: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) getDisplayName,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(getDisplayName(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showAddEmployeeDialog() {
    // Reset the form
    nameController.clear();
    emailController.clear();
    selectedDepartment = null;
    selectedPosition = null;
    selectedRole = 'employee';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Add New Employee',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Employee Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: emailController,
                      label: 'Employee Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<Department>(
                      label: 'Department',
                      icon: Icons.business_outlined,
                      value: selectedDepartment,
                      items: Department.values,
                      onChanged: (Department? value) {
                        setState(() => selectedDepartment = value);
                      },
                      getDisplayName: (dept) => dept.displayName,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<Position>(
                      label: 'Position',
                      icon: Icons.work_outline,
                      value: selectedPosition,
                      items: Position.values,
                      onChanged: (Position? value) {
                        setState(() => selectedPosition = value);
                      },
                      getDisplayName: (pos) => pos.displayName,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<String>(
                      label: 'Role',
                      icon: Icons.admin_panel_settings_outlined,
                      value: selectedRole,
                      items: const ['employee', 'admin'],
                      onChanged: (String? value) {
                        setState(() => selectedRole = value ?? 'employee');
                      },
                      getDisplayName: (role) => toSentenceCase(role),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDepartment != null &&
                        selectedPosition != null) {
                      addEmployee();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select both department and position'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Add Employee'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: const CustomAppBar(title: "Employee Management"),
          drawer: const CustomSidebar(),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Employee'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: AppTheme.textColor2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _showAddEmployeeDialog,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: employees
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Something went wrong',
                          style: TextStyle(color: AppTheme.accentColor),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: LoadingScreen(
                          message: 'Loading employees...',
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        // Convert department and position to sentence case
                        if (data['department'] != null) {
                          data['department'] =
                              toSentenceCase(data['department']);
                        }
                        if (data['position'] != null) {
                          data['position'] = toSentenceCase(data['position']);
                        }

                        return EmployeeListItem(
                          employee: document,
                          onDelete: deleteEmployee,
                          onView: () {
                            showDialog(
                              context: context,
                              builder: (context) => EmployeeDetailsDialog(
                                employee: document,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          LoadingScreen(
            message: loadingMessage,
          ),
      ],
    );
  }

// Utility function to convert string to sentence case
  String toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    departmentController.dispose();
    positionController.dispose();
    super.dispose();
  }
}
