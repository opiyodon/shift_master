import 'package:flutter/material.dart';
import 'package:shift_master/services/firebase_service.dart';
import 'package:shift_master/services/firestore_service.dart';
import 'package:shift_master/utils/theme.dart';

class CustomSidebar extends StatefulWidget {
  const CustomSidebar({super.key});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _firebaseService.auth.currentUser;
    if (user != null) {
      final data = await _firestoreService.getUser(user.uid);
      setState(() {
        userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userData != null
                    ? "${userData!['firstName']} ${userData!['lastName']}"
                    : "Loading...",
                style: const TextStyle(
                  color: AppTheme.textColor2,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                userData != null ? userData!['email'] : "Loading...",
                style: const TextStyle(
                  color: AppTheme.textColor2,
                  fontSize: 14,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppTheme.accentColor,
                child: Text(
                  userData != null ? userData!['firstName'][0] : "?",
                  style: const TextStyle(
                    fontSize: 32,
                    color: AppTheme.textColor2,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildListTile(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    route: '/',
                  ),
                  _buildListTile(
                    icon: Icons.people,
                    title: "Employees",
                    route: '/employees',
                  ),
                  _buildListTile(
                    icon: Icons.schedule,
                    title: "Shifts",
                    route: '/shifts',
                  ),
                  _buildListTile(
                    icon: Icons.calendar_today,
                    title: "Calendar Feeds",
                    route: '/calendar',
                  ),
                  _buildListTile(
                    icon: Icons.sticky_note_2,
                    title: "Notice Board",
                    route: '/notice-board',
                    badge: "12",
                  ),
                  _buildListTile(
                    icon: Icons.notifications,
                    title: "Notifications",
                    route: '/notifications',
                  ),
                  _buildListTile(
                    icon: Icons.settings,
                    title: "Settings",
                    route: '/settings',
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: AppTheme.textColor2,
            ),
            _buildListTile(
              icon: Icons.exit_to_app,
              title: "Logout",
              onTap: () async {
                await _firebaseService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              showTrailing: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? route,
    String? badge,
    VoidCallback? onTap,
    bool showTrailing = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textColor2,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textColor2,
          fontSize: 16,
        ),
      ),
      trailing: showTrailing
          ? badge != null
          ? CircleAvatar(
        radius: 12,
        backgroundColor: AppTheme.accentColor,
        child: Text(
          badge,
          style: const TextStyle(
            color: AppTheme.textColor2,
            fontSize: 12,
          ),
        ),
      )
          : const Icon(
        Icons.chevron_right,
        color: AppTheme.textColor2,
      )
          : null,
      onTap: onTap ??
          (route != null ? () => Navigator.pushNamed(context, route) : null),
    );
  }
}
