import 'package:flutter/material.dart';
import 'package:shift_master/widgets/custom_sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      drawer: CustomSidebar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Shift Master!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shifts');
              },
              child: const Text('Manage Shifts'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/employees');
              },
              child: const Text('Manage Employees'),
            ),
          ],
        ),
      ),
    );
  }
}
