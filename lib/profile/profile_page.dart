import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/app_localizations.dart';
import '../vehicles/my_vehicles_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'coupons_page.dart';
import 'payment_history_page.dart';

class ProfilePage extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback onBack;

  const ProfilePage({
    super.key,
    required this.onLanguageChange,
    required this.onBack,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  String name = '';
  String email = '';

  int washes = 0;
  int points = 0;
  int coupons = 0;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = user!.uid;

    // 👤 USER DATA
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final userData = userSnap.data() ?? {};

    // 🚗 WASHES COUNT (completed only)
    final washesSnap = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .get();

    if (!mounted) return;

    setState(() {
      name = userData['name'] ?? '';
      email = user!.email ?? '';

      points = (userData['points'] ?? 0) as int;
      coupons = (userData['coupons'] ?? 0) as int;
      washes = washesSnap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _header(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _statsCard(),
                const SizedBox(height: 16),
                _goldStatus(),
                const SizedBox(height: 24),

                /// 🚗 MY VEHICLES
                _menuItem(
                  icon: Icons.directions_car,
                  title: t.translate('my_vehicles'),
                  subtitle: 'Manage your cars',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyVehiclesPage(
                          onLanguageChange: widget.onLanguageChange,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),

              /// 💳 PAYMENT
              _menuItem(
                icon: Icons.credit_card,
                title: t.translate('payment'),
                subtitle: 'Payment history',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentHistoryPage(
                        onLanguageChange: widget.onLanguageChange,
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
              ),


                /// 🎁 COUPONS
                _menuItem(
                  icon: Icons.card_giftcard,
                  title: 'Promo Codes',
                  subtitle: 'Available coupons',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PromoCodesPage(
                          onLanguageChange: widget.onLanguageChange,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),

                /// ⚙️ SETTINGS
                _menuItem(
                  icon: Icons.settings,
                  title: t.translate('settings'),
                  subtitle: 'Privacy & preferences',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(
                          onLanguageChange: widget.onLanguageChange,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                /// 🚪 SIGN OUT
                OutlinedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    widget.onBack();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    t.translate('logout'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFFF7A18),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
              const Spacer(),

              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                onPressed: () {
                  widget.onLanguageChange(
                    isArabic ? const Locale('en') : const Locale('ar'),
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
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
            ],
          ),

          const SizedBox(height: 12),

          Column(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat('Washes', washes.toString()),
          _Stat('Points', points.toString(), highlight: true),
          _Stat('Coupons', coupons.toString()),
        ],
      ),
    );
  }

  // ================= GOLD STATUS =================

  Widget _goldStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gold Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Next reward at 1000 pts ($points / 1000)',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (points / 1000).clamp(0.0, 1.0),
            color: const Color(0xFFFF7A18),
            backgroundColor: Colors.white,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  // ================= MENU ITEM =================

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF5F5F5),
          child: Icon(icon, color: const Color(0xFFFF7A18)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ================= STAT =================

class _Stat extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  const _Stat(this.title, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: highlight ? const Color(0xFFFF7A18) : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}