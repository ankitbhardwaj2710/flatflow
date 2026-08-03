import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bills/providers/bill_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../../home/providers/home_provider.dart';

import '../models/insight_model.dart';
import '../services/insight_service.dart';

final insightServiceProvider = Provider(
  (ref) => InsightService(),
);

final insightsProvider =
    Provider<List<InsightModel>>((ref) {
  final expenses =
      ref.watch(expensesProvider).value ?? [];

  final bills =
      ref.watch(billsProvider).value ?? [];

  final members =
      ref.watch(currentFlatMembersProvider).value ?? [];

  return ref
      .watch(insightServiceProvider)
      .generateInsights(
        expenses: expenses,
        bills: bills,
        members: members,
      );
});