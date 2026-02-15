import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

class PaymentHistoryPage extends StatelessWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback onBack;

  const PaymentHistoryPage({
    super.key,
    required this.onLanguageChange,
    required this.onBack,
  });

  String _methodLabel(String method) {
    switch (method) {
      case 'credit_card':
        return 'Credit Card';
      case 'apple_pay':
        return 'Apple Pay';
      case 'cash':
      case 'pay_on_site':
        return 'Pay on Site';
      default:
        return '—';
    }
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card;
      case 'apple_pay':
        return Icons.apple;
      case 'cash':
      case 'pay_on_site':
        return Icons.payments;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A18),
        foregroundColor: Colors.white,
        title: Text(t.translate('payment')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'completed')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No payment history yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final method = data['paymentMethod'] ?? '';
              final price = data['totalPrice'] ?? 0;
              final date = (data['date'] as Timestamp).toDate();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF5F5F5),
                      child: Icon(
                        _methodIcon(method),
                        color: const Color(0xFFFF7A18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _methodLabel(method),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy • hh:mm a').format(date),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$price SAR',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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