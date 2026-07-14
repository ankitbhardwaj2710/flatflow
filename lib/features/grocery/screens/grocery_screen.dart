import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../models/grocery_item_model.dart';
import '../providers/grocery_provider.dart';

class GroceryScreen extends ConsumerWidget {
  const GroceryScreen({super.key});

  Future<void> _showAddItemSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> saveItem() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              FocusScope.of(context).unfocus();

              setSheetState(() {
                isSaving = true;
              });

              try {
                await ref
                    .read(groceryRepositoryProvider)
                    .addItem(
                      name: nameController.text,
                      quantity: quantityController.text,
                    );

                if (!sheetContext.mounted) return;

                Navigator.of(sheetContext).pop();

                ScaffoldMessenger.of(
                  sheetContext,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Grocery item added successfully.',
                    ),
                  ),
                );
              } catch (error) {
                if (!sheetContext.mounted) return;

                String message = error.toString();

                if (message.startsWith('Exception: ')) {
                  message = message.replaceFirst(
                    'Exception: ',
                    '',
                  );
                }

                ScaffoldMessenger.of(
                  sheetContext,
                ).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );

                setSheetState(() {
                  isSaving = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add grocery item',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: isSaving
                              ? null
                              : () {
                                  Navigator.of(
                                    sheetContext,
                                  ).pop();
                                },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization:
                          TextCapitalization.sentences,
                      textInputAction:
                          TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                        hintText: 'e.g. Milk',
                        prefixIcon: Icon(
                          Icons.shopping_basket_outlined,
                        ),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Please enter an item name';
                        }

                        if (name.length > 60) {
                          return 'Item name is too long';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: quantityController,
                      textCapitalization:
                          TextCapitalization.sentences,
                      textInputAction:
                          TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isSaving) {
                          saveItem();
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Quantity (optional)',
                        hintText: 'e.g. 2 packets',
                        prefixIcon: Icon(
                          Icons.numbers_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed:
                            isSaving ? null : saveItem,
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Add Item',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // nameController.dispose();
    // quantityController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(groceryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grocery',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add grocery item',
            onPressed: () {
              _showAddItemSheet(
                context,
                ref,
              );
            },
            icon: const Icon(
              Icons.add_rounded,
            ),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () {
            ref.invalidate(groceryItemsProvider);
          },
        ),
        data: (items) {
          final pendingItems = items
              .where(
                (item) => !item.isBought,
              )
              .toList();

          final boughtItems = items
              .where(
                (item) => item.isBought,
              )
              .toList();

          if (items.isEmpty) {
            return _EmptyGroceryView(
              onAddItem: () {
                _showAddItemSheet(
                  context,
                  ref,
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                groceryItemsProvider,
              );
            },
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                120,
              ),
              children: [
                _GrocerySummaryCard(
                  pendingCount:
                      pendingItems.length,
                  boughtCount:
                      boughtItems.length,
                ),

                if (pendingItems.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'To buy',
                    count: pendingItems.length,
                  ),
                  const SizedBox(height: 12),
                  _GroceryItemsCard(
                    items: pendingItems,
                  ),
                ],

                if (boughtItems.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Bought',
                    count: boughtItems.length,
                  ),
                  const SizedBox(height: 12),
                  _GroceryItemsCard(
                    items: boughtItems,
                  ),
                ],
              ],
            ),
          );
        },
      ),
      
    );
  }
}

class _GrocerySummaryCard extends StatelessWidget {
  final int pendingCount;
  final int boughtCount;

  const _GrocerySummaryCard({
    required this.pendingCount,
    required this.boughtCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount =
        pendingCount + boughtCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 18),
          const Text(
            'Shared grocery list',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalCount == 0
                ? 'Your list is empty'
                : '$pendingCount to buy • $boughtCount bought',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.75,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.10),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _GroceryItemsCard
    extends ConsumerWidget {
  final List<GroceryItemModel> items;

  const _GroceryItemsCard({
    required this.items,
  });

  Future<void> _toggleItem(
    BuildContext context,
    WidgetRef ref,
    GroceryItemModel item,
  ) async {
    try {
      await ref
          .read(groceryRepositoryProvider)
          .toggleBought(item);
    } catch (error) {
      if (!context.mounted) return;

      String message = error.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        message = message.replaceFirst(
          'Exception: ',
          '',
        );
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    GroceryItemModel item,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete item?',
          ),
          content: Text(
            'Remove "${item.name}" from the shared grocery list?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        !context.mounted) {
      return;
    }

    try {
      await ref
          .read(groceryRepositoryProvider)
          .deleteItem(item.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Grocery item deleted.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      String message = error.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        message = message.replaceFirst(
          'Exception: ',
          '',
        );
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];
            final isLast =
                index == items.length - 1;

            return Column(
              children: [
                Dismissible(
                  key: ValueKey(
                    item.id,
                  ),
                  direction:
                      DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _deleteItem(
                      context,
                      ref,
                      item,
                    );

                    // Firestore stream removes
                    // the item from the UI.
                    return false;
                  },
                  background: Container(
                    alignment:
                        Alignment.centerRight,
                    padding:
                        const EdgeInsets.only(
                      right: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: item.isBought,
                    onChanged: (_) {
                      _toggleItem(
                        context,
                        ref,
                        item,
                      );
                    },
                    controlAffinity:
                        ListTileControlAffinity
                            .leading,
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        decoration:
                            item.isBought
                                ? TextDecoration
                                    .lineThrough
                                : null,
                        color: item.isBought
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(
                                  alpha: 0.45,
                                )
                            : null,
                      ),
                    ),
                    subtitle:
                        item.quantity.isEmpty
                            ? null
                            : Text(
                                item.quantity,
                              ),
                    secondary: IconButton(
                      tooltip: 'Delete',
                      onPressed: () {
                        _deleteItem(
                          context,
                          ref,
                          item,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .delete_outline_rounded,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyGroceryView
    extends StatelessWidget {
  final VoidCallback onAddItem;

  const _EmptyGroceryView({
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Your grocery list is empty',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add items your flat needs and keep the list synced with everyone.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    height: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(
                          alpha: 0.55,
                        ),
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddItem,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Add first item',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load grocery list.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}