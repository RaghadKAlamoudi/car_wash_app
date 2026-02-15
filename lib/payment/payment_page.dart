import 'package:flutter/material.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../booking/confirmation_page.dart';
import '../l10n/app_localizations.dart';

class PaymentPage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;

  const PaymentPage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;

  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  void _confirmAndPay() {
    if (selectedMethod == null) return;

    widget.booking.paymentMethod = selectedMethod!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationPage(
          booking: widget.booking,
          onLanguageChange: widget.onLanguageChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('payment'),
      showBack: true,
      child: Column(
        children: [
          const SizedBox(height: 16),

          _paymentOption(
            title: t.translate('Credit Card'),
            icon: Icons.credit_card,
            value: 'card',
          ),
          const SizedBox(height: 16),

          _paymentOption(
            title: t.translate('Apple Pay'),
            icon: Icons.apple,
            value: 'apple_pay',
          ),
          const SizedBox(height: 16),

          _paymentOption(
            title: t.translate('Pay On Site'),
            icon: Icons.payments,
            value: 'cash',
          ),

          const SizedBox(height: 24),

          /// 💳 CARD FORM (ONLY FOR CREDIT CARD)
          if (selectedMethod == 'card') _cardForm(),

          const Spacer(),

          ElevatedButton(
            onPressed: selectedMethod == null ? null : _confirmAndPay,
            child: Text(t.translate('confirm_and_pay')),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================= PAYMENT OPTION =================

  Widget _paymentOption({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedMethod == value;

    return Material(
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.12)
          : const Color(0xFFF3F3F3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => selectedMethod = value);
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CARD FORM =================

  Widget _cardForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Card Holder Name'),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. JOHN ALI',
            ),
          ),

          const SizedBox(height: 16),

          const Text('Card Number'),
          const SizedBox(height: 8),
          TextField(
            controller: numberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '0000 0000 0000 0000',
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expiry'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: expiryController,
                      decoration:
                          const InputDecoration(hintText: 'MM/YY'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CVV'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cvvController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(hintText: '***'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}