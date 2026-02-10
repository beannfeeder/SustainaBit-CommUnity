import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeRegistrationScreen extends StatelessWidget {
  const WelcomeRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7), // 匹配设计图的淡绿色背景
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 1. Logo (暂时用文字)
              const Text(
                "CommUnity",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),

              // 2. 欢迎语
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nice to meet you, Joe!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select your community to receive posts and announcements around your area",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // 3. 地图部分 (暂时用灰色方块占位)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text("Map Placeholder")),
              ),
              const SizedBox(height: 24),

              // 4. 选择框标签
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Selected Community:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // 5. 社区选择框 (带图标的容器)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text("Warf Residences, Bukit Jalil"),
                    ),
                    Icon(Icons.location_on_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 6. Continue 按钮
              SizedBox(
                width: 150, // 匹配设计图的宽度
                height: 45,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Continue", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}