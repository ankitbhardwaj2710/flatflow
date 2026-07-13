import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../repositories/flat_repository.dart';

final flatRepositoryProvider = Provider<FlatRepository>((ref) {
  return FlatRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});