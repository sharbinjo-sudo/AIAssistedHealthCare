import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/locale_controller.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'l10n/generated/app_localizations.dart';

class HealGuiApp extends StatelessWidget {
  HealGuiApp({super.key, LocaleController? localeController}) : localeController = localeController ?? LocaleController();

  final GoRouter _router = AppRoutes.router;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return LocaleControllerScope(
      controller: localeController,
      child: AnimatedBuilder(
        animation: localeController,
        builder: (context, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: localeController.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ta'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
