import 'package:go_router/go_router.dart';

import '../screens/screens.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/personal-details', builder: (context, state) => const PersonalDetailsScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeDashboardScreen()),
      GoRoute(path: '/games', builder: (context, state) => const MiniGamesScreen()),
      GoRoute(path: '/upload', builder: (context, state) => const MedicalReportUploadScreen()),
      GoRoute(path: '/analysis', builder: (context, state) => const HealthAnalysisScreen()),
      GoRoute(path: '/ai-report', builder: (context, state) => const AiHealthReportScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const AiChatScreen()),
      GoRoute(path: '/future', builder: (context, state) => const FutureHealthScreen()),
      GoRoute(path: '/diet', builder: (context, state) => const DietScreen()),
      GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const ReportHistoryScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
}
