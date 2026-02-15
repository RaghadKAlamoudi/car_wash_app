import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceFormPage extends StatefulWidget {
  final DocumentSnapshot? serviceDoc;

  const ServiceFormPage({
    super.key,
    this.serviceDoc,
  });

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  bool saving = false;

  final Map<String, String> washTypes = const {
    'basic': 'Basic Wash',
    'full': 'Full Wash',
    'deep': 'Deep Wash',
  };

  String? selectedWashType;

  /// ✅ ALWAYS AT LEAST ONE LOCATION
  final Set<String> _locationTypes = {
    'admin_location',
    'user_location',
  };

  /// Required only for admin_location
  String? selectedLocationId;

  @override
  void initState() {
    super.initState();

    if (widget.serviceDoc != null) {
      final data = widget.serviceDoc!.data() as Map<String, dynamic>;

      nameController.text = data['name'] ?? '';
      priceController.text = data['price']?.toString() ?? '';
      descriptionController.text = data['description'] ?? '';
      selectedWashType = data['washType'];

      final List types = (data['serviceLocationTypes'] ?? []);

      if (types.isEmpty) {
        _locationTypes
          ..clear()
          ..addAll(['admin_location', 'user_location']);
      } else {
        _locationTypes
          ..clear()
          ..addAll(types.cast<String>());
      }

      selectedLocationId = data['locationId'];
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveService() async {
    if (saving) return;

    if (_locationTypes.isEmpty) {
      _locationTypes.add('user_location');
    }

    if (selectedWashType == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        (_locationTypes.contains('admin_location') &&
            selectedLocationId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final data = {
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text),
        'description': descriptionController.text.trim(),
        'washType': selectedWashType,
        'serviceLocationTypes': _locationTypes.toList(),
        'locationId':
            _locationTypes.contains('admin_location')
                ? selectedLocationId
                : null,
        'active': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.serviceDoc == null) {
        await FirebaseFirestore.instance
            .collection('services')
            .add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await widget.serviceDoc!.reference.update(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving service: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.serviceDoc == null ? 'Add Service' : 'Edit Service',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1️⃣ WASH TYPE
            DropdownButtonFormField<String>(
              initialValue: selectedWashType,
              decoration: InputDecoration(
                labelText: 'Wash Type *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: washTypes.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: saving
                  ? null
                  : (v) =>
                      setState(() => selectedWashType = v),
            ),

            const SizedBox(height: 16),

            // 2️⃣ LOCATION CHECKBOXES
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Car Wash Branch'),
              subtitle:
                  const Text('Customer comes to the car wash'),
              value:
                  _locationTypes.contains('admin_location'),
              onChanged: saving
                  ? null
                  : (v) => setState(() {
                        if (v == true) {
                          _locationTypes
                              .add('admin_location');
                        } else if (_locationTypes.length >
                            1) {
                          _locationTypes
                              .remove('admin_location');
                          selectedLocationId = null;
                        }
                      }),
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Customer Location'),
              subtitle:
                  const Text('Service goes to the customer'),
              value:
                  _locationTypes.contains('user_location'),
              onChanged: saving
                  ? null
                  : (v) => setState(() {
                        if (v == true) {
                          _locationTypes
                              .add('user_location');
                        } else if (_locationTypes.length >
                            1) {
                          _locationTypes
                              .remove('user_location');
                        }
                      }),
            ),

            // 3️⃣ LOCATION DROPDOWN
            if (_locationTypes.contains('admin_location')) ...[
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('locations')
                    .where('active', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: selectedLocationId,
                    decoration: InputDecoration(
                      labelText: 'Car Wash Location *',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    items: snapshot.data!.docs.map((doc) {
                      final d =
                          doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(
                          '${d['city']} • ${d['area']}',
                        ),
                      );
                    }).toList(),
                    onChanged: saving
                        ? null
                        : (v) => setState(
                              () => selectedLocationId = v,
                            ),
                  );
                },
              ),
            ],

            const SizedBox(height: 20),

            // 4️⃣ SERVICE NAME
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Service Name *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              enabled: !saving,
            ),

            const SizedBox(height: 16),

            // 5️⃣ PRICE
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (SAR) *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              enabled: !saving,
            ),

            const SizedBox(height: 16),

            // 6️⃣ DESCRIPTION
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              enabled: !saving,
            ),

            const SizedBox(height: 28),

            // 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: saving ? null : saveService,
                child: saving
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                    : const Text(
                        'Save Service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}