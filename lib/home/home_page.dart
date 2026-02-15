import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth_gate.dart';
import '../location/location_page.dart';
import '../location/customer_location_time_page.dart';
import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/safe_text.dart';
import '../l10n/app_localizations.dart';
import '../profile/coupons_page.dart';
import '../appointments/appointments_page.dart';

class HomePage extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback onProfileTap;
  final VoidCallback onVehiclesTap;

  const HomePage({
    super.key,
    required this.onLanguageChange,
    required this.onProfileTap,
    required this.onVehiclesTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showAllServices = false;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoCompleteOldBookings();
    });
  }

  Future<void> _autoCompleteOldBookings() async {
    final user = FirebaseAuth.instance.currentUser!;
    final now = Timestamp.now();

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'upcoming')
        .where('date', isLessThan: now)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'status': 'completed'});
    }
  }
      final bool _showAllUpcoming = false;
      final bool _showAllPast = false;

  // ================= SERVICE NAME RESOLVER =================
  /// Fixes old bookings with missing serviceName / washType
  String resolveServiceName(
    Map<String, dynamic> data,
    AppLocalizations t,
  ) {
    final serviceName = data['serviceName'];
    final washType = data['washType'];

    if (serviceName is String && serviceName.trim().isNotEmpty) {
      return serviceName;
    }

    if (washType is String && washType.trim().isNotEmpty) {
      return washType;
    }

    return t.translate('Car Wash Service');
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('home'),
      showBack: false,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (value) {
            widget.onLanguageChange(
              value == 'en' ? const Locale('en') : const Locale('ar'),
            );
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'en', child: Text('English')),
            PopupMenuItem(value: 'ar', child: Text('العربية')),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AuthGate(onLanguageChange: widget.onLanguageChange),
              ),
              (_) => false,
            );
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(user, t, widget.onProfileTap),
          const SizedBox(height: 24),

          _offerSection(t, widget.onLanguageChange),
          const SizedBox(height: 24),

          _aboutUsSection(context, t),
          const SizedBox(height: 32),

          _services(context, t, widget.onLanguageChange),
          const SizedBox(height: 32),

        
        _checkAppointmentsButton(
          context,
          t,
          widget.onLanguageChange,
        ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }


  // ================= HEADER =================
Widget _header(
  User user,
  AppLocalizations t,
  VoidCallback onProfileTap,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${t.translate('hello')} ${user.email?.split('@').first ?? ''} 👋',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.translate('take_care'),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
      GestureDetector(
        onTap: onProfileTap,
        child: CircleAvatar(
          radius: 22,
          backgroundColor:
              Theme.of(context).primaryColor.withOpacity(0.15),
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    ],
  );
}

// ================= OFFER =================

Widget _offerSection(
  AppLocalizations t,
  Function(Locale) onLanguageChange,
) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PromoCodesPage(
            onLanguageChange: onLanguageChange,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeText(
                  t.translate('special_offer'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.translate('Get up to 20% off on your first wash'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.local_offer,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    ),
  );
}
 // ================= ABOUT =================

Widget _aboutUsSection(
  BuildContext context,
  AppLocalizations t,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.info,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.translate('about_us'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.translate(
                  'Professional car wash services delivered to your location using high-quality products and trusted teams.',
                ),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


/// ================= SERVICES =================

IconData _washIcon(String washType) {
  switch (washType.toLowerCase()) {
    case 'basic':
    case 'basic wash':
      return Icons.local_car_wash;        // 🧼 Basic
    case 'full':
    case 'full wash':
      return Icons.directions_car_filled; // 🚗 Full
    case 'deep':
    case 'deep wash':
      return Icons.cleaning_services;     // 🧽 Deep
    default:
      return Icons.local_car_wash;
  }
}

Widget _services(
  BuildContext context,
  AppLocalizations t,
  Function(Locale) onLanguageChange,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// 🔹 TITLE + VIEW MORE
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t.translate('Car Wash Services'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _showAllServices = !_showAllServices;
              });
            },
            child: Text(
              _showAllServices
                  ? t.translate('View less')
                  : t.translate('View more'),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text(
              t.translate('no_services'),
              style: const TextStyle(color: Colors.grey),
            );
          }

          final allServices = snapshot.data!.docs;

          final visibleServices = _showAllServices
              ? allServices
              : allServices.take(4).toList();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleServices.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (_, i) {
              return _serviceCard(
                context,
                visibleServices[i],
                t,
                onLanguageChange,
              );
            },
          );
        },
      ),
    ],
  );
}

Widget _serviceCard(
  BuildContext context,
  QueryDocumentSnapshot service,
  AppLocalizations t,
  Function(Locale) onLanguageChange,
) {
  final data = service.data() as Map<String, dynamic>;

  final String serviceName =
      (data['name'] ?? 'Service').toString();

  final String washType =
      (data['washType'] ?? 'basic')
          .toString()
          .toLowerCase();

  /// 📍 LOCATION TYPES
  final List rawTypes =
      (data['serviceLocationTypes'] ?? []) as List;

  final List<String> locationTypes =
      rawTypes.whereType<String>().toList();

  final bool hasAdmin =
      locationTypes.isEmpty ||
      locationTypes.contains('admin_location');

  final bool hasUser =
      locationTypes.isEmpty ||
      locationTypes.contains('user_location');

  /// 💰 PRICE FROM DATABASE
  final int price =
      (data['price'] is num)
          ? (data['price'] as num).round()
          : 0;

  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      // ✅ CREATE BOOKING WITH PRICE + NAME
      final booking = BookingDraft()
        ..serviceId = service.id
        ..serviceName = serviceName
        ..washType = washType
        ..totalPrice = price; // 🔥 THIS FIXES EVERYTHING

      // 🛑 SAFETY (optional)
      assert(
        booking.totalPrice > 0,
        'Service price must be > 0',
      );

      // ================= LOCATION FLOW =================

      if (hasAdmin && hasUser) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.store),
                title: Text(t.translate('At our car wash')),
                onTap: () {
                  booking.serviceType = 'admin_location';
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerLocationTimePage(
                        booking: booking,
                        onLanguageChange: onLanguageChange,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(t.translate('At your location')),
                onTap: () {
                  booking.serviceType = 'user_location';
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationPage(
                        booking: booking,
                        onLanguageChange: onLanguageChange,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
        return;
      }

      if (hasAdmin) {
        booking.serviceType = 'admin_location';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerLocationTimePage(
              booking: booking,
              onLanguageChange: onLanguageChange,
            ),
          ),
        );
        return;
      }

      if (hasUser) {
        booking.serviceType = 'user_location';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LocationPage(
              booking: booking,
              onLanguageChange: onLanguageChange,
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('Service is not available')),
        ),
      );
    },

    // ================= UI =================
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _washIcon(washType),
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            serviceName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '$price SAR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            hasAdmin && hasUser
                ? t.translate('At our car wash & your location')
                : hasAdmin
                    ? t.translate('At our car wash')
                    : t.translate('At your location'),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
/// ================= BUTTON =================

Widget _checkAppointmentsButton(
  BuildContext context,
  AppLocalizations t,
  Function(Locale) onLanguageChange,
) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AppointmentsPage(
            onLanguageChange: onLanguageChange,
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.translate('Check appointments'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    ),
  );
}
}