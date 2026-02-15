import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_page_layout.dart';
import '../car/car_type_page.dart';
import '../models/booking_draft.dart';
import '../l10n/app_localizations.dart';
import '../car/car_flow_mode.dart';
import 'edit_vehicle_page.dart';

class MyVehiclesPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback onBack;

  const MyVehiclesPage({
    super.key,
    required this.onLanguageChange,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final t = AppLocalizations.of(context);

    final vehiclesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vehicles')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return AppPageLayout(
      title: t.translate('my_vehicles'),
      onBack: onBack,
      actions: [_languageMenu()],
      child: StreamBuilder<QuerySnapshot>(
        stream: vehiclesStream,
        builder: (context, snapshot) {
          final vehicles = snapshot.data?.docs ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 SUBTITLE
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Text(
                  'My Garage',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 STATS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _infoCard(
                      title: 'TOTAL CARS',
                      value: vehicles.length.toString(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'STATUS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 ACTIVE FLEET
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ACTIVE FLEET',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 VEHICLE LIST
              Expanded(
                child: vehicles.isEmpty
                    ? Center(
                        child: Text(
                          t.translate('no_vehicles'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vehicles.length,
                        itemBuilder: (_, i) {
                          return _vehicleCard(
                            context,
                            vehicle: vehicles[i],
                            t: t,
                          );
                        },
                      ),
              ),

              // 🔹 ADD VEHICLE BUTTON
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(t.translate('add_vehicle')),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarTypePage(
                            booking: BookingDraft(),
                            onLanguageChange: onLanguageChange,
                            mode: CarFlowMode.vehicleOnly,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🔹 INFO CARD
  Widget _infoCard({
    required String title,
    required String value,
  }) {
    return Container(
      width: 140,
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 VEHICLE CARD (FIXED)
  Widget _vehicleCard(
    BuildContext context, {
    required QueryDocumentSnapshot vehicle,
    required AppLocalizations t,
  }) {
    final data = vehicle.data() as Map<String, dynamic>;

    final plateEn = (data['plateEn'] ?? '').toString();
    final plateAr = (data['plateAr'] ?? '').toString();
    final hasPlate = plateEn.isNotEmpty || plateAr.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.orange.shade100,
            child: const Icon(Icons.directions_car),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['brand']} ${data['model']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasPlate
                            ? (plateAr.isNotEmpty
                                ? '$plateEn | $plateAr'
                                : plateEn)
                            : (t.locale.languageCode == 'ar'
                                ? 'لم يتم إضافة اللوحة'
                                : 'Plate not added'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${data['year']} • ${data['carType']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditVehiclePage(
                        vehicleRef: vehicle.reference,
                        vehicle: data,
                        onLanguageChange: onLanguageChange,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => vehicle.reference.delete(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 LANGUAGE
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