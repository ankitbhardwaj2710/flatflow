import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/providers/home_provider.dart';

class FlatSettingsScreen extends ConsumerWidget {
  const FlatSettingsScreen({super.key});

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
                    onPressed: () {},
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
