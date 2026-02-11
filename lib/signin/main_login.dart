import 'package:flutter/material.dart';
import 'package:stock_inv/signin/button_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 영역 (아이콘으로 대체)
              const Icon(Icons.inventory, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 16),
              const Text(
                'Stock Inv',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '당신의 투자 파트너',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 로그인 입력 폼 위젯
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}