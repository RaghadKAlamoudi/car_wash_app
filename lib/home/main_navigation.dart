import 'package:flutter/material.dart';

import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../vehicles/my_vehicles_page.dart';
import '../appointments/appointments_page.dart';

class MainNavigation extends StatefulWidget {
  final Function(Locale) onLanguageChange;

  const MainNavigation({
    super.key,
    required this.onLanguageChange,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _goHome() => setState(() => _currentIndex = 0);
  void _goAppointments() => setState(() => _currentIndex = 1);
  void _goVehicles() => setState(() => _currentIndex = 2);
  void _goProfile() => setState(() => _currentIndex = 3);

  late final List<Widget> _pages = [
    /// 🏠 HOME
    HomePage(
      onLanguageChange: widget.onLanguageChange,
      onProfileTap: _goProfile,
      onVehiclesTap: _goVehicles,
    ),

    /// 📅 APPOINTMENTS (NEW)
    AppointmentsPage(
      onLanguageChange: widget.onLanguageChange,
    ),

    /// 🚗 VEHICLES
    MyVehiclesPage(
      onLanguageChange: widget.onLanguageChange,
      onBack: _goHome,
    ),

    /// 👤 PROFILE
    ProfilePage(
      onLanguageChange: widget.onLanguageChange,
      onBack: _goHome,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ✅ floating nav style
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      /// 🔥 CUSTOM BOTTOM NAV
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFFFF8C32),
              unselectedItemColor: Colors.white70,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car),
                  label: 'Vehicles',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}