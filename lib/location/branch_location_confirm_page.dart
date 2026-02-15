import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_draft.dart';
import '../payment/payment_page.dart';
import '../widgets/app_page_layout.dart';

class BranchLocationConfirmPage extends StatelessWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const BranchLocationConfirmPage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  Widget build(BuildContext context) {
    return AppPageLayout(
      title: 'Confirm Branch Location',
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('locations')
            .doc(booking.locationId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final lat = data['lat'];
          final lng = data['lng'];

          if (lat == null || lng == null) {
            return const Center(
              child: Text('Branch location not available'),
            );
          }

          final branchLatLng = LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          );


          return Column(
            children: [
              Container(
                height: 320,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: branchLatLng,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.carwash.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: branchLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.store,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.store),
                title: Text(
                  '${data['city']} • ${data['area']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(data['street'] ?? ''),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Confirm & Pay'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          booking: booking,
                          onLanguageChange:
                              onLanguageChange,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}