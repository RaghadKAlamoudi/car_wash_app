import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as device_location;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_draft.dart';
import '../booking/date_time_page.dart';
import '../widgets/error_snackbar.dart';

class LocationPage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const LocationPage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LatLng? selectedLatLng;
  String selectedAddress = '';
  String selectedCity = '';

  final device_location.Location location =
      device_location.Location();

  @override
  void initState() {
    super.initState();

    // Safety: customer location only
    if (widget.booking.serviceType == 'admin_location') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  // =============================
  // 📍 CURRENT LOCATION
  // =============================
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      var permission = await location.hasPermission();
      if (permission ==
          device_location.PermissionStatus.denied) {
        permission = await location.requestPermission();
      }

      if (permission !=
          device_location.PermissionStatus.granted) {
        return;
      }

      final currentLocation = await location.getLocation();

      if (!mounted) return;

      setState(() {
        selectedLatLng = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      });
    } catch (_) {}
  }

  // =============================
  // 📌 MAP TAP (DO NOT TOUCH)
  // =============================
  Future<void> _onMapTap(LatLng point) async {
    // Immediate UI update
    setState(() {
      selectedLatLng = point;
      selectedAddress =
          'Lat ${point.latitude.toStringAsFixed(5)}, '
          'Lng ${point.longitude.toStringAsFixed(5)}';
      selectedCity = '';
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (!mounted || placemarks.isEmpty) return;

      final p = placemarks.first;

      final city =
          p.locality ??
          p.subAdministrativeArea ??
          p.administrativeArea ??
          '';

      final addressParts = [
        p.street,
        p.subLocality,
        city,
      ].where((e) => e != null && e.isNotEmpty).toList();

      setState(() {
        selectedCity = city;
        selectedAddress = addressParts.join(', ');
      });
    } catch (_) {}
  }

  // =============================
  // ➡️ CONFIRM & START
  // =============================
  Future<void> _confirmAndStart() async {
    if (selectedLatLng == null ||
        selectedAddress.isEmpty) {
      showError(context, 'Please select a location');
      return;
    }

    final cityToCheck =
        selectedCity.isNotEmpty ? selectedCity : 'Jeddah';

    final query = await FirebaseFirestore.instance
        .collection('locations')
        .where('city', isEqualTo: cityToCheck)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      showError(
        context,
        'Service not available in this area yet',
      );
      return;
    }

    widget.booking.latitude = selectedLatLng!.latitude;
    widget.booking.longitude = selectedLatLng!.longitude;
    widget.booking.address = selectedAddress;
    widget.booking.city = cityToCheck;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DateTimePage(
          booking: widget.booking,
          onLanguageChange: widget.onLanguageChange,
        ),
      ),
    );
  }

  // =============================
  // 🧱 UI
  // =============================
  @override
  Widget build(BuildContext context) {
    final canConfirm =
        selectedLatLng != null &&
        selectedAddress.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // ================= MAP =================
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  selectedLatLng ??
                  const LatLng(21.543333, 39.172778),
              initialZoom: 14,
              onTap: (_, p) => _onMapTap(p),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.carshine.app',
              ),
              if (selectedLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLatLng!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        size: 48,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ================= TOP BAR =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.language),
                      onSelected: (value) {
                        widget.onLanguageChange(
                          value == 'ar'
                              ? const Locale('ar')
                              : const Locale('en'),
                        );
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        PopupMenuItem(
                          value: 'ar',
                          child: Text('العربية'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= BOTTOM CARD =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.orange.withOpacity(0.15),
                        child: const Icon(
                          Icons.home,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedAddress.isEmpty
                                  ? 'Tap map to select location'
                                  : selectedAddress,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Saved Places'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              canConfirm ? _confirmAndStart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text(
                            'Confirm & Start',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}