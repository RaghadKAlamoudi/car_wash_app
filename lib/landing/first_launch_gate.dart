import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_gate.dart';
import '../landing/landing_page.dart';

class FirstLaunchGate extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const FirstLaunchGate({
    super.key,
    required this.onLanguageChange,
  });

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstLaunch') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstLaunch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return LandingPage(
            onLanguageChange: onLanguageChange,
          );
        }

        return AuthGate(
          onLanguageChange: onLanguageChange,
        );
      },
    );
  }
}