import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../expenses/models/member_balance.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocument = ref.watch(currentUserDocumentProvider);
    final currentFlat = ref.watch(currentFlatProvider);
    final members = ref.watch(currentFlatMembersProvider);
    final expenseSummary = ref.watch(expenseSummaryProvider);
    final memberBalances = ref.watch(memberBalancesProvider);

    return Scaffold(
      body: SafeArea(
        child: userDocument.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => _ErrorView(
            message: 'Unable to load your profile.',
            onRetry: () {
              ref.invalidate(currentUserDocumentProvider);
            },
          ),
          data: (userSnapshot) {
            final userData = userSnapshot.data();

            final userName =
                userData?['name']?.toString().trim();

            final displayName =
                userName != null && userName.isNotEmpty
                    ? userName
                    : 'FlatFlow User';

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentUserDocumentProvider);
                ref.invalidate(currentFlatProvider);
                ref.invalidate(currentFlatMembersProvider);
                ref.invalidate(expensesProvider);
              },
              child: CustomScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      32,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _Header(
                          userName: displayName,
                        ),
                        const SizedBox(height: 28),

                        currentFlat.when(
                          loading: () =>
                              const _LoadingCard(),
                          error: (error, stackTrace) =>
                              const _ErrorCard(
                            message:
                                'Unable to load your flat.',
                          ),
                          data: (flat) {
                            if (flat == null) {
                              return const _ErrorCard(
                                message:
                                    'No active flat found.',
                              );
                            }

                            return _FlatCard(
                              flatName: flat.name,
                              inviteCode: flat.inviteCode,
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'Overview',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _OverviewCard(
                                icon: Icons
                                    .account_balance_wallet_outlined,
                                title: _getBalanceLabel(
                                  expenseSummary.balance,
                                ),
                                value: _formatCurrency(
                                  expenseSummary.balance
                                      .abs(),
                                ),
                                iconColor:
                                    expenseSummary.balance >=
                                            0
                                        ? AppColors.primary
                                        : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OverviewCard(
                                icon: Icons
                                    .receipt_long_outlined,
                                title: 'This month',
                                value: _formatCurrency(
                                  expenseSummary
                                      .monthlySpending,
                                ),
                                iconColor:
                                    AppColors.secondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'Balances',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                        ),

                        const SizedBox(height: 14),

                        if (memberBalances.isEmpty)
                          const _SettledBalanceCard()
                        else
                          _MemberBalancesCard(
                            balances: memberBalances,
                          ),

                        const SizedBox(height: 28),

                        Text(
                          'Quick actions',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                        ),

                        const SizedBox(height: 14),

                        const Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.add_rounded,
                                label: 'Add expense',
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons
                                    .receipt_long_rounded,
                                label: 'Add bill',
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons
                                    .shopping_cart_outlined,
                                label: 'Grocery',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              'Flat members',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                            ),
                            members.when(
                              data: (memberList) => Text(
                                '${memberList.length} members',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(
                                        alpha: 0.55,
                                      ),
                                ),
                              ),
                              loading: () =>
                                  const SizedBox(),
                              error: (
                                error,
                                stackTrace,
                              ) =>
                                  const SizedBox(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        members.when(
                          loading: () =>
                              const _LoadingCard(),
                          error: (error, stackTrace) =>
                              const _ErrorCard(
                            message:
                                'Unable to load members.',
                          ),
                          data: (memberList) {
                            if (memberList.isEmpty) {
                              return const _ErrorCard(
                                message:
                                    'No members found.',
                              );
                            }

                            return _MembersCard(
                              members: memberList,
                            );
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;

  const _Header({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final cleanName = userName.trim();

    final firstName = cleanName.isEmpty
        ? 'FlatFlow User'
        : cleanName.split(RegExp(r'\s+')).first;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you,',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                firstName,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),
      ],
    );
  }
}

class _FlatCard extends StatelessWidget {
  final String flatName;
  final String inviteCode;

  const _FlatCard({
    required this.flatName,
    required this.inviteCode,
  });

  Future<void> _copyInviteCode(
    BuildContext context,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: inviteCode),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 20),
          Text(
            flatName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your shared space',
            style: TextStyle(
              color:
                  Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 22),
          InkWell(
            onTap: () => _copyInviteCode(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.14,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INVITE CODE',
                          style: TextStyle(
                            color: Colors.white
                                .withValues(
                                  alpha: 0.65,
                                ),
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inviteCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionCard({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  final List<Map<String, dynamic>> members;

  const _MembersCard({
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1),
        itemBuilder: (context, index) {
          final member = members[index];

          final name =
              member['name'] as String? ??
              'Flat member';

          final role =
              member['role'] as String? ??
              'member';

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 6,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary
                  .withValues(alpha: 0.10),
              child: Text(
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              role == 'admin'
                  ? 'Admin'
                  : 'Member',
            ),
          );
        },
      ),
    );
  }
}

class _MemberBalancesCard
    extends ConsumerStatefulWidget {
  final List<MemberBalance> balances;

  const _MemberBalancesCard({
    required this.balances,
  });

  @override
  ConsumerState<_MemberBalancesCard>
      createState() =>
          _MemberBalancesCardState();
}

class _MemberBalancesCardState
    extends ConsumerState<_MemberBalancesCard> {
  String? _processingMemberId;

  Future<void> _settleUp(
    MemberBalance balance,
  ) async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final amount = balance.amount.abs();

    final paidBy = balance.owesYou
        ? balance.memberId
        : currentUser.uid;

    final paidTo = balance.owesYou
        ? currentUser.uid
        : balance.memberId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Confirm settlement'),
          content: Text(
            balance.owesYou
                ? '${balance.memberName} paid you '
                    '${_formatCurrency(amount)}?'
                : 'You paid ${balance.memberName} '
                    '${_formatCurrency(amount)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _processingMemberId =
          balance.memberId;
    });

    try {
      await ref
          .read(expenseRepositoryProvider)
          .addSettlement(
            paidBy: paidBy,
            paidTo: paidTo,
            amount: amount,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Settlement recorded successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      String message = error.toString();

      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst(
          'Exception: ',
          '',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingMemberId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(
          widget.balances.length,
          (index) {
            final balance =
                widget.balances[index];

            final isLast =
                index ==
                widget.balances.length - 1;

            final isProcessing =
                _processingMemberId ==
                balance.memberId;

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          balance.memberName
                                  .isNotEmpty
                              ? balance
                                  .memberName[0]
                                  .toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              balance.memberName,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              balance.owesYou
                                  ? 'owes you ${_formatCurrency(balance.amount.abs())}'
                                  : 'you owe ${_formatCurrency(balance.amount.abs())}',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    balance.owesYou
                                        ? Colors
                                            .green
                                        : Colors
                                            .orange,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 38,
                        child:
                            FilledButton.tonal(
                          onPressed: isProcessing
                              ? null
                              : () {
                                  _settleUp(
                                    balance,
                                  );
                                },
                          child: isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Text(
                                  'Settle Up',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettledBalanceCard
    extends StatelessWidget {
  const _SettledBalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Everyone is settled up.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

String _getBalanceLabel(double balance) {
  if (balance > 0.009) {
    return 'You get back';
  }

  if (balance < -0.009) {
    return 'You owe';
  }

  return 'Settled up';
}

String _formatCurrency(double amount) {
  if (amount == amount.roundToDouble()) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  return '₹${amount.toStringAsFixed(2)}';
}