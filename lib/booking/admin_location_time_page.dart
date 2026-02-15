import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/services/service_form_page.dart';
import '../admin/widgets/admin_drawer.dart';
import '../l10n/app_localizations.dart';

class AdminLocationTimePage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const AdminLocationTimePage({
    super.key,
    required this.onLanguageChange,
  });

  // ================= HELPERS =================

  List<String> _normalizeLocationTypes(Map<String, dynamic> data) {
    if (data['serviceLocationTypes'] is List) {
      return List<String>.from(data['serviceLocationTypes']);
    }

    final old = data['serviceLocationType'];
    if (old == 'admin_location') return ['admin_location'];
    if (old == 'user_location') return ['user_location'];

    return [];
  }

  String _locationLabel(List<String> types) {
    final hasAdmin = types.contains('admin_location');
    final hasUser = types.contains('user_location');

    if (hasAdmin && hasUser) return 'Branch & Customer';
    if (hasAdmin) return 'Car Wash Branch';
    if (hasUser) return 'Customer Location';
    return 'Not Set';
  }

  Color _locationColor(List<String> types) {
    if (types.contains('admin_location') &&
        types.contains('user_location')) {
      return Colors.purple;
    }
    if (types.contains('admin_location')) return Colors.blue;
    if (types.contains('user_location')) return Colors.green;
    return Colors.grey;
  }

  // ================= DELETE =================

  void _confirmDelete(
    BuildContext context,
    DocumentSnapshot doc,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text(
          'Are you sure you want to delete this service?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await doc.reference.delete();
              Navigator.pop(context);
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
    final t = AppLocalizations.of(context);

    return Scaffold(
      drawer: AdminDrawer(
        onLanguageChange: onLanguageChange,
      ),
      appBar: AppBar(
        title: Text(t.translate('Manage Services')),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ServiceFormPage(),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .orderBy('createdAt', descending: true)
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
                t.translate('No services found'),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              final locationTypes =
                  _normalizeLocationTypes(data);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(
                    data['name'] ?? 'Unnamed Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _locationLabel(locationTypes),
                    style: TextStyle(
                      color: _locationColor(locationTypes),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        _confirmDelete(context, doc),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}