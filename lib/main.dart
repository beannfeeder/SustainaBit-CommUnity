import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/config/app_theme.dart';
import 'src/routes/app_router.dart'; // 恢复这个导入

void main() {
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
      // 恢复 .router 模式，让 AppRouter 掌管页面跳转
      child: MaterialApp.router( 
        title: 'SustainaBit CommUnity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, 
        
        // 恢复这一行，连接到你在 app_router.dart 里写的配置
        routerConfig: AppRouter.router, 
      ),
    );
  }
}