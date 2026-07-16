import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/providers/home_provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/providers/auth_provider.dart';

class FlatSettingsScreen extends ConsumerWidget {
  const FlatSettingsScreen({super.key});
  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Rename Flat"),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: "Flat Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                final newName = controller.text.trim();

                if (newName.isEmpty) {
                  return;
                }

                try {
                  final firestore = ref.read(firestoreProvider);

                  final user = ref.read(firebaseAuthProvider).currentUser;

                  if (user == null) {
                    return;
                  }

                  final userDoc = await firestore
                      .collection('users')
                      .doc(user.uid)
                      .get();

                  final flatId = userDoc.data()?['currentFlatId'] as String?;

                  if (flatId == null) {
                    return;
                  }

                  await firestore.collection('flats').doc(flatId).update({
                    'name': newName,
                  });

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Flat renamed successfully.')),
                  );
                } catch (error) {
                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveFlat(BuildContext context, WidgetRef ref) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Leave Flat"),
          content: const Text("Are you sure you want to leave this flat?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );

    if (shouldLeave != true) {
      return;
    }

    try {
      final firestore = ref.read(firestoreProvider);

      final user = ref.read(firebaseAuthProvider).currentUser;

      if (user == null) {
        return;
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      final flatId = userDoc.data()?['currentFlatId'] as String?;

      if (flatId == null) {
        return;
      }
      final memberDoc = await firestore
          .collection('flats')
          .doc(flatId)
          .collection('members')
          .doc(user.uid)
          .get();

      final role = memberDoc.data()?['role'] as String? ?? 'member';

      final memberSnapshot = await firestore
          .collection('flats')
          .doc(flatId)
          .collection('members')
          .get();

      final memberCount = memberSnapshot.docs.length;

      if (role == 'admin' && memberCount > 1) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer admin access before leaving the flat.'),
          ),
        );

        return;
      }
      // Remove member from flat
      await firestore
          .collection('flats')
          .doc(flatId)
          .collection('members')
          .doc(user.uid)
          .delete();

      // Remove current flat from user
      await firestore.collection('users').doc(user.uid).update({
        'currentFlatId': null,
      });

      if (!context.mounted) return;

      context.go('/flat-setup');
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _transferAdmin(
    BuildContext context,
    WidgetRef ref,
    String newAdminId,
    String newAdminName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Transfer Admin"),
          content: Text(
            "Make $newAdminName the new admin?\n\nYou will become a normal member.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Transfer"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final firestore = ref.read(firestoreProvider);

      final currentUser = ref.read(firebaseAuthProvider).currentUser;

      if (currentUser == null) return;

      final userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final flatId = userDoc.data()?['currentFlatId'] as String?;

      if (flatId == null) return;

      await firestore.runTransaction((transaction) async {
        final currentAdminRef = firestore
            .collection('flats')
            .doc(flatId)
            .collection('members')
            .doc(currentUser.uid);

        final newAdminRef = firestore
            .collection('flats')
            .doc(flatId)
            .collection('members')
            .doc(newAdminId);

        transaction.update(currentAdminRef, {'role': 'member'});

        transaction.update(newAdminRef, {'role': 'admin'});
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$newAdminName is now the admin.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flat Settings')),
      body: ref
          .watch(currentFlatProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (error, _) => Center(child: Text(error.toString())),

            data: (flat) {
              if (flat == null) {
                return const Center(child: Text("No Flat Found"));
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    flat.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.key),
                      title: const Text("Invite Code"),
                      subtitle: Text(flat.inviteCode),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text("Members"),
                      subtitle: Text(
                        "${ref.watch(currentFlatMembersProvider).value?.length ?? 0} Members",
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    "Members",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  ref
                      .watch(currentFlatMembersProvider)
                      .when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox(),
                        data: (members) {
                          final currentUser = ref
                              .read(firebaseAuthProvider)
                              .currentUser;

                          final currentUserRole =
                              members.firstWhere(
                                    (member) =>
                                        member['id'] == currentUser?.uid,
                                    orElse: () => <String, dynamic>{},
                                  )['role']
                                  as String? ??
                              'member';

                          final isCurrentUserAdmin = currentUserRole == 'admin';
                          return Card(
                            child: Column(
                              children: members.map((member) {
                                final isAdmin = member['role'] == 'admin';

                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      (member['name'] ?? '?')
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase(),
                                    ),
                                  ),
                                  title: Text(member['name'] ?? ''),
                                  subtitle: Text(isAdmin ? "Admin" : "Member"),
                                  trailing: isAdmin
                                      ? const Icon(
                                          Icons.workspace_premium,
                                          color: Colors.amber,
                                        )
                                      : isCurrentUserAdmin
                                      ? TextButton(
                                          onPressed: () {
                                            _transferAdmin(
                                              context,
                                              ref,
                                              member['id'] as String,
                                              member['name'] as String,
                                            );
                                          },
                                          child: const Text("Make Admin"),
                                        )
                                      : const SizedBox(),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 25),

                  FilledButton.icon(
                    onPressed: () {
                      _showRenameDialog(context, ref, flat.name);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Rename Flat"),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {
                      _leaveFlat(context, ref);
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Leave Flat"),
                  ),
                ],
              );
            },
          ),
    );
  }
}
