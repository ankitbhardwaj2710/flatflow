import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}