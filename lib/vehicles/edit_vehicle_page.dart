import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_page_layout.dart';
import '../l10n/app_localizations.dart';

class EditVehiclePage extends StatefulWidget {
  final DocumentReference vehicleRef;
  final Map<String, dynamic> vehicle;
  final Function(Locale) onLanguageChange;

  const EditVehiclePage({
    super.key,
    required this.vehicleRef,
    required this.vehicle,
    required this.onLanguageChange,
  });

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  late TextEditingController year;
  late TextEditingController plate;

  @override
  void initState() {
    super.initState();
    year = TextEditingController(text: widget.vehicle['year']);
    plate = TextEditingController(text: widget.vehicle['plate']);
  }

  Future<void> _save() async {
    await widget.vehicleRef.update({
      'year': year.text.trim(),
      'plate': plate.text.trim(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppPageLayout(
      title: t.translate('edit_vehicle'),
      actions: [_languageMenu()],
      child: Column(
        children: [
          TextField(
            controller: year,
            decoration:
                InputDecoration(labelText: t.translate('car_year')),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: plate,
            decoration:
                InputDecoration(labelText: t.translate('plate')),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _save,
            child: Text(t.translate('save')),
          ),
        ],
      ),
    );
  }

  Widget _languageMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (v) {
        widget.onLanguageChange(
          v == 'en' ? const Locale('en') : const Locale('ar'),
        );
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'en', child: Text('English')),
        PopupMenuItem(value: 'ar', child: Text('العربية')),
      ],
    );
  }
}