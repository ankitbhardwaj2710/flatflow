import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/insight_provider.dart';
import '../widgets/insight_card.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Insights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: insights.isEmpty
          ? const Center(
              child: Text(
                'No insights available yet.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: insights.length,
              itemBuilder: (context, index) {
                return InsightCard(
                  insight: insights[index],
                );
              },
            ),
    );
  }
}