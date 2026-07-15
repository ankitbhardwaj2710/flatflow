import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _copyInviteCode(BuildContext context, String inviteCode) async {
    if (inviteCode.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: inviteCode));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied to clipboard.')),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out of FlatFlow?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(firebaseAuthProvider).signOut();

      if (!context.mounted) {
        return;
      }

      context.go('/login');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to log out: $error')));
    }
  }

  Future<void> _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final nameController = TextEditingController(text: currentName);

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> saveProfile() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              FocusScope.of(context).unfocus();

              setSheetState(() {
                isSaving = true;
              });

              try {
                final user = ref.read(firebaseAuthProvider).currentUser;

                if (user == null) {
                  throw Exception('User is not signed in.');
                }

                final name = nameController.text.trim();

                final firestore = ref.read(firestoreProvider);

                // Get current user's document.
                final userDocument = await firestore
                    .collection('users')
                    .doc(user.uid)
                    .get();

                final flatId = userDocument.data()?['currentFlatId'] as String?;

                // Update main user profile.
                await firestore.collection('users').doc(user.uid).update({
                  'name': name,
                });

                // Update the user's name inside the
                // current flat members collection too.
                if (flatId != null && flatId.isNotEmpty) {
                  await firestore
                      .collection('flats')
                      .doc(flatId)
                      .collection('members')
                      .doc(user.uid)
                      .update({'name': name});
                }

                // Update Firebase Auth display name.
                await user.updateDisplayName(name);

                // Refresh all providers that use the user's name.
                // ref.invalidate(
                //   currentUserDocumentProvider,
                // );

                // ref.invalidate(
                //   currentFlatMembersProvider,
                // );

                if (!sheetContext.mounted) {
                  return;
                }

                Navigator.of(sheetContext).pop();

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully.'),
                  ),
                );
              } catch (error) {
                if (!sheetContext.mounted) {
                  return;
                }

                String message = error.toString();

                if (message.startsWith('Exception: ')) {
                  message = message.replaceFirst('Exception: ', '');
                }

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Edit profile',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          onPressed: isSaving
                              ? null
                              : () {
                                  Navigator.of(sheetContext).pop();
                                },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isSaving) {
                          saveProfile();
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Please enter your name';
                        }

                        if (name.length < 2) {
                          return 'Name is too short';
                        }

                        if (name.length > 50) {
                          return 'Name is too long';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: isSaving ? null : saveProfile,
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontWeight: FontWeight.w800),
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

    // Intentionally not disposing here because the bottom sheet
    // may still be finishing its closing animation.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocument = ref.watch(currentUserDocumentProvider);

    final currentFlat = ref.watch(currentFlatProvider);

    final members = ref.watch(currentFlatMembersProvider);

    final authUser = ref.watch(firebaseAuthProvider).currentUser;
    final currentUserData = userDocument.value;

    final currentUserName =
        currentUserData?['name'] as String? ??
        authUser?.displayName ??
        'FlatFlow User';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentUserDocumentProvider);

          ref.invalidate(currentFlatProvider);

          ref.invalidate(currentFlatMembersProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            userDocument.when(
              loading: () => const _ProfileHeaderLoading(),
              error: (error, stackTrace) => _ProfileHeader(
                name: 'FlatFlow User',
                email: authUser?.email ?? '',
              ),
              data: (userData) {
                final name =
                    userData['name'] as String? ??
                    authUser?.displayName ??
                    'FlatFlow User';

                final email =
                    userData['email'] as String? ?? authUser?.email ?? '';

                return _ProfileHeader(name: name, email: email);
              },
            ),

            const SizedBox(height: 28),

            Text(
              'Your flat',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 14),

            currentFlat.when(
              loading: () => const _FlatCardLoading(),
              error: (error, stackTrace) => const _NoFlatCard(),
              data: (flatData) {
                if (flatData == null) {
                  return const _NoFlatCard();
                }

                final flatName = flatData.name;
                final inviteCode = flatData.inviteCode;

                final memberCount = members.value?.length ?? 0;

                return _FlatInfoCard(
                  flatName: flatName,
                  inviteCode: inviteCode,
                  memberCount: memberCount,
                  onCopyInviteCode: () {
                    _copyInviteCode(context, inviteCode);
                  },
                );
              },
            ),

            const SizedBox(height: 28),

            Text(
              'Account',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 14),

            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    _showEditProfileSheet(context, ref, currentUserName);
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.home_outlined,
                  title: 'Flat settings',
                  subtitle: 'Manage your shared flat',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Flat settings are coming next.'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                _logout(context, ref);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileHeaderLoading extends StatelessWidget {
  const _ProfileHeaderLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 140,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _FlatInfoCard extends StatelessWidget {
  final String flatName;
  final String inviteCode;
  final int memberCount;
  final VoidCallback onCopyInviteCode;

  const _FlatInfoCard({
    required this.flatName,
    required this.inviteCode,
    required this.memberCount,
    required this.onCopyInviteCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.home_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flatName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$memberCount '
                      '${memberCount == 1 ? 'member' : 'members'}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (inviteCode.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite code',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inviteCode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Copy invite code',
                  onPressed: onCopyInviteCode,
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FlatCardLoading extends StatelessWidget {
  const _FlatCardLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _NoFlatCard extends StatelessWidget {
  const _NoFlatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(Icons.home_outlined, color: AppColors.primary),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'No active flat found.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
