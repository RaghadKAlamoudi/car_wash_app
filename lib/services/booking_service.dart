import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'canceled',
      'updatedAt': Timestamp.now(),
    });
  }

  static Future<void> rescheduleBooking(
    String bookingId,
    DateTime newDate,
  ) async {
    await _db.collection('bookings').doc(bookingId).update({
      'date': Timestamp.fromDate(newDate),
      'status': 'upcoming',
      'updatedAt': Timestamp.now(),
    });
  }
}

