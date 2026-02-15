import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../home/main_navigation.dart';
import '../l10n/app_localizations.dart';

class ConfirmationPage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const ConfirmationPage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool loading = true;
  String bookingId = '';

  @override
  void initState() {
    super.initState();
    _confirmBooking();
  }

  // ================= CONFIRM BOOKING =================

  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('bookings')
        .add({
      ...widget.booking.toMap(),

      // 🔐 SYSTEM FIELDS
      'userId': user.uid,
      'status': 'upcoming',
      'createdAt': Timestamp.now(),
      'date': Timestamp.fromDate(widget.booking.dateTime),

      // 💰 PRICE (SOURCE OF TRUTH)
      'totalPrice': widget.booking.totalPrice,
    });

    bookingId = doc.id;

    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    // ✅ PRICE FROM BOOKING ONLY
    final int totalPrice = widget.booking.totalPrice;

    assert(
      totalPrice > 0,
      'ERROR: totalPrice must be set before ConfirmationPage',
    );

    final String serviceName =
        widget.booking.serviceName.isNotEmpty
            ? widget.booking.serviceName
            : widget.booking.washType;

    return AppPageLayout(
      showBack: false,
      title: '',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ✅ SUCCESS ICON
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Wash Confirmed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'YOUR CAR IS ABOUT TO GET GLOW CAR TREATMENT.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= DETAILS CARD =================
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          'BOOKING ID',
                          bookingId.substring(0, 10),
                        ),
                        const Divider(height: 24),

                        _iconInfo(
                          Icons.local_car_wash,
                          'SERVICE',
                          serviceName,
                        ),
                        const SizedBox(height: 16),

                        _iconInfo(
                          Icons.calendar_today,
                          'SCHEDULED FOR',
                          _formatDate(widget.booking.dateTime),
                          sub: _formatTime(widget.booking.dateTime),
                        ),

                        const Divider(height: 24),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL PAID',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.green.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'SUCCESS',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$totalPrice SAR',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= CTA =================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFF7A00),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => MainNavigation(
                                onLanguageChange:
                                    widget.onLanguageChange,
                              ),
                            ),
                            (_) => false,
                          );
                        },
                        child: const Text(
                          'Back to Home Page',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= HELPERS =================

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _iconInfo(
    IconData icon,
    String label,
    String value, {
    String? sub,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (sub != null)
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${_weekday(d.weekday)}, ${_month(d.month)} ${d.day}';

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _weekday(int i) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1];

  String _month(int i) =>
      [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][i - 1];
}