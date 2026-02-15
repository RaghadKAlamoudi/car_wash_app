import 'package:flutter/material.dart';

import '../models/booking_draft.dart';
import '../car/car_details_page.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';
import 'car_flow_mode.dart';

class CarTypePage extends StatelessWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;
  final CarFlowMode mode;
  final VoidCallback? onFinished;

  const CarTypePage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
    this.mode = CarFlowMode.booking,
    this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('select_car_type'),
      actions: [_languageMenu()],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 SUBTITLE
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'CAR MANAGEMENT',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          _typeCard(
            context,
            title: t.translate('sedan'),
            subtitle: 'Comfortable 4-door vehicles',
            icon: Icons.directions_car,
          ),
          const SizedBox(height: 16),

          _typeCard(
            context,
            title: t.translate('suv'),
            subtitle: 'Large family and 4×4 vehicles',
            icon: Icons.airport_shuttle,
          ),
          const SizedBox(height: 16),

          _typeCard(
            context,
            title: t.translate('truck'),
            subtitle: 'Commercial and heavy duty',
            icon: Icons.local_shipping,
          ),
        ],
      ),
    );
  }

  Widget _typeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        booking.carType = title;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailsPage(
              booking: booking,
              onLanguageChange: onLanguageChange,
              mode: mode,
              onFinished: onFinished, // 🔥 THIS IS THE FIX
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.orange.shade100,
              child: Icon(icon, color: Colors.orange),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
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
}