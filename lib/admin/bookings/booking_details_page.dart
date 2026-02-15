import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailsPage extends StatefulWidget {
  final DocumentSnapshot booking;

  const BookingDetailsPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late String status;

  final List<String> statuses = const [
    'upcoming',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    final rawStatus = widget.booking['status'] ?? 'upcoming';
    status = statuses.contains(rawStatus) ? rawStatus : 'upcoming';
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => status = newStatus);

    await widget.booking.reference.update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ================= CUSTOMER =================
  Widget _customerSection(Map<String, dynamic> data) {
    final storedName = data['customerName'];
    final storedEmail = data['customerEmail'];

    if (storedName != null || storedEmail != null) {
      return _centerInfo('CUSTOMER', storedName ?? storedEmail);
    }

    final userId = data['userId'];
    if (userId == null) {
      return _centerInfo('CUSTOMER', 'Unknown');
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _centerInfo('CUSTOMER', 'Unknown');
        }

        final userData =
            snapshot.data!.data() as Map<String, dynamic>;

        return _centerInfo(
          'CUSTOMER',
          userData['name'] ??
              userData['email'] ??
              'Unknown',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.booking.data() as Map<String, dynamic>;

    // ✅ SERVICE NAME FROM DB
    final String serviceName =
        (data['serviceName'] ??
         data['washType'] ??
         'Service').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 32,
        ),
        child: Column(
          children: [
            // ================= BOOKING INFO =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _centerInfo(
                    'BOOKING ID',
                    widget.booking.id,
                  ),
                  const SizedBox(height: 20),

                  _customerSection(data),
                  const SizedBox(height: 20),

                  _centerInfo(
                    'SERVICE',
                    serviceName,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ================= STATUS =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: status,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                      ),
                      items: statuses.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(s),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _updateStatus(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CENTER INFO =================
  Widget _centerInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.6,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}