import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/config/app_theme.dart';
import 'src/routes/app_router.dart';
import 'src/services/storage_service.dart';
import 'firebase_options.dart'; // ✅ 已经取消注释，引入你刚才手写的配置文件

Future<void> main() async {
  // 必须保留：确保 Flutter 引擎初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 必须保留：初始化你的本地存储服务
  await StorageService.init();

  // --- Firebase 真实初始化区域 ---
  try {
      // ✅ 已经取消注释，调用你配置的 apiKey 和 projectId
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, 
      );
  } catch (e) {
      debugPrint("Firebase initialization failed: $e");
      // 如果初始化失败，显示红色的错误提示页面
      runApp(InitializationErrorApp(error: e.toString()));
      return; // 阻止程序继续往下走
  }
  // -------------------------------------------

  // 初始化成功后，正常启动 App
  runApp(const MyApp());
}

class InitializationErrorApp extends StatelessWidget {
  final String error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please ensure firebase_options.dart is correctly configured.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
        darkTheme: AppTheme.darkTheme, 
        themeMode: ThemeMode.system,
        // 这里是关键：确保 routerConfig 能够感知到 URL 的变化
        routerConfig: AppRouter.router, 
      ),
    );
  }
}
