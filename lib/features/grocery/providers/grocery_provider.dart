import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/grocery_item_model.dart';
import '../repositories/grocery_repository.dart';

final groceryRepositoryProvider = Provider<GroceryRepository>((ref) {
  return GroceryRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final groceryItemsProvider = StreamProvider<List<GroceryItemModel>>((ref) {
  return ref.watch(groceryRepositoryProvider).watchItems();
});

final pendingGroceryItemsProvider = Provider<List<GroceryItemModel>>((ref) {
  final items = ref.watch(groceryItemsProvider).value ?? [];

  return items.where((item) => !item.isBought).toList();
});

final boughtGroceryItemsProvider = Provider<List<GroceryItemModel>>((ref) {
  final items = ref.watch(groceryItemsProvider).value ?? [];

  return items.where((item) => item.isBought).toList();
});
