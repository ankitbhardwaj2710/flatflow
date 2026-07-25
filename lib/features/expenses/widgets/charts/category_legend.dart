import 'package:flutter/material.dart';

class CategoryLegend extends StatelessWidget {
  final Map<String, double> categories;

  const CategoryLegend({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categories.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(entry.key),
              ),
              Text(
                '₹${entry.value.toStringAsFixed(2)}',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}