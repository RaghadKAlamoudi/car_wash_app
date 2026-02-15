import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminTimeSlotsPage extends StatefulWidget {
  final String locationId;
  final String locationName;

  const AdminTimeSlotsPage({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<AdminTimeSlotsPage> createState() =>
      _AdminTimeSlotsPageState();
}

class _AdminTimeSlotsPageState extends State<AdminTimeSlotsPage> {
  bool saving = false;

  final DateFormat dateFmt = DateFormat('yyyy-MM-dd');
  final DateFormat timeFmt = DateFormat('HH:mm');

  // ================= ADD DATE + TIME SLOT =================

  Future<void> _addTimeSlot() async {
    // 📅 Pick date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    // ⏰ Pick time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null) return;

    final date = dateFmt.format(pickedDate);
    final time =
        '${pickedTime.hour.toString().padLeft(2, '0')}:'
        '${pickedTime.minute.toString().padLeft(2, '0')}';

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() => saving = true);

    try {
      // 🚫 Prevent duplicate date + time
      final exists = await FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.locationId)
          .collection('timeSlots')
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: time)
          .limit(1)
          .get();

      if (exists.docs.isNotEmpty) {
        _showError('This date & time already exists');
        setState(() => saving = false);
        return;
      }

      await FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.locationId)
          .collection('timeSlots')
          .add({
        'date': date, // yyyy-MM-dd
        'time': time, // HH:mm
        'dateTime': Timestamp.fromDate(dateTime),
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _showError('Failed to add time slot');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // ================= DELETE =================

  void _confirmDelete(String slotId, String label) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Time Slot'),
        content: Text('Delete $label ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('locations')
                  .doc(widget.locationId)
                  .collection('timeSlots')
                  .doc(slotId)
                  .delete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Time Slots'),
            Text(
              widget.locationName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: saving ? null : _addTimeSlot,
        child: saving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .doc(widget.locationId)
            .collection('timeSlots')
            .orderBy('dateTime')
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
            return const Center(
              child: Text(
                'No time slots yet.\nTap + to add.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data =
                  doc.data() as Map<String, dynamic>;

              final date = data['date'];
              final time = data['time'];
              final label = '$date • $time';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(date),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        _confirmDelete(doc.id, label),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ================= HELPERS =================

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}