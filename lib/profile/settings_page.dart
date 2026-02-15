import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/app_localizations.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale) onLanguageChange;

  const SettingsPage({
    super.key,
    required this.onLanguageChange,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = true;
  bool marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(t.translate('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= ACCOUNT MANAGEMENT =================
          _sectionTitle(t.translate('account')),

          _card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.person,
                  title: t.translate('personal_information'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(
                          onLanguageChange: widget.onLanguageChange,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
                _divider(),
                _tile(
                  icon: Icons.lock,
                  title: t.translate('change_password'),
                  onTap: () {
                    // You can add ChangePasswordPage later
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= PREFERENCES =================
          _sectionTitle(t.translate('preferences')),

          _card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.language,
                  title: t.translate('language'),
                  trailing: Text(
                    isArabic ? 'العربية' : 'English',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    widget.onLanguageChange(
                      isArabic
                          ? const Locale('en')
                          : const Locale('ar'),
                    );
                  },
                ),
                _divider(),
                _switchTile(
                  icon: Icons.notifications,
                  title: t.translate('push_notifications'),
                  value: pushNotifications,
                  onChanged: (v) {
                    setState(() => pushNotifications = v);
                  },
                ),
                _divider(),
                _switchTile(
                  icon: Icons.email,
                  title: t.translate('marketing_emails'),
                  value: marketingEmails,
                  onChanged: (v) {
                    setState(() => marketingEmails = v);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= SUPPORT & LEGAL =================
          _sectionTitle(t.translate('support_legal')),

          _card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.help_outline,
                  title: t.translate('help_center'),
                  onTap: () {},
                ),
                _divider(),
                _tile(
                  icon: Icons.description,
                  title: t.translate('terms_of_service'),
                  onTap: () {},
                ),
                _divider(),
                _tile(
                  icon: Icons.privacy_tip,
                  title: t.translate('privacy_policy'),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ================= DELETE ACCOUNT =================
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _confirmDeleteAccount,
            child: Text(
              t.translate('delete_account').toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.4,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.15),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.15),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value,
        activeThumbColor: Colors.orange,
        onChanged: onChanged,
      ),
    );
  }

  // ================= DELETE ACCOUNT =================

  Future<void> _confirmDeleteAccount() async {
    final t = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.translate('delete_account')),
        content: Text(t.translate('delete_account_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.translate('no')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              t.translate('yes'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .delete();

    await user.delete();
  }
}