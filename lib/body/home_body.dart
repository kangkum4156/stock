import 'package:flutter/material.dart';
import 'package:stock_inv/body/stock/stock_body.dart';
import 'package:stock_inv/body/notice/notice_body.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../signin/main_login.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  int _currentIndex = 0;

  // 탭에 따라 보여줄 페이지 리스트
  final List<Widget> _pages = [
    const StockBody(),   // 첫 번째 페이지: 주식 정보
    const NoticeBody(),  // 두 번째 페이지: 공지사항
  ];

  // 로그아웃 로직
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      // 로그인 화면으로 이동하며 스택 제거
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [추가됨] 상단 툴바 (AppBar)
      appBar: AppBar(
        title: const Text(
          'Stock INV',
          style: TextStyle(fontWeight: FontWeight.bold), // 굵게 강조
        ),
        backgroundColor: Colors.blue,
        centerTitle: false, // false로 설정해야 타이틀이 왼쪽으로 붙습니다.
        elevation: 1,       // 툴바 그림자 (0으로 하면 평평해짐)
        actions: [
          // 우측 상단 로그아웃 버튼
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
          ),
          const SizedBox(width: 10), // 우측 여백 약간 추가
        ],
      ),

      // 현재 인덱스에 해당하는 바디를 보여줌
      body: _pages[_currentIndex],

      // 하단 네비게이션 바 (프래그먼트 전환 역할)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: '주식 현황',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '공지사항',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}