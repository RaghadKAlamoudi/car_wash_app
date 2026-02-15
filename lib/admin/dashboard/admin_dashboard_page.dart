import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/admin_drawer.dart';
import '../services/admin_services_page.dart';
import '../bookings/admin_bookings_page.dart';
import '../users/admin_users_page.dart';
import '../locations/admin_locations_page.dart';
import 'admin_activity_history_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final Function(Locale) onLanguageChange;

  const AdminDashboardPage({
    super.key,
    required this.onLanguageChange,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // ================= HELPERS =================

  final Map<String, String> _userNameCache = {};

  Future<String> _resolveUserName(String userId) async {
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final name = doc.data()?['name'] ?? 'User';
    _userNameCache[userId] = name;
    return name;
  }

  Stream<QuerySnapshot> _latestBookings() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .snapshots();
  }

  Future<int> _count(String collection) async {
    final snap =
        await FirebaseFirestore.instance.collection(collection).get();
    return snap.docs.length;
  }

  // ================= 🔥 FIXED REVENUE CALCULATION =================
  // Revenue is calculated ONLY from what the user actually PAID
 Future<int> _totalRevenue() async {
  final snap =
      await FirebaseFirestore.instance.collection('bookings').get();

  double total = 0;

  for (final doc in snap.docs) {
    final data = doc.data();

    // OPTIONAL but recommended: count only completed bookings
    if (data['status'] != 'completed') continue;

    dynamic rawAmount =
        data['paidAmount'] ??
        data['amountPaid'] ??
        data['totalAmount'] ??
        data['price'];

    if (rawAmount == null) continue;

    // Handle ALL cases safely
    if (rawAmount is int) {
      total += rawAmount.toDouble();
    } else if (rawAmount is double) {
      total += rawAmount;
    } else if (rawAmount is String) {
      total += double.tryParse(rawAmount) ?? 0;
    }
  }

  return total.round();
}

  Color _statusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      drawer: AdminDrawer(onLanguageChange: widget.onLanguageChange),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= TOP STATS =================
            Row(
              children: [
                FutureBuilder<int>(
                  future: _totalRevenue(),
                  builder: (_, snap) => _StatCard(
                    title: 'Revenue',
                    value: snap.hasData ? '${snap.data} SAR' : '—',
                    change: '',
                    changeColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                FutureBuilder<int>(
                  future: _count('bookings'),
                  builder: (_, snap) => _StatCard(
                    title: 'Bookings',
                    value: snap.hasData ? snap.data.toString() : '—',
                    change: '',
                    changeColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                FutureBuilder<int>(
                  future: _count('users'),
                  builder: (_, snap) => _StatCard(
                    title: 'Customers',
                    value: snap.hasData ? snap.data.toString() : '—',
                    change: '',
                    changeColor: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// ================= CORE MANAGEMENT =================
            const Text(
              'CORE MANAGEMENT',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.4,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _ManagementCard(
                  title: 'Services',
                  subtitle: 'Manage',
                  icon: Icons.local_car_wash,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminServicesPage(
                        onLanguageChange: widget.onLanguageChange,
                      ),
                    ),
                  ),
                ),
                _ManagementCard(
                  title: 'Locations',
                  subtitle: 'Manage',
                  icon: Icons.location_on,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminLocationsPage(),
                    ),
                  ),
                ),
                _ManagementCard(
                  title: 'Bookings',
                  subtitle: 'View All',
                  icon: Icons.calendar_month,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminBookingsPage(
                        onLanguageChange: widget.onLanguageChange,
                      ),
                    ),
                  ),
                ),
                _ManagementCard(
                  title: 'Users',
                  subtitle: 'View All',
                  icon: Icons.people,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminUsersPage(
                        onLanguageChange: widget.onLanguageChange,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// ================= LIVE ACTIVITY =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LIVE ACTIVITY',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminActivityHistoryPage(),
                    ),
                  ),
                  child: const Text(
                    'VIEW HISTORY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔥 LIVE DATA ONLY (NO DEMO)
            StreamBuilder<QuerySnapshot>(
              stream: _latestBookings(),
              builder: (_, snap) {
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Column(
                  children: snap.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final userId = data['userId'];

                    return FutureBuilder<String>(
                      future: userId != null
                          ? _resolveUserName(userId)
                          : Future.value('User'),
                      builder: (_, nameSnap) {
                        final name = nameSnap.data ?? 'User';

                        return _ActivityTile(
                          initial: name[0].toUpperCase(),
                          name: name,
                          service: data['serviceName'] ?? 'Service',
                          time: 'Recently',
                          status:
                              (data['status'] ?? 'PENDING').toUpperCase(),
                          statusColor: _statusColor(data['status']),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// STAT CARD
////////////////////////////////////////////////////////////
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final Color changeColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(change,
                style: TextStyle(
                  fontSize: 12,
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// MANAGEMENT CARD
////////////////////////////////////////////////////////////
class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ACTIVITY TILE
////////////////////////////////////////////////////////////
class _ActivityTile extends StatelessWidget {
  final String initial;
  final String name;
  final String service;
  final String time;
  final String status;
  final Color statusColor;

  const _ActivityTile({
    required this.initial,
    required this.name,
    required this.service,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.orange.shade50,
            child: Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$service · $time',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}