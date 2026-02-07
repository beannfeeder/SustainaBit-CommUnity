import 'package:flutter/material.dart';
import 'src/services/storage_service.dart';

import 'src/config/app_theme.dart';
import 'src/routes/app_router.dart';

Future<void> main() async {
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SustainaBit CommUnity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
