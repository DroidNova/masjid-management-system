import 'package:flutter/material.dart';
import 'package:platform_core_frontend/app/router.dart';
import 'package:platform_core_frontend/shared/theme/app_theme.dart';

class MasjidCoreApp extends StatelessWidget {
  const MasjidCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Masjid Core',
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
