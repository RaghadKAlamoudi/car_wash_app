import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_draft.dart';
import '../services/booking_service.dart';
import '../car/car_type_page.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';

class MyBookingsPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const MyBookingsPage({
    super.key,
    required this.onLanguageChange,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return AppPageLayout(
      title: t.translate('my_bookings'),
      showBack: false,
      actions: [_languageMenu()],
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data?.docs ?? [];

          if (bookings.isEmpty) {
            return _emptyState(context, t);
          }

          final upcoming =
              bookings.where((b) => b['status'] == 'upcoming').toList();

          final past = bookings.where(
            (b) =>
                b['status'] == 'completed' ||
                b['status'] == 'canceled',
          ).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle(t.translate('upcoming_wash')),
              const SizedBox(height: 12),

              if (upcoming.isEmpty)
                Text(t.translate('no_upcoming'))
              else
                ...upcoming.map(
                  (b) => _bookingRow(context, b, true, t),
                ),

              const SizedBox(height: 32),

              _sectionTitle(t.translate('past_washes')),
              const SizedBox(height: 12),

              if (past.isEmpty)
                Text(t.translate('no_past'))
              else
                ...past.map(
                  (b) => _bookingRow(context, b, false, t),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _bookingRow(
    BuildContext context,
    QueryDocumentSnapshot booking,
    bool isUpcoming,
    AppLocalizations t,
  ) {
    final date = (booking['date'] as Timestamp).toDate();
    final status = booking['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['washType'] ?? t.translate('wash'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == 'canceled'
                        ? Colors.red
                        : status == 'completed'
                            ? Colors.green
                            : Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          if (isUpcoming)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'cancel') {
                  await BookingService.cancelBooking(booking.id);
                }
                if (value == 'reschedule') {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 30)),
                  );
                  if (newDate != null) {
                    await BookingService.rescheduleBooking(
                      booking.id,
                      newDate,
                    );
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'reschedule',
                  child: Text(t.translate('reschedule')),
                ),
                PopupMenuItem(
                  value: 'cancel',
                  child: Text(
                    t.translate('cancel'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.translate('no_bookings'),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CarTypePage(
                    booking: BookingDraft(),
                    onLanguageChange: onLanguageChange,
                  ),
                ),
              );
            },
            child: Text(t.translate('new_wash')),
          ),
        ],
      ),
    );
  }

  Widget _languageMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) {
        onLanguageChange(
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