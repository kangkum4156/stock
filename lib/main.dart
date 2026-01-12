import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_inv/firebase_options.dart';
import 'package:stock_inv/signin/main_login.dart';
import 'package:stock_inv/body/home_body.dart';
import 'package:stock_inv/data/const_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ★ 핵심 추가: 앱을 켤 때마다 강제로 로그아웃 처리
  // 이 코드가 있어야 앱 재실행 시 무조건 로그인 화면이 뜹니다.
  await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Inv',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // AuthWrapper가 로그인 상태를 감지하지만,
      // main()에서 이미 로그아웃을 시켰기 때문에 항상 LoginScreen으로 시작합니다.
      home: const LoginScreen(),
    );
  }
}
