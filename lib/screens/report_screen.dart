import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:shift_master/models/report_model.dart';
import 'package:shift_master/screens/loading_screen_dart.dart';
import 'package:shift_master/services/firestore_service.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/models/shift_model.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/custom_app_bar.dart';
import 'package:shift_master/widgets/custom_sidebar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  ReportsScreenState createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedReportType = 'Employees';
  DateTimeRange? _dateRange;
  List<Employee> _employees = [];
  List<ShiftData> _shifts = [];
  bool _isLoading = false;
  String loadingMessage = '';

  void _showLoading(String message) {
    setState(() {
      _isLoading = true;
      loadingMessage = message;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
      loadingMessage = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
    _loadInitialData();
    _loadReports();
  }

  Future<void> _loadReports() async {
    _firestoreService.getReports().listen((reports) {
      setState(() {});
    });
  }

  Future<void> _loadInitialData() async {
    try {
      _showLoading('Loading employees...');
      _employees = await _firestoreService.fetchInitialEmployees();
      // Load shifts for the selected date range
      await _loadShifts();
    } catch (e) {
      _showErrorSnackBar('Error loading data: $e');
    } finally {
      _hideLoading();
    }
  }

  Future<void> _loadShifts() async {
    if (_dateRange == null) return;
    try {
      _showLoading('Loading shifts...');
      // Subscribe to shifts stream and filter by date range
      _firestoreService.getShifts().listen((shifts) {
        final filteredShifts = shifts.where((shift) {
          final shiftDate = shift.startTime;
          return shiftDate.isAfter(_dateRange!.start) &&
              shiftDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        }).toList();
        setState(() => _shifts = filteredShifts);
        _hideLoading();
      });
    } catch (e) {
      _showErrorSnackBar('Error loading shifts: $e');
      _hideLoading();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: AppTheme.textColor2,
              surface: AppTheme.backgroundColor2!,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      await _loadShifts();
    }
  }

  Future<void> _generateAndPreviewReport() async {
    try {
      _showLoading('Generating report...');
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            _buildReportHeader(),
            pw.SizedBox(height: 20),
            _selectedReportType == 'Employees'
                ? _buildEmployeesReport()
                : _buildShiftsReport(),
          ],
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
          ),
        ),
      );

      // Save PDF
      final Uint8List pdfBytes = await pdf.save();
      final fileName =
          '${_selectedReportType.toLowerCase()}_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      // Save to device and get file path
      final filePath = await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );

      // Save report metadata to Firestore
      await _firestoreService.saveReport(
        type: _selectedReportType.toString(),
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        fileUrl: filePath,
        totalRecords: _selectedReportType == 'Employees'
            ? _employees.length
            : _shifts.length,
      );

      // Preview PDF
      await Printing.layoutPdf(
        onLayout: (format) => Future.value(pdfBytes),
        name: fileName,
      );
    } catch (e) {
      _showErrorSnackBar('Error generating report: $e');
    } finally {
      _hideLoading();
    }
  }

  // Add a new method to build reports list
  Widget _buildReportsList() {
    return StreamBuilder<List<Report>>(
      stream: _firestoreService.getReports(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reports = snapshot.data ?? [];

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    report.type[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('${report.type} Report'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Generated: ${DateFormat('MMM d, yyyy').format(report.generatedAt)}'),
                    Text(
                        'Period: ${DateFormat('MMM d').format(report.startDate)} - ${DateFormat('MMM d, yyyy').format(report.endDate)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${report.totalRecords} records'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReport(report.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Add method to delete a report
  Future<void> _deleteReport(String reportId) async {
    try {
      await _firestoreService.deleteReport(reportId);
    } catch (e) {
      _showErrorSnackBar('Error deleting report: $e');
    }
  }

  pw.Widget _buildReportHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$_selectedReportType Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Generated on: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        if (_dateRange != null) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            'Period: ${DateFormat('MMM d, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}',
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildEmployeesReport() {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      headers: ['Name', 'Department', 'Position', 'Role'],
      data: _employees
          .map((employee) => [
                employee.name,
                employee.department,
                employee.position,
                employee.role,
              ])
          .toList(),
      cellAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 12),
    );
  }

  pw.Widget _buildShiftsReport() {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      headers: ['Date', 'Employee', 'Start Time', 'End Time', 'Status'],
      data: _shifts.map((shift) {
        // Find the employee name by matching the employeeId
        final employee = _employees.firstWhere(
          (emp) => emp.id == shift.employeeId,
          orElse: () => Employee(
            id: '',
            name: 'Unknown Employee',
            email: '',
            department: '',
            position: '',
            role: '',
          ),
        );

        return [
          DateFormat('MMM d, yyyy').format(shift.startTime),
          employee.name,
          DateFormat('hh:mm a').format(shift.startTime),
          DateFormat('hh:mm a').format(shift.endTime),
          shift.status,
        ];
      }).toList(),
      cellAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: const CustomAppBar(title: "Reports"),
          drawer: const CustomSidebar(),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              children: [
                _buildReportControls(),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Report Preview'),
                            Tab(text: 'Generated Reports'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildReportPreview(),
                              _buildReportsList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          LoadingScreen(
            message: loadingMessage,
          ),
      ],
    );
  }

  Widget _buildReportControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor2,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedReportType,
                  decoration: const InputDecoration(
                    labelText: 'Report Type',
                    filled: true,
                  ),
                  items: ['Employees', 'Shifts']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedReportType = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: const Text('Select Date Range'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generateAndPreviewReport,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generate Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportPreview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _selectedReportType == 'Employees'
          ? _buildEmployeesPreview()
          : _buildShiftsPreview(),
    );
  }

  Widget _buildEmployeesPreview() {
    return ListView.builder(
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final employee = _employees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                employee.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(employee.name),
            subtitle: Text('${employee.department} - ${employee.position}'),
            trailing: Text(
              employee.role,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShiftsPreview() {
    return ListView.builder(
      itemCount: _shifts.length,
      itemBuilder: (context, index) {
        final shift = _shifts[index];

        // Find the corresponding employee
        final employee = _employees.firstWhere(
          (emp) => emp.id == shift.employeeId,
          orElse: () => Employee(
            id: '',
            name: 'Unknown Employee',
            email: '',
            department: '',
            position: '',
            role: '',
          ),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                employee.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(employee.name),
            subtitle: Text(
              '${DateFormat('MMM d, yyyy').format(shift.startTime)}\n'
              '${DateFormat('hh:mm a').format(shift.startTime)} - '
              '${DateFormat('hh:mm a').format(shift.endTime)}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: shift.status == 'PENDING'
                    ? Colors.orange
                    : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                shift.status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
