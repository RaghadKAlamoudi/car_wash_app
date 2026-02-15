import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ADMIN PAGES
import '../dashboard/admin_dashboard_page.dart';
import '../services/admin_services_page.dart';
import '../bookings/admin_bookings_page.dart';
import '../users/admin_users_page.dart';
import '../locations/admin_locations_page.dart';

// AUTH GATE
import '../../main.dart';

class AdminDrawer extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const AdminDrawer({
    super.key,
    required this.onLanguageChange,
  });

  // ✅ STANDARD ADMIN NAVIGATION
  void _goTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // 🔐 LOGOUT
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AuthGate(onLanguageChange: onLanguageChange),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                'Admin Panel',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => _goTo(
              context,
              AdminDashboardPage(onLanguageChange: onLanguageChange),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.local_car_wash),
            title: const Text('Services'),
            onTap: () => _goTo(
              context,
              AdminServicesPage(onLanguageChange: onLanguageChange),
            ),
          ),

          // ✅ LOCATIONS
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Locations'),
            onTap: () => _goTo(
              context,
              const AdminLocationsPage(),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Bookings'),
            onTap: () => _goTo(
              context,
              AdminBookingsPage(onLanguageChange: onLanguageChange),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () => _goTo(
              context,
              AdminUsersPage(onLanguageChange: onLanguageChange),
            ),
          ),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}