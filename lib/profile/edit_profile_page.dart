import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/error_snackbar.dart';
import '../l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback onBack;

  const EditProfilePage({
    super.key,
    required this.onLanguageChange,
    required this.onBack,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = true;
  bool saving = false;

  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadData();
  }

  Future<void> _loadData() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = snap.data() ?? {};
    nameController.text = data['name'] ?? '';
    emailController.text = user!.email ?? '';

    setState(() => loading = false);
  }

  Future<void> _saveProfile() async {
    final t = AppLocalizations.of(context);

    if (nameController.text.trim().isEmpty) {
      showError(context, t.translate('fill_all_fields'));
      return;
    }

    try {
      setState(() => saving = true);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': nameController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('save'))),
      );
    } catch (_) {
      showError(context, t.translate('something_wrong'));
    } finally {
      setState(() => saving = false);
    }
  }

  Future<void> _changeEmail() async {
    final t = AppLocalizations.of(context);

    try {
      setState(() => saving = true);

      await user!.updateEmail(emailController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'email': emailController.text.trim()});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('change_email'))),
      );
    } catch (_) {
      showError(context, t.translate('something_wrong'));
    } finally {
      setState(() => saving = false);
    }
  }

  Future<void> _changePassword() async {
    final t = AppLocalizations.of(context);

    if (passwordController.text.length < 6) {
      showError(context, t.translate('invalid_password'));
      return;
    }

    try {
      setState(() => saving = true);

      await user!.updatePassword(passwordController.text.trim());
      passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('change_password'))),
      );
    } catch (_) {
      showError(context, t.translate('something_wrong'));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('profile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              widget.onLanguageChange(
                value == 'en'
                    ? const Locale('en')
                    : const Locale('ar'),
              );
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'en',
                child: Text(t.translate('english')),
              ),
              PopupMenuItem(
                value: 'ar',
                child: Text(t.translate('arabic')),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: t.translate('name'),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: t.translate('email'),
            ),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: saving ? null : _changeEmail,
            child: Text(t.translate('change_email')),
          ),

          const Divider(height: 32),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: t.translate('new_password'),
            ),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: saving ? null : _changePassword,
            child: Text(t.translate('change_password')),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: saving ? null : _saveProfile,
            child: Text(t.translate('save')),
          ),
        ],
      ),
    );
  }
}