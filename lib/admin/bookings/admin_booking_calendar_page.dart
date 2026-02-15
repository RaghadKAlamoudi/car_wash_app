import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingCalendarPage extends StatefulWidget {
  const AdminBookingCalendarPage({super.key});

  @override
  State<AdminBookingCalendarPage> createState() =>
      _AdminBookingCalendarPageState();
}

class _AdminBookingCalendarPageState
    extends State<AdminBookingCalendarPage> {
  DateTime selectedDate = DateTime.now();

  // ================= DATE PICKER =================

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 60),
      ),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  // ================= QUERY =================

  Query _bookingQuery() {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('bookings')
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: start,
        )
        .where(
          'dateTime',
          isLessThan: end,
        )
        .orderBy('dateTime');
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),

      body: Column(
        children: [
          // ================= DATE HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Text(
              DateFormat('EEEE, dd MMM yyyy')
                  .format(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ================= BOOKINGS =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _bookingQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No bookings for this day',
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    final time =
                        data['selectedTime'] != null
                            ? '${data['selectedTime']['hour']
                                .toString()
                                .padLeft(2, '0')}:'
                              '${data['selectedTime']['minute']
                                .toString()
                                .padLeft(2, '0')}'
                            : '—';

                    final status = data['status'] ?? 'upcoming';

                    Color statusColor = status == 'completed'
                        ? Colors.green
                        : status == 'canceled'
                            ? Colors.red
                            : Colors.blue;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              statusColor.withOpacity(0.15),
                          child: Icon(
                            Icons.schedule,
                            color: statusColor,
                          ),
                        ),

                        title: Text(
                          '$time • ${data['washType']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              data['address'] ?? '',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}