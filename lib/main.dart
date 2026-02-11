import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stock_inv/firebase_options.dart';
import 'package:stock_inv/signin/main_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // [수정 완료]
  // 앱 시작 시 강제 로그아웃(signOut) 코드를 제거했습니다.
  // 이유: 유령 계정(가입 중단자) 상태를 유지해야,
  //       로그인 화면의 [회원가입] 버튼을 누를 때 감지해서 삭제할 수 있기 때문입니다.

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
      home: const LoginScreen(),
    );
  }
}