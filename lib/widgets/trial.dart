import 'package:flutter/material.dart';
import 'package:shift_master/widgets/custom_sidebar.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: AppTheme.textColor2,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      drawer: const CustomSidebar(),
      body: SingleChildScrollView(
        child: Container(
          color: AppTheme.backgroundColor2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 24),
                _buildSummaryCards(context),
                const SizedBox(height: 24),
                _buildCharts(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Admin!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s an overview of your Shift Master dashboard.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryCard(context, 'Total Employees', '42', Icons.people),
        _buildSummaryCard(context, 'Active Shifts', '7', Icons.access_time),
        _buildSummaryCard(context, 'Pending Requests', '3', Icons.assignment),
      ],
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift Distribution',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(child: _buildPieChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildBarChart()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: AppTheme.primaryColor,
            value: 40,
            title: 'Morning',
            radius: 50,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            color: AppTheme.secondaryColor,
            value: 30,
            title: 'Afternoon',
            radius: 50,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            color: AppTheme.accentColor,
            value: 30,
            title: 'Night',
            radius: 50,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ];
                return Text(titles[value.toInt()],
                    style: const TextStyle(color: AppTheme.textColor));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 8, color: AppTheme.primaryColor)]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: 10, color: AppTheme.primaryColor)
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(toY: 14, color: AppTheme.primaryColor)
          ]),
          BarChartGroupData(x: 3, barRods: [
            BarChartRodData(toY: 15, color: AppTheme.primaryColor)
          ]),
          BarChartGroupData(x: 4, barRods: [
            BarChartRodData(toY: 13, color: AppTheme.primaryColor)
          ]),
          BarChartGroupData(x: 5, barRods: [
            BarChartRodData(toY: 10, color: AppTheme.primaryColor)
          ]),
          BarChartGroupData(
              x: 6,
              barRods: [BarChartRodData(toY: 6, color: AppTheme.primaryColor)]),
        ],
      ),
    );
  }
}
