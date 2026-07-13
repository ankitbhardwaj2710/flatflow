import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class FlatSetupScreen extends StatelessWidget {
  const FlatSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Set up your flat',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create a new flat or join your roommates using an invite code.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.60),
                    ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push('/create-flat'),
                icon: const Icon(Icons.add_home_rounded),
                label: const Text(
                  'Create a Flat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Join Flat screen next step me banayenge.
                  },
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text(
                    'Join with Invite Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}