import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';
import 'package:frontend/core/locale_controller.dart';
import 'package:frontend/core/theme.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/screens/screens.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('navigates from splash to login', (tester) async {
    await tester.pumpWidget(HealGuiApp());

    expect(find.text('Heal Gui AI'), findsWidgets);
    expect(find.text('AI Powered Smart Healthcare'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('personal details fields, dropdowns, and save work', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 1400));

    final router = GoRouter(
      initialLocation: '/personal-details',
      routes: [
        GoRoute(path: '/personal-details', builder: (context, state) => const PersonalDetailsScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeDashboardScreen()),
      ],
    );

    await tester.pumpWidget(_LocalizedTestApp(controller: LocaleController(), router: router));

    for (final label in const [
      'Name',
      'Age',
      'Gender',
      'Height',
      'Weight',
      'Blood Pressure',
      'Heart Rate',
      'Blood Group',
      'Family History',
      'Allergies',
      'Diabetes',
      'Smoking',
      'Alcohol',
      'Exercise',
      'Sleep Hours',
      'Water Intake',
      'Emergency Contact',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    expect(find.text('Male'), findsNothing);

    await tester.tap(find.text('Gender'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Male').last);
    await tester.pumpAndSettle();
    expect(find.text('Male'), findsOneWidget);

    await tester.tap(find.text('Blood Group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('O-').last);
    await tester.pumpAndSettle();
    expect(find.text('O-'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'John');
    await tester.enterText(find.widgetWithText(TextField, 'Emergency Contact'), '555-0100');
    await tester.tap(find.text('Save Profile'));
    await tester.pump();
    expect(find.text('Saving...'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 1000));
    expect(find.text('Hello John'), findsOneWidget);
  });

  testWidgets('settings switches language immediately and persists it', (tester) async {
    final controller = LocaleController();
    await controller.load();

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    );

    await tester.pumpWidget(_LocalizedTestApp(controller: controller, router: router));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('தமிழ் (Tamil)'), findsOneWidget);

    await tester.tap(find.text('தமிழ் (Tamil)'));
    await tester.pumpAndSettle();

    expect(find.text('அமைப்புகள்'), findsOneWidget);
    expect(find.text('மொழி'), findsOneWidget);
    expect(find.text('ஆங்கிலம்'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language_code'), 'ta');

    final restoredController = LocaleController();
    await restoredController.load();
    expect(restoredController.locale, const Locale('ta'));

    await tester.tap(find.text('ஆங்கிலம்'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(prefs.getString('language_code'), 'en');
  });

  testWidgets('navbar language menu switches language and persists it', (tester) async {
    final controller = LocaleController();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeDashboardScreen()),
      ],
    );

    await tester.pumpWidget(_LocalizedTestApp(controller: controller, router: router));
    await tester.pump();

    expect(find.text('Hello John'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('தமிழ் (Tamil)').last);
    await tester.pumpAndSettle();

    expect(find.text('வணக்கம் ஜான்'), findsOneWidget);
    expect(find.text('தமிழ்'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language_code'), 'ta');

    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ஆங்கிலம்').last);
    await tester.pumpAndSettle();

    expect(find.text('Hello John'), findsOneWidget);
    expect(prefs.getString('language_code'), 'en');
  });

  testWidgets('primary routes render in English and Tamil', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 1600));

    for (final locale in const [Locale('en'), Locale('ta')]) {
      for (final route in const [
        '/home',
        '/games',
        '/upload',
        '/analysis',
        '/ai-report',
        '/chat',
        '/future',
        '/diet',
        '/progress',
        '/reports',
        '/profile',
        '/settings',
      ]) {
        final controller = LocaleController();
        await controller.setLocale(locale);

        await tester.pumpWidget(_LocalizedTestApp(controller: controller, router: _routerFor(route)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1200));

        expect(tester.takeException(), isNull);
      }
    }
  });
}

GoRouter _routerFor(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
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

class _LocalizedTestApp extends StatelessWidget {
  const _LocalizedTestApp({required this.controller, required this.router});

  final LocaleController controller;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return LocaleControllerScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp.router(
            theme: AppTheme.light,
            locale: controller.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('en'), Locale('ta')],
            routerConfig: router,
          );
        },
      ),
    );
  }
}
