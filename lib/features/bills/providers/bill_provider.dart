import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../models/bill_model.dart';
import '../repositories/bill_repository.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final billsProvider = StreamProvider<List<BillModel>>((ref) {
  return ref.watch(billRepositoryProvider).watchBills();
});

class BillSummary {
  final int totalBills;
  final int paidBills;
  final int unpaidBills;
  final double totalAmount;
  final double unpaidAmount;

  const BillSummary({
    required this.totalBills,
    required this.paidBills,
    required this.unpaidBills,
    required this.totalAmount,
    required this.unpaidAmount,
  });
}

final billSummaryProvider = Provider<BillSummary>((ref) {
  final bills = ref.watch(billsProvider).value ?? [];

  int paid = 0;
  int unpaid = 0;

  double total = 0;
  double pending = 0;

  for (final bill in bills) {
    total += bill.amount;

    if (bill.isPaid) {
      paid++;
    } else {
      unpaid++;
      pending += bill.amount;
    }
  }

  return BillSummary(
    totalBills: bills.length,
    paidBills: paid,
    unpaidBills: unpaid,
    totalAmount: total,
    unpaidAmount: pending,
  );
});