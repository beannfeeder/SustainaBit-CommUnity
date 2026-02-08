import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/config/app_theme.dart';
import 'src/routes/app_router.dart';
import 'src/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<String>.value(value: "Init"),
      ],
      child: MaterialApp.router(
        title: 'SustainaBit CommUnity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme, // 顺便保留主分支的暗黑模式配置
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router, // 确保指向你的路由配置
      ),
    );
  }
}