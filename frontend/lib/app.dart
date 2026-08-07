import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/routes.dart';
import 'core/theme.dart';

class HealGuiApp extends StatelessWidget {
  HealGuiApp({super.key});

  final GoRouter _router = AppRoutes.router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Heal Gui AI',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
