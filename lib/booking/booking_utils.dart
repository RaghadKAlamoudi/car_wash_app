import 'package:cloud_firestore/cloud_firestore.dart';

Future<Set<String>> getBookedSlots({
  required String locationId,
  required DateTime date,
}) async {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));

  final snap = await FirebaseFirestore.instance
      .collection('bookings')
      .where('locationId', isEqualTo: locationId)
      .where('status', isEqualTo: 'upcoming')
      .where('dateTime', isGreaterThanOrEqualTo: start)
      .where('dateTime', isLessThan: end)
      .get();

  final Set<String> booked = {};

  for (final doc in snap.docs) {
    final data = doc.data();
    final time = data['selectedTime'];

    if (time != null) {
      booked.add(
        '${time['hour'].toString().padLeft(2, '0')}:'
        '${time['minute'].toString().padLeft(2, '0')}',
      );
    }
  }

  return booked;
}