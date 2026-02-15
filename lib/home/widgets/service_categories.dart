import 'package:flutter/material.dart';

class ServiceCategories extends StatelessWidget {
  const ServiceCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Car Wash Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _ServiceItem('Classic'),
            _ServiceItem('External'),
            _ServiceItem('Premium'),
          ],
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String title;

  const _ServiceItem(this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_car_wash),
        ),
        const SizedBox(height: 8),
        Text(title),
      ],
    );
  }
}
