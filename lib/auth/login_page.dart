import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/error_snackbar.dart';
import '../l10n/app_localizations.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  final Function(Locale) onLanguageChange;

  const LoginPage({
    super.key,
    required this.onLanguageChange,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  // ================= EMAIL LOGIN =================
  Future<void> _login() async {
    final t = AppLocalizations.of(context);

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showError(context, t.translate('enter_email_password'));
      return;
    }

    try {
      setState(() => loading = true);

      // 🔐 SIGN IN
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user!;
      final ref =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final snap = await ref.get();

      // 🧾 CREATE USER DOC IF MISSING
      if (!snap.exists) {
        await ref.set({
          'email': user.email,
          'role': 'user',
          'hasCar': true,
          'provider': 'email',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // ✅ DO NOT NAVIGATE
      // AuthGate will redirect automatically

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showError(context, t.translate('user_not_found'));
      } else if (e.code == 'wrong-password') {
        showError(context, t.translate('wrong_password'));
      } else {
        showError(context, t.translate('something_wrong'));
      }
    } catch (e) {
      showError(context, t.translate('something_wrong'));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌍 LANGUAGE SWITCH
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    widget.onLanguageChange(
                      isArabic
                          ? const Locale('en')
                          : const Locale('ar'),
                    );
                  },
                  child: Text(
                    isArabic
                        ? t.translate('english')
                        : t.translate('arabic'),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                t.translate('welcome_back'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.translate('login_subtitle'),
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              Text(t.translate('email')),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: t.translate('email'),
                ),
              ),

              const SizedBox(height: 20),

              Text(t.translate('password')),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: t.translate('password'),
                ),
              ),

              const SizedBox(height: 24),

              loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: Text(t.translate('login')),
                      ),
                    ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.translate('dont_have_account')),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupPage(
                            onLanguageChange:
                                widget.onLanguageChange,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      t.translate('signup'),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}