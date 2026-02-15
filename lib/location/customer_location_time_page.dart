import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';
import 'branch_location_confirm_page.dart';

class CustomerLocationTimePage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const CustomerLocationTimePage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  State<CustomerLocationTimePage> createState() =>
      _CustomerLocationTimePageState();
}

class _CustomerLocationTimePageState
    extends State<CustomerLocationTimePage> {
  String? expandedLocationId;

  final DateFormat displayFmt =
      DateFormat('EEE, MMM d • HH:mm');

  @override
  void initState() {
    super.initState();

    // ⛔ SAFETY: This page is ONLY for branch bookings
    if (widget.booking.serviceType != 'admin_location') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
  }

  // ===============================
  // 🕒 SELECT SLOT
  // ===============================
  void _selectTimeSlot(
    String locationId,
    DateTime dateTime,
  ) {
    widget.booking.locationId = locationId;
    widget.booking.dateTime = dateTime;
    widget.booking.selectedTime =
        TimeOfDay.fromDateTime(dateTime);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BranchLocationConfirmPage(
          booking: widget.booking,
          onLanguageChange: widget.onLanguageChange,
        ),
      ),
    );
  }

  // ===============================
  // 🧱 UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('Select Branch & Time'),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                t.translate('No branches available'),
              ),
            );
          }

          final locations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final data =
                  location.data() as Map<String, dynamic>;

              final isExpanded =
                  expandedLocationId == location.id;

              final title =
                  '${data['city']} • ${data['area']}';
              final subtitle = data['street'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    // ================= BRANCH =================
                    ListTile(
                      leading: const Icon(Icons.store),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(subtitle),
                      trailing: Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      onTap: () {
                        setState(() {
                          expandedLocationId =
                              isExpanded
                                  ? null
                                  : location.id;
                        });
                      },
                    ),

                    // ================= TIME SLOTS =================
                    if (isExpanded)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('locations')
                            .doc(location.id)
                            .collection('timeSlots')
                            .orderBy('dateTime')
                            .snapshots(),
                        builder: (context, slotSnapshot) {
                          if (slotSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child:
                                  CircularProgressIndicator(),
                            );
                          }

                          if (!slotSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final now = DateTime.now();

                          final slots = slotSnapshot
                              .data!.docs
                              .where((doc) {
                                final d = doc.data()
                                    as Map<String, dynamic>;

                                // Must have dateTime
                                if (!d.containsKey(
                                    'dateTime')) {
                                  return false;
                                }

                                final ts =
                                    d['dateTime'];
                                if (ts is! Timestamp) {
                                  return false;
                                }

                                // Active defaults to true
                                final active =
                                    d['active'] ?? true;
                                if (!active) return false;

                                final dt =
                                    ts.toDate();

                                // Future only
                                return dt.isAfter(now);
                              })
                              .toList();

                          if (slots.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.all(16),
                              child: Text(
                                t.translate(
                                    'No available time slots'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: slots.map((slot) {
                              final d = slot.data()
                                  as Map<String, dynamic>;

                              final dateTime =
                                  (d['dateTime']
                                          as Timestamp)
                                      .toDate();

                              return ListTile(
                                leading: const Icon(
                                    Icons.event),
                                title: Text(
                                  displayFmt
                                      .format(dateTime),
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () =>
                                    _selectTimeSlot(
                                  location.id,
                                  dateTime,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}