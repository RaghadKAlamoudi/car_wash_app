import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_draft.dart';
import '../wash/wash_type_page.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';
import '../car/car_type_page.dart';
import '../car/car_flow_mode.dart';
import '../home/main_navigation.dart';
import 'edit_vehicle_page.dart';

class SelectVehiclePage extends StatelessWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const SelectVehiclePage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
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
      child: StreamBuilder<QuerySnapshot>(
        stream: vehiclesStream,
        builder: (context, snapshot) {
          final vehicles = snapshot.data?.docs ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              /// 🔹 ACTIVE FLEET TITLE
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

              /// 🔹 VEHICLE LIST
              Expanded(
                child: vehicles.isEmpty
                    ? Center(
                        child: Text(
                          t.translate('no_vehicles'),
                          style:
                              const TextStyle(color: Colors.grey),
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

              /// 🔹 ADD VEHICLE BUTTON
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
                            onFinished: () {
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MainNavigation(
                                    onLanguageChange:
                                        onLanguageChange,
                                  ),
                                ),
                                (_) => false,
                              );
                            },
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

  // ================= VEHICLE CARD (MATCHES MY VEHICLES) =================

  Widget _vehicleCard(
    BuildContext context, {
    required QueryDocumentSnapshot vehicle,
    required AppLocalizations t,
  }) {
    final data = vehicle.data() as Map<String, dynamic>;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        /// ✅ SELECT VEHICLE (FLOW PRESERVED)
        booking.vehicleId = vehicle.id;
        booking.carType = data['carType'];
        booking.carBrand = data['brand'];
        booking.carModel = data['model'];
        booking.carYear = data['year'];
        booking.licensePlateEn = data['plateEn'];
        booking.licensePlateAr = data['plateAr'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WashTypePage(
              booking: booking,
              onLanguageChange: onLanguageChange,
            ),
          ),
        );
      },
      child: Container(
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['brand']} ${data['model']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${data['plateEn']} | ${data['plateAr']}',
                          style:
                              const TextStyle(fontSize: 12),
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

            /// ✏️ EDIT (OPTIONAL – SAME AS MY VEHICLES)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditVehiclePage(
                      vehicleRef: vehicle.reference,
                      vehicle: data,
                      onLanguageChange:
                          onLanguageChange,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}