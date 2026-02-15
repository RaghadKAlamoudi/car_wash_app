import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'service_form_page.dart';
import '../widgets/admin_drawer.dart';

class AdminServicesPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const AdminServicesPage({
    super.key,
    required this.onLanguageChange,
  });

  // ================= DELETE =================

  void _confirmDelete(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
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

  // ================= HELPERS =================

  String _washTypeLabel(String type) {
    switch (type) {
      case 'basic':
        return 'BASIC WASH';
      case 'full':
        return 'FULL WASH';
      case 'deep':
        return 'DEEP WASH';
      default:
        return 'WASH';
    }
  }

  String _locationLabel(List types) {
    final hasAdmin = types.contains('admin_location');
    final hasUser = types.contains('user_location');

    if (hasAdmin && hasUser) return 'BRANCH & CUSTOMER';
    if (hasAdmin) return 'CAR WASH BRANCH';
    if (hasUser) return 'CUSTOMER LOCATION';
    return 'NOT SET';
  }

  Color _locationColor(List types) {
    final hasAdmin = types.contains('admin_location');
    final hasUser = types.contains('user_location');

    if (hasAdmin && hasUser) return Colors.purple;
    if (hasAdmin) return Colors.blue;
    if (hasUser) return Colors.green;
    return Colors.grey;
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      drawer: AdminDrawer(onLanguageChange: onLanguageChange),
      appBar: AppBar(
        title: const Text('Manage Services'),
        elevation: 0,
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No services found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed Service';
              final washType = data['washType'] ?? '';
              final price = data['price'] ?? 0;
              final List locationTypes =
                  (data['serviceLocationTypes'] ?? []) as List;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= ICON =================
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ================= INFO =================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_washTypeLabel(washType)}  •  $price SAR',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _locationLabel(locationTypes),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _locationColor(locationTypes),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= ACTIONS =================
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServiceFormPage(serviceDoc: doc),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDelete(context, doc),
                        ),
                      ],
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