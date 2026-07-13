import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (mounted) {
        context.go('/flat-setup');
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message = 'Unable to sign in. Please try again.';

      switch (error.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/flatflow_logo.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Welcome back 👋',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue managing your flat.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.60),
                      ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!email.contains('@') ||
                        !email.contains('.')) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                    child: const Text(
                      'Forgot password?',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        'New to FlatFlow?',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      context.push('/signup');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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