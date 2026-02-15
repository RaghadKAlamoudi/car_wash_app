import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';
import '../payment/payment_page.dart';

class ServiceBookingMapPage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const ServiceBookingMapPage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  State<ServiceBookingMapPage> createState() =>
      _ServiceBookingMapPageState();
}

class _ServiceBookingMapPageState
    extends State<ServiceBookingMapPage> {
  LatLng? selectedLatLng;
  String selectedAddress = '';

  // ================= MAP TAP =================

  Future<void> _onMapTap(LatLng latLng) async {
    setState(() {
      selectedLatLng = latLng;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        selectedAddress =
            '${p.street ?? ''}, ${p.locality ?? ''}';
      }
    } catch (_) {}
  }

  // ================= CONFIRM =================

  void _confirmLocation() {
    if (selectedLatLng == null) return;

    widget.booking.latitude = selectedLatLng!.latitude;
    widget.booking.longitude = selectedLatLng!.longitude;
    widget.booking.address = selectedAddress;
    widget.booking.city = '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          booking: widget.booking,
          onLanguageChange: widget.onLanguageChange, // ✅ FIXED
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('select_location'),
      actions: [_languageMenu()],
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  center: const LatLng(21.543333, 39.172778), // Jeddah
                  zoom: 13,
                  onTap: (_, latLng) => _onMapTap(latLng),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (selectedLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLatLng!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Text(
                  t.translate('tap_on_map_to_select_location'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedLatLng == null ? null : _confirmLocation,
              child: Text(t.translate('continue')),
            ),
          ),
        ],
      ),
    );
  }

  // ================= LANGUAGE =================

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