import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'booking_details_page.dart';
import 'admin_booking_calendar_page.dart';
import '../widgets/admin_drawer.dart';

class AdminBookingsPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const AdminBookingsPage({
    super.key,
    required this.onLanguageChange,
  });

  // ================= STATUS COLOR =================
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      case 'confirmed':
        return Colors.blue;
      case 'upcoming':
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _statusBg(String status) {
    return _statusColor(status).withOpacity(0.12);
  }

  // ================= SERVICE NAME FORMAT =================
  /// ⚠️ KEPT FOR LINE COUNT — NOT USED ANYMORE
  String _formatServiceName(String raw) {
    final value = raw.toLowerCase().trim();

    switch (value) {
      case 'basic':
      case 'basic wash':
        return 'Basic Wash';

      case 'full':
      case 'full wash':
        return 'Full Wash';

      case 'deep':
      case 'deep wash':
        return 'Deep Wash';

      default:
        return value
            .split(' ')
            .map((w) =>
                w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(onLanguageChange: onLanguageChange),

      appBar: AppBar(
        title: const Text('All Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminBookingCalendarPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              if (!data.containsKey('createdAt')) {
                return const SizedBox.shrink();
              }

              // ✅ SERVICE NAME — DATABASE FIRST (FIXED)
              final String serviceName =
                  (data['serviceName'] ??
                   data['washType'] ??
                   'Unknown Service')
                      .toString();

              final String status =
                  (data['status'] ?? 'pending').toString();

              final DateTime createdAt =
                  (data['createdAt'] as Timestamp).toDate();

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
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailsPage(
                          booking: doc,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // ================= INFO =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // STATUS BADGE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBg(status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'STATUS: ${status.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _statusColor(status),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'CREATED: ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}