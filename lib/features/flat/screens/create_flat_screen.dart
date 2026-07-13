import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/flat_provider.dart';

class CreateFlatScreen extends ConsumerStatefulWidget {
  const CreateFlatScreen({super.key});

  @override
  ConsumerState<CreateFlatScreen> createState() =>
      _CreateFlatScreenState();
}

class _CreateFlatScreenState extends ConsumerState<CreateFlatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flatNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _flatNameController.dispose();
    super.dispose();
  }

  Future<void> _createFlat() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(flatRepositoryProvider).createFlat(
            flatName: _flatNameController.text,
          );

      if (mounted) {
        context.go('/home');
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to create flat: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Flat'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Give your flat a name',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This name will be visible to everyone who joins your flat.',
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
                const SizedBox(height: 32),
                TextFormField(
                  controller: _flatNameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _createFlat(),
                  decoration: const InputDecoration(
                    labelText: 'Flat name',
                    hintText: 'e.g. Gurugram Flat',
                    prefixIcon: Icon(
                      Icons.home_outlined,
                    ),
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.length < 2) {
                      return 'Please enter a valid flat name';
                    }

                    if (name.length > 40) {
                      return 'Flat name is too long';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createFlat,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Flat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}