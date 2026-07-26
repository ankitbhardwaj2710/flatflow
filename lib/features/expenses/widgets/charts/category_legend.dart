import 'package:flutter/material.dart';

import '../../utils/chart_colors.dart';

class CategoryLegend extends StatelessWidget {
  final Map<String, double> categories;

  const CategoryLegend({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox();
    }

    final entries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return Column(
      children: List.generate(entries.length, (index) {
        final entry = entries[index];

        final percentage =
            total == 0 ? 0 : (entry.value / total) * 100;

        final color =
            ChartColors.colors[index % ChartColors.colors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.30),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor:
                      Colors.grey.withOpacity(.15),
                  valueColor:
                      AlwaysStoppedAnimation(color),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Spacer(),
                  Text(
                    '₹${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}