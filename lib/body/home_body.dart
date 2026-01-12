import 'package:flutter/material.dart';
import 'package:stock_inv/signin/firebase_service_login.dart';
import 'package:stock_inv/signin/main_login.dart';
import 'package:stock_inv/data/const_data.dart'; // 전역 변수 (user_email)

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final AuthService _authService = AuthService();

  // 로그아웃 처리
  void _handleLogout() async {
    // 1. Firebase 로그아웃
    await _authService.signOut();

    if (!mounted) return;

    // 2. 로그인 화면으로 이동 (이전 스택 모두 제거)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Home'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                '환영합니다!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}