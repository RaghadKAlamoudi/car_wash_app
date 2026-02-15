import 'package:flutter/material.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';
import 'basic_wash_details_page.dart';
import 'full_wash_details_page.dart';
import 'deep_wash_details_page.dart';

class WashTypePage extends StatelessWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const WashTypePage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  void _resetForNewService() {
    booking.selectedWashServices.clear();
    booking.totalPrice = 0;

    // 🔁 Reset location
    booking.latitude = null;
    booking.longitude = null;
    booking.address = '';
    booking.city = '';

    // 🔁 Reset date & time
    booking.selectedTime = null;
    booking.dateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('select_wash_type'),
      actions: [_languageMenu()],
      child: Column(
        children: [
          _card(context, t.translate('basic_wash'), () {
            _resetForNewService();
            booking.washType = 'Basic Wash';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BasicWashDetailsPage(
                  booking: booking,
                  onLanguageChange: onLanguageChange,
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          _card(context, t.translate('full_wash'), () {
            _resetForNewService();
            booking.washType = 'Full Wash';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullWashDetailsPage(
                  booking: booking,
                  onLanguageChange: onLanguageChange,
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          _card(context, t.translate('deep_wash'), () {
            _resetForNewService();
            booking.washType = 'Deep Wash';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeepWashDetailsPage(
                  booking: booking,
                  onLanguageChange: onLanguageChange,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _languageMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) {
        onLanguageChange(
          value == 'en' ? const Locale('en') : const Locale('ar'),
        );
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'en', child: Text('English')),
        PopupMenuItem(value: 'ar', child: Text('العربية')),
      ],
    );
  }

  Widget _card(BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}