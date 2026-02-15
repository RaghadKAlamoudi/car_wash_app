import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';
import '../location/service_booking_map_page.dart';

class DeepWashDetailsPage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const DeepWashDetailsPage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  State<DeepWashDetailsPage> createState() =>
      _DeepWashDetailsPageState();
}

class _DeepWashDetailsPageState extends State<DeepWashDetailsPage> {
  final Map<String, int> defaultServices = {
    'Exterior Wash': 60,
    'Interior Deep Cleaning': 120,
    'Engine Bay Cleaning': 90,
    'Tire & Rim Polish': 50,
  };

  Map<String, int> services = {};
  final Set<String> selected = {};

  int get total =>
      selected.fold(0, (sum, s) => sum + services[s]!);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('deep_wash'),
      actions: [_languageMenu()],
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('washType', isEqualTo: 'deep')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          services = Map.from(defaultServices);

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              services[data['name']] =
                  (data['price'] as num).toInt();
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t.translate('select_services'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.translate('select_one_or_more_services'),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              ...services.entries.map(
                (e) => _serviceRow(e.key, e.value, t),
              ),

              const SizedBox(height: 32),
              _bottomBar(t),
            ],
          );
        },
      ),
    );
  }

  Widget _serviceRow(String name, int price, AppLocalizations t) {
    final isSelected = selected.contains(name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _pill(name, isSelected, () => _toggle(name)),
          const SizedBox(width: 12),
          _pill(
            '$price ${t.translate('sar')}',
            isSelected,
            () => _toggle(name),
          ),
        ],
      ),
    );
  }

  void _toggle(String service) {
    setState(() {
      selected.contains(service)
          ? selected.remove(service)
          : selected.add(service);
    });
  }

  Widget _pill(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color:
            isSelected ? const Color(0xFF9ED8F8) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  const Icon(Icons.check, size: 16),
                if (isSelected) const SizedBox(width: 6),
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(AppLocalizations t) {
    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              '$total ${t.translate('sar')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: selected.isEmpty
                ? null
                : () {
                    widget.booking.washType = 'deep';
                    widget.booking.selectedWashServices =
                        selected.toList();
                    widget.booking.totalPrice = total;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceBookingMapPage(
                          booking: widget.booking,
                          onLanguageChange:
                              widget.onLanguageChange,
                        ),
                      ),
                    );
                  },
            child: Text(t.translate('next')),
          ),
        ),
      ],
    );
  }

  Widget _languageMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) {
        widget.onLanguageChange(
          value == 'en'
              ? const Locale('en')
              : const Locale('ar'),
        );
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'en', child: Text('English')),
        PopupMenuItem(value: 'ar', child: Text('العربية')),
      ],
    );
  }
}