import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/error_snackbar.dart';
import '../l10n/app_localizations.dart';
import '../home/home_page.dart';

class SignupPage extends StatefulWidget {
  final Function(Locale) onLanguageChange;

  const SignupPage({
    super.key,
    required this.onLanguageChange,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  // ================= EMAIL SIGNUP =================
  Future<void> _signup() async {
    final t = AppLocalizations.of(context);

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showError(context, t.translate('fill_all_fields'));
      return;
    }

    try {
      setState(() => loading = true);

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user',
        'hasCar': false,
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            onLanguageChange: widget.onLanguageChange,
            onProfileTap: () {},
            onVehiclesTap: () {},
          ),
        ),
      );

    } on FirebaseAuthException catch (_) {
      showError(context, t.translate('signup_failed'));
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

              // 🟠 TITLE
              Text(
                t.translate('signup'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.translate('signup_subtitle'),
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // 👤 FULL NAME
              Text(t.translate('full_name')),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  hintText: t.translate('full_name'),
                ),
              ),

              const SizedBox(height: 20),

              // 📧 EMAIL
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

              // 🔒 PASSWORD
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

              const SizedBox(height: 28),

              // 🔥 CREATE ACCOUNT
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signup,
                        child: Text(t.translate('create_account')),
                      ),
                    ),

              const SizedBox(height: 20),

              // 📜 TERMS
              Text(
                t.translate('terms_text'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 32),

              // 🔁 BACK TO LOGIN
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    t.translate('login'),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}