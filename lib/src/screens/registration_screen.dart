import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. 添加此导入以支持跳转

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 暂时用文字代替 Logo
              const Text(
                "CommUnity",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 100),

              // 唯一的 Google 登录按钮
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  // 2. 修改此处的跳转逻辑
                  onPressed: () => context.go('/welcome-registration'), 
                  icon: const Icon(Icons.login, color: Colors.black),
                  label: const Text(
                    "Login with Google",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}