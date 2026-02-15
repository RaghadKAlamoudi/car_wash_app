import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_draft.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/error_snackbar.dart';
import '../l10n/app_localizations.dart';
import 'car_flow_mode.dart';

class CarDetailsPage extends StatefulWidget {
  final BookingDraft booking;
  final Function(Locale) onLanguageChange;
  final CarFlowMode mode;
  final VoidCallback? onFinished;

  const CarDetailsPage({
    super.key,
    required this.booking,
    required this.onLanguageChange,
    this.mode = CarFlowMode.booking,
    this.onFinished,
  });

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  final yearController = TextEditingController();

  // 🔥 NEW
  final carSearchController = TextEditingController();
  final plateLettersController = TextEditingController();
  final plateNumbersController = TextEditingController();

  String? selectedBrand;
  String? selectedModel;

  String plateEnPreview = '';
  String plateArPreview = '';

  // ================= CAR DATA =================

  final Map<String, List<String>> carData = {
    'Toyota': ['Corolla', 'Camry', 'Yaris', 'Land Cruiser', 'Prado', 'Hilux', 'RAV4'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe'],
    'Nissan': ['Sunny', 'Altima', 'Patrol', 'X-Trail'],
    'Kia': ['Cerato', 'Sportage', 'Sorento'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC'],
    'Audi': ['A3', 'A4', 'A6', 'Q5'],
    'Tesla': ['Model 3', 'Model Y', 'Model S'],
    'Other': ['Other'],
  };

  List<String> filteredBrands = [];

  @override
  void initState() {
    super.initState();
    filteredBrands = carData.keys.toList();
  }

  void _searchCar(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredBrands = carData.keys.where((brand) {
        if (brand.toLowerCase().contains(q)) return true;
        return carData[brand]!
            .any((model) => model.toLowerCase().contains(q));
      }).toList();
    });
  }

  // ================= SAUDI PLATE MAPPING =================

  static const Map<String, String> enToArLetters = {
    'A': 'أ','B': 'ب','J': 'ج','D': 'د','R': 'ر',
    'S': 'س','X': 'ص','T': 'ط','E': 'ع','G': 'ق',
    'K': 'ك','L': 'ل','M': 'م','N': 'ن','H': 'هـ',
    'W': 'و','Y': 'ي',
  };

  static const Map<String, String> enToArNumbers = {
    '0': '٠','1': '١','2': '٢','3': '٣','4': '٤',
    '5': '٥','6': '٦','7': '٧','8': '٨','9': '٩',
  };

  late final Map<String, String> arToEnLetters = {
    for (final e in enToArLetters.entries) e.value: e.key,
    'ى': 'Y',
  };

  late final Map<String, String> arToEnNumbers =
      enToArNumbers.map((k, v) => MapEntry(v, k));

  bool _containsArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  String normalizeEnPlate(String input) {
    return input
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '')
        .split('')
        .map((c) => c == 'U' ? 'W' : c == 'V' ? 'Y' : c)
        .join();
  }

  String arToEn(String input) {
    return normalizeEnPlate(
      input
          .replaceAll(RegExp(r'\s+'), '')
          .split('')
          .map((c) => arToEnLetters[c] ?? arToEnNumbers[c] ?? '')
          .join(),
    );
  }

  String enToAr(String input) {
    return input
        .split('')
        .map((c) => enToArLetters[c] ?? enToArNumbers[c] ?? '')
        .join(' ');
  }

  final RegExp englishPlate = RegExp(r'^[A-Z]{3}[0-9]{3,4}$');

  void _onPlateChangedCombined() {
    final combined =
        '${plateLettersController.text}${plateNumbersController.text}';

    if (combined.isEmpty) {
      setState(() {
        plateEnPreview = '';
        plateArPreview = '';
      });
      return;
    }

    final en =
        _containsArabic(combined) ? arToEn(combined) : normalizeEnPlate(combined);

    setState(() {
      plateEnPreview = en;
      plateArPreview = enToAr(en);
    });
  }

  // ================= SAVE =================

  Future<void> _continue() async {
    final t = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (selectedBrand == null ||
        selectedModel == null ||
        yearController.text.isEmpty ||
        plateEnPreview.isEmpty) {
      showError(context, t.translate('fill_all_fields'));
      return;
    }

    if (!englishPlate.hasMatch(plateEnPreview)) {
      showError(context, t.translate('invalid_plate'));
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vehicles')
        .add({
      'carType': widget.booking.carType,
      'brand': selectedBrand,
      'model': selectedModel,
      'year': yearController.text,
      'plateEn': plateEnPreview,
      'plateAr': plateArPreview,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return AppPageLayout(
      title: 'Details',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: carSearchController,
            onChanged: _searchCar,
            decoration: InputDecoration(
              hintText: 'Search brand or model',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),
          _label('VEHICLE BRAND'),
          _dropdown(
            hint: 'Select Brand',
            value: selectedBrand,
            items: filteredBrands,
            onChanged: (v) => setState(() {
              selectedBrand = v;
              selectedModel = null;
            }),
          ),

          const SizedBox(height: 16),
          _label('VEHICLE MODEL'),
          _dropdown(
            hint: 'Select Model',
            value: selectedModel,
            items: selectedBrand == null ? [] : carData[selectedBrand]!,
            onChanged: (v) => setState(() => selectedModel = v),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _textField('YEAR', yearController)),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  'PLATE LETTERS',
                  plateLettersController,
                  onChanged: (_) => _onPlateChangedCombined(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  'PLATE NUMBERS',
                  plateNumbersController,
                  onChanged: (_) => _onPlateChangedCombined(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _platePreview(),

          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _continue,
              icon: const Icon(Icons.check),
              label: const Text('Complete Registration'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      );

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _platePreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF1E4F91),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('K\nS\nA', style: TextStyle(color: Colors.white)),
                SizedBox(height: 8),
                Text('SA', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  plateEnPreview.isEmpty ? '— — —' : plateEnPreview,
                  style: const TextStyle(fontSize: 20, letterSpacing: 4),
                ),
                const SizedBox(height: 8),
                Text(plateArPreview.isEmpty ? '— — —' : plateArPreview),
              ],
            ),
          ),
        ],
      ),
    );
  }
}