import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

                  const SizedBox(height: 25),

                  FilledButton.icon(
                    onPressed: () {
                      _showRenameDialog(context, ref, flat.name);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Rename Flat"),
                  ),
                ],
              );
            },
          ),
    );
  }
}
