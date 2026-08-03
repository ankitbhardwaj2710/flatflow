import 'package:flutter/material.dart';

import '../models/insight_model.dart';

class InsightCard extends StatelessWidget {
  final InsightModel insight;

  const InsightCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Text(
          insight.icon,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          insight.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(insight.subtitle),
        trailing: Text(
          insight.value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: insight.isPositive
                ? Colors.green
                : Colors.red,
          ),
        ),
      ),
    );
  }
}