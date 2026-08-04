import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/settlement_model.dart';
import '../repository/settlement_repository.dart';

final settlementRepositoryProvider =
    Provider<SettlementRepository>(
  (ref) => SettlementRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  ),
);

final settlementProvider =
    FutureProvider<List<SettlementModel>>(
  (ref) {
    return ref
        .read(settlementRepositoryProvider)
        .calculateSettlements();
  },
);