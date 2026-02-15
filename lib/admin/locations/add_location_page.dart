import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddLocationPage extends StatefulWidget {
  final QueryDocumentSnapshot? editDoc;

  const AddLocationPage({
    super.key,
    this.editDoc,
  });

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final _formKey = GlobalKey<FormState>();

  final cityCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();

    // ✏️ Prefill when editing
    if (widget.editDoc != null) {
      final data = widget.editDoc!.data() as Map<String, dynamic>;
      cityCtrl.text = data['city'] ?? '';
      areaCtrl.text = data['area'] ?? '';
      streetCtrl.text = data['street'] ?? '';
      notesCtrl.text = data['notes'] ?? '';
      latCtrl.text = data['lat']?.toString() ?? '';
      lngCtrl.text = data['lng']?.toString() ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final city = cityCtrl.text.trim();
      final area = areaCtrl.text.trim();
      final street = streetCtrl.text.trim();
      final notes = notesCtrl.text.trim();
      final lat = double.parse(latCtrl.text);
      final lng = double.parse(lngCtrl.text);

      // Stable document ID
      final docId = [city, area]
          .where((e) => e.isNotEmpty)
          .join('_')
          .toLowerCase()
          .replaceAll(' ', '_');

      final data = {
        'city': city,
        'area': area,
        'street': street,
        'notes': notes,
        'lat': lat,
        'lng': lng,
        'active': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.editDoc == null) {
        // ➕ ADD
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(docId)
            .set(data);
      } else {
        // ✏️ EDIT
        await widget.editDoc!.reference.update(data);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editDoc != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Location' : 'Add Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // CITY
              TextFormField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'City *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 12),

              // AREA
              TextFormField(
                controller: areaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Area / District'),
              ),
              const SizedBox(height: 12),

              // STREET
              TextFormField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: 'Street'),
              ),
              const SizedBox(height: 12),

              // LATITUDE
              TextFormField(
                controller: latCtrl,
                decoration: const InputDecoration(
                  labelText: 'Latitude *',
                  hintText: 'e.g. 21.5756',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Latitude is required';
                  }
                  if (double.tryParse(v) == null) {
                    return 'Invalid latitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // LONGITUDE
              TextFormField(
                controller: lngCtrl,
                decoration: const InputDecoration(
                  labelText: 'Longitude *',
                  hintText: 'e.g. 39.1817',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Longitude is required';
                  }
                  if (double.tryParse(v) == null) {
                    return 'Invalid longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // NOTES
              TextFormField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 24),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEdit ? 'Save Changes' : 'Add Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}