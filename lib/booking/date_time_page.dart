import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';
import '../payment/payment_page.dart';
import '../car/car_type_page.dart';
import '../car/car_flow_mode.dart';

class DateTimePage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const DateTimePage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  State<DateTimePage> createState() => _DateTimePageState();
}

class _DateTimePageState extends State<DateTimePage> {
  String? selectedVehicleId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final List<TimeOfDay> timeSlots = const [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
  ];

  bool get canContinue =>
      selectedVehicleId != null &&
      selectedDate != null &&
      selectedTime != null;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser!;

    return AppPageLayout(
      title: 'Car Shine',
      showBack: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (value) {
            widget.onLanguageChange(
              value == 'ar' ? const Locale('ar') : const Locale('en'),
            );
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'en', child: Text('English')),
            PopupMenuItem(value: 'ar', child: Text('العربية')),
          ],
        ),
      ],
      child: SafeArea(
        child: Column(
          children: [
            /// 🔹 SCROLLABLE CONTENT (FIXES OVERFLOW)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= VEHICLE =================
                    const Text(
                      'Vehicle',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('vehicles')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final vehicles = snapshot.data!.docs;

                        return Column(
                          children: [
                            ...vehicles.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;
                              final selected =
                                  selectedVehicleId == doc.id;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVehicleId = doc.id;
                                    widget.booking.vehicleId = doc.id;
                                    widget.booking.carBrand = data['brand'];
                                    widget.booking.carModel = data['model'];
                                    widget.booking.licensePlateEn =
                                        data['plateEn'];
                                    widget.booking.licensePlateAr =
                                        data['plateAr'];
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFFFF1D6)
                                        : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.directions_car),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${data['brand']} ${data['model']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            /// ➕ ADD VEHICLE
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarTypePage(
                                      booking: BookingDraft(),
                                      onLanguageChange:
                                          widget.onLanguageChange,
                                      mode: CarFlowMode.vehicleOnly,
                                      onFinished: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.orange),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add,
                                        color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add Vehicle',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ================= DATE =================
                    const Text(
                      'Date',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Spacer(),
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ================= TIME =================
                    const Text(
                      'Select Time',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: timeSlots.map((time) {
                        final selected = time == selectedTime;

                        return ChoiceChip(
                          label: Text(time.format(context)),
                          selected: selected,
                          selectedColor: Colors.orange.shade200,
                          backgroundColor:
                              const Color(0xFFF0F0F0),
                          onSelected: (_) {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 120), // 👈 space for button
                  ],
                ),
              ),
            ),

            /// 🔹 FIXED CONTINUE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canContinue ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canContinue
                        ? Colors.orange
                        : Colors.grey.shade300,
                    foregroundColor:
                        canContinue ? Colors.white : Colors.grey,
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        selectedTime = null;
      });
    }
  }

  void _continue() {
    widget.booking.dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    widget.booking.selectedTime = selectedTime;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          booking: widget.booking,
          onLanguageChange: widget.onLanguageChange,
        ),
      ),
    );
  }
}