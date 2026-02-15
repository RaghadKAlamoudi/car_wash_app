import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/main_navigation.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const AuthGate({
    super.key,
    required this.onLanguageChange,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ NOT LOGGED IN
        if (!snapshot.hasData) {
          return LoginPage(
            onLanguageChange: onLanguageChange,
          );
        }

        // ✅ LOGGED IN → MAIN NAVIGATION
        return MainNavigation(
          onLanguageChange: onLanguageChange,
        );
      },
    );
  }
}