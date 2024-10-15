import 'package:flutter/material.dart';
import 'package:shift_master/services/firebase_service.dart';

class CustomSidebar extends StatelessWidget {
  final FirebaseService firebaseService = FirebaseService();

  CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const UserAccountsDrawerHeader(
                  accountName: Text("Charlotte Walker"),
                  accountEmail: Text("charlotte@example.com"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage:
                        NetworkImage("https://example.com/profile.jpg"),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text("Shifts"),
                  onTap: () => Navigator.pushNamed(context, '/shifts'),
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text("Employees"),
                  onTap: () => Navigator.pushNamed(context, '/employees'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notifications"),
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                // Add other sidebar items...
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Logout"),
            onTap: () async {
              await firebaseService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
