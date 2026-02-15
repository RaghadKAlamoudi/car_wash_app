import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_page.dart';
import '../admin/dashboard/admin_dashboard_page.dart';
import '../home/main_navigation.dart';

/// =======================================================
/// AUTH GATE
/// Handles:
/// - Login state
/// - Role resolution (admin / user)
/// =======================================================
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
        // ⏳ Waiting for Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }

        // ❌ NOT LOGGED IN
        if (!snapshot.hasData) {
          return LoginPage(
            onLanguageChange: onLanguageChange,
          );
        }

        final user = snapshot.data!;

        // 🔐 FETCH USER DATA FROM FIRESTORE (ROLE ONLY)
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const _Loading();
            }

            if (!roleSnapshot.hasData ||
                !roleSnapshot.data!.exists) {
              return const _Loading();
            }

            final data =
                roleSnapshot.data!.data() as Map<String, dynamic>? ??
                    {};

            final role = data['role'] ?? 'user';

            // 👑 ADMIN
            if (role == 'admin') {
              return AdminDashboardPage(
                onLanguageChange: onLanguageChange,
              );
            }

            // 👤 NORMAL USER → HOME
            return MainNavigation(
              onLanguageChange: onLanguageChange,
            );
          },
        );
      },
    );
  }
}

/// =======================================================
/// LOADING SCREEN
/// =======================================================
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}