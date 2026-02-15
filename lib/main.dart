import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// USER
import 'auth/login_page.dart';
import 'home/main_navigation.dart';
import 'car/car_type_page.dart';
import 'models/booking_draft.dart';
import 'theme/app_theme.dart';

// ADMIN
import 'admin/dashboard/admin_dashboard_page.dart';

// LOCALIZATION
import 'l10n/app_localizations.dart';

// LANDING
import 'landing/first_launch_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // REQUIRED FOR FLUTTER WEB LOGIN STABILITY
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(const MyApp());
}

/// =======================================================
/// APP ROOT
/// =======================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  /// 🔁 Load saved language
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('lang') ?? 'en';

    setState(() {
      _locale = Locale(code);
    });
  }

  /// 🌍 Change language globally
  Future<void> _changeLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', locale.languageCode);

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// 🔥 FIRST LAUNCH → AUTH → ROLE FLOW
      home: FirstLaunchGate(
        onLanguageChange: _changeLocale,
      ),
    );
  }
}

/// =======================================================
/// AUTH GATE (DO NOT TOUCH 🔥)
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }

        // ❌ NOT LOGGED IN
        if (!snapshot.hasData) {
          return LoginPage(
            onLanguageChange: onLanguageChange,
          );
        }

        // ✅ LOGGED IN
        return RoleResolver(
          onLanguageChange: onLanguageChange,
        );
      },
    );
  }
}

/// =======================================================
/// ROLE RESOLVER (ADMIN / USER)
/// =======================================================
class RoleResolver extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const RoleResolver({
    super.key,
    required this.onLanguageChange,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const _Loading();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _Loading();
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final role = data['role'] ?? 'user';
        final hasCar = data['hasCar'] ?? false;

        // 👑 ADMIN
        if (role == 'admin') {
          return AdminDashboardPage(
            onLanguageChange: onLanguageChange,
          );
        }

        // 🚗 USER WITHOUT CAR
        if (!hasCar) {
          return CarTypePage(
            booking: BookingDraft(),
            onLanguageChange: onLanguageChange,
          );
        }

        // 👤 NORMAL USER
        return MainNavigation(
          onLanguageChange: onLanguageChange,
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