import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class PromoCodesPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback onBack;

  const PromoCodesPage({
    super.key,
    required this.onLanguageChange,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
        title: Text(
          t.translate('promo_codes'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onLanguageChange(
                isArabic ? const Locale('en') : const Locale('ar'),
              );
            },
            child: Text(
              isArabic ? t.translate('english') : t.translate('arabic'),
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _promoCard(
            context: context,
            title: t.translate('welcome_bonus'),
            value: '20 SAR OFF',
            code: 'FIRSTWASH',
            description: t.translate('first_wash_discount_desc'),
            expires: t.translate('no_expiry'),
            isExpired: false,
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 16),
          _promoCard(
            context: context,
            title: t.translate('foam_master'),
            value: '50% OFF',
            code: 'FOAMY50',
            description: t.translate('foam_weekend_desc'),
            expires: t.translate('expired'),
            isExpired: true,
            icon: Icons.local_car_wash,
          ),
        ],
      ),
    );
  }

  // ================= PROMO CARD =================

  Widget _promoCard({
    required BuildContext context,
    required String title,
    required String value,
    required String code,
    required String description,
    required String expires,
    required bool isExpired,
    required IconData icon,
  }) {
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: isExpired ? Colors.grey : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: isExpired
                    ? Colors.grey.shade200
                    : Colors.orange.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: isExpired ? Colors.grey : Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          // PROMO CODE ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.translate('promo_code'),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              if (!isExpired)
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: code),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.translate('code_copied')),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    t.translate('copy_code'),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // DESCRIPTION
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          // EXPIRY
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${t.translate('expires')}: $expires',
              style: TextStyle(
                fontSize: 11,
                color: isExpired ? Colors.red : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}