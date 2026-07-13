import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/flat/screens/create_flat_screen.dart';
import '../features/flat/screens/flat_setup_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
  path: '/onboarding',
  name: 'onboarding',
  builder: (context, state) => const OnboardingScreen(),
),
GoRoute(
  path: '/login',
  name: 'login',
  builder: (context, state) => const LoginScreen(),
),
GoRoute(
  path: '/signup',
  name: 'signup',
  builder: (context, state) => const SignupScreen(),
),
GoRoute(
  path: '/forgot-password',
  name: 'forgot-password',
  builder: (context, state) => const ForgotPasswordScreen(),
),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
  path: '/flat-setup',
  name: 'flat-setup',
  builder: (context, state) => const FlatSetupScreen(),
),
GoRoute(
  path: '/create-flat',
  name: 'create-flat',
  builder: (context, state) => const CreateFlatScreen(),
),
  ],
);