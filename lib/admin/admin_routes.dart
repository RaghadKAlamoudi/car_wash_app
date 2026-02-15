import 'package:flutter/material.dart';

import 'auth/admin_login_page.dart';
import 'dashboard/admin_dashboard_page.dart';
import 'services/admin_services_page.dart';
import 'bookings/admin_bookings_page.dart';
import 'users/admin_users_page.dart';
import 'locations/admin_locations_page.dart';

class AdminRoutes {
  static const login = '/admin-login';
  static const dashboard = '/admin-dashboard';
  static const services = '/admin-services';
  static const bookings = '/admin-bookings';
  static const users = '/admin-users';
  static const locations = '/admin-locations';

  static Map<String, WidgetBuilder> routes({
    required Function(Locale) onLanguageChange,
  }) {
    return {
      login: (_) => AdminLoginPage(
            onLanguageChange: onLanguageChange,
          ),

      dashboard: (_) => AdminDashboardPage(
            onLanguageChange: onLanguageChange,
          ),

      services: (_) => AdminServicesPage(
            onLanguageChange: onLanguageChange,
          ),

      bookings: (_) => AdminBookingsPage(
            onLanguageChange: onLanguageChange,
          ),

      users: (_) => AdminUsersPage(
            onLanguageChange: onLanguageChange,
          ),

      locations: (_) => const AdminLocationsPage(),
    };
  }
}
