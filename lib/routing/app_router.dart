import 'package:go_router/go_router.dart';
import '../features/export/screens/export_screen.dart';
import '../core/widgets/main_navigation_shell.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/expenses/screens/expenses_screen.dart';
import '../features/flat/screens/create_flat_screen.dart';
import '../features/flat/screens/flat_setup_screen.dart';
import '../features/flat/screens/join_flat_screen.dart';
import '../features/grocery/screens/grocery_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/expenses/screens/add_expense_screen.dart';
import '../features/expenses/screens/expense_details_screen.dart';
import '../features/expenses/models/expense_model.dart';
import '../features/profile/screens/flat_settings_screen.dart';
import '../features/bills/screens/bills_screen.dart';
import '../features/insights/screens/insights_screen.dart';
import '../features/settlement/screens/settlement_screen.dart';
import '../features/settlement/screens/settlement_history_screen.dart';
import '../../features/activity/screens/activity_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';

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
  path: '/notifications',
  builder: (context, state) =>
      const NotificationScreen(),
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
      path: '/flat-setup',
      name: 'flat-setup',
      builder: (context, state) => const FlatSetupScreen(),
    ),
    GoRoute(
  path: '/activity',
  builder: (context, state) =>
      const ActivityScreen(),
),
    GoRoute(
  path: '/settlement-history',
  builder: (_, __) =>
      const SettlementHistoryScreen(),
),
    GoRoute(
      path: '/create-flat',
      name: 'create-flat',
      builder: (context, state) => const CreateFlatScreen(),
    ),
    GoRoute(
  path: '/insights',
  name: 'insights',
  builder: (context, state) =>  const InsightsScreen(),
),
    GoRoute(
      path: '/join-flat',
      name: 'join-flat',
      builder: (context, state) => const JoinFlatScreen(),
    ),
    GoRoute(
  path: '/flat-settings',
  name: 'flat-settings',
  builder: (context, state) => const FlatSettingsScreen(),
),
GoRoute(
  path: '/bills',
  name: 'bills',
  builder: (context, state) => const BillsScreen(),
),
GoRoute(
  path: '/settlement',
  builder: (context, state) =>
      const SettlementScreen(),
),
GoRoute(
  path: '/add-expense',
  name: 'add-expense',
  builder: (context, state) => const AddExpenseScreen(),
),
GoRoute(
  path: '/export',
  name: 'export',
  builder: (context, state) => const ExportScreen(),
),
GoRoute(
  path: '/expense-details',
  name: 'expense-details',
  builder: (context, state) {
    final expense = state.extra as ExpenseModel;

    return ExpenseDetailsScreen(
      expense: expense,
    );
  },
),
GoRoute(
  path: '/edit-expense',
  name: 'edit-expense',
  builder: (context, state) {
    final expense = state.extra as ExpenseModel;

    return AddExpenseScreen(
      expense: expense,
    );
  },
),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/expenses',
              name: 'expenses', 
              builder: (context, state) => const ExpensesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/grocery',
              name: 'grocery',
              builder: (context, state) => const GroceryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);