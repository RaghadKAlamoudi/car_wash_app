import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_draft.dart';
import '../location/location_page.dart';
import '../location/customer_location_time_page.dart';
import '../widgets/safe_text.dart';
import '../l10n/app_localizations.dart';

enum BookingType { upcoming, past }

class AppointmentsPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const AppointmentsPage({
    super.key,
    required this.onLanguageChange,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(t.translate('Appointments')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ⏳ UPCOMING
          _bookingSection(
            context: context,
            title: t.translate('upcoming_wash'),
            type: BookingType.upcoming,
            emptyText: t.translate('no_upcoming'),
            user: user,
            t: t,
            onLanguageChange: onLanguageChange,
          ),

          const SizedBox(height: 32),

          /// 🕘 PAST
          _bookingSection(
            context: context,
            title: t.translate('past_washes'),
            type: BookingType.past,
            emptyText: t.translate('no_past'),
            user: user,
            t: t,
            onLanguageChange: onLanguageChange,
          ),
        ],
      ),
    );
  }
}

// ================= BOOKINGS =================

Widget _bookingSection({
  required BuildContext context,
  required String title,
  required BookingType type,
  required String emptyText,
  required User user,
  required AppLocalizations t,
  required Function(Locale) onLanguageChange,
}) {
  final stream = type == BookingType.upcoming
      ? FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'upcoming')
          .orderBy('date')
          .snapshots()
      : FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['completed', 'canceled'])
          .orderBy('date', descending: true)
          .snapshots();

  return StreamBuilder<QuerySnapshot>(
    stream: stream,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(emptyText,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      }

      final docs = snapshot.data!.docs;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          Column(
            children: docs
                .map(
                  (doc) => _bookingCard(
                    context: context,
                    booking: doc,
                    t: t,
                    onLanguageChange: onLanguageChange,
                  ),
                )
                .toList(),
          ),
        ],
      );
    },
  );
}

// ================= BOOKING CARD =================

Widget _bookingCard({
  required BuildContext context,
  required QueryDocumentSnapshot booking,
  required AppLocalizations t,
  required Function(Locale) onLanguageChange,
}) {
  final data = booking.data() as Map<String, dynamic>;

  // 📅 DATE
  final rawDate = data['date'];
  if (rawDate is! Timestamp) return const SizedBox();
  final date = rawDate.toDate();

  // 📌 STATUS
  final String status =
      (data['status'] ?? 'completed').toString();
  final bool isUpcoming = status == 'upcoming';

  // 🧼 SERVICE NAME
  final String washType =
      (data['washType'] ?? 'Service').toString();

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        // 🔶 ICON
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isUpcoming
                ? Theme.of(context)
                    .primaryColor
                    .withOpacity(0.12)
                : Colors.grey.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_car_wash,
            size: 22,
            color: isUpcoming
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ),

        const SizedBox(width: 12),

        // 🏷 TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeText(
                washType,
                titleCase: true,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // 🟠 UPCOMING MENU / 🟢 PAST BADGE
        if (isUpcoming)
          PopupMenuButton<String>(
            icon:
                const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) async {
              if (value == 'cancel') {
                await booking.reference
                    .update({'status': 'canceled'});
              }

              if (value == 'reschedule') {
                final draft =
                    BookingDraft.fromMap(data);

                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        draft.serviceType == 'admin_location'
                            ? CustomerLocationTimePage(
                                booking: draft,
                                onLanguageChange:
                                    onLanguageChange,
                              )
                            : LocationPage(
                                booking: draft,
                                onLanguageChange:
                                    onLanguageChange,
                              ),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'reschedule',
                child: Text(t.translate('Reschedule')),
              ),
              PopupMenuItem(
                value: 'cancel',
                child: Text(
                  t.translate('Cancel'),
                  style:
                      const TextStyle(color: Colors.red),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: status == 'completed'
                  ? Colors.green.withOpacity(0.12)
                  : Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              t.translate(status).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: status == 'completed'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
      ],
    ),
  );
}
