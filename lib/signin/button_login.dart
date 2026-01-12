import 'package:flutter/material.dart';
import 'package:stock_inv/body/home_body.dart';
import 'package:stock_inv/signin/find_passward_login.dart';
import 'package:stock_inv/signin/firebase_service_login.dart';
import 'package:stock_inv/signup/main_signup.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // 컨트롤러: 이메일, 비밀번호, 그리고 접속 코드
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final pw = _passwordController.text.trim();
    final code = _codeController.text.trim();

    if (email.isEmpty || pw.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일, 비밀번호, 접속 코드를 모두 입력하세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1단계: Firebase Auth 로그인 (이메일/비번 확인)
    final user = await _authService.signIn(email, pw);

    if (user != null) {
      // 2단계: Firestore 접속 코드 검증
      final isCodeValid = await _authService.verifyAccessCode(code);

      if (isCodeValid) {
        // [성공] 홈 화면으로 이동
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeBody()),
        );
      } else {
        // [실패] 코드가 틀리면 로그아웃 처리 후 경고
        await _authService.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 접속 코드가 올바르지 않습니다.')),
        );
      }
    } else {
      // [실패] 이메일/비번 틀림
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 로그인 실패. 계정 정보를 확인하세요.')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 이메일 입력
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        // 비밀번호 입력
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        // 접속 코드 입력 (여기에 1234567 입력해야 함)
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Access Code',
            prefixIcon: Icon(Icons.vpn_key),
            border: OutlineInputBorder(),
            hintText: '전달받은 접속 코드를 입력하세요',
          ),
        ),

        // 비밀번호 찾기 링크
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindPassword()),
              );
            },
            child: const Text('비밀번호를 잊으셨나요?'),
          ),
        ),
        const SizedBox(height: 20),

        // 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),

        // 회원가입 이동 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: const Text('Sign Up'),
          ),
        ),
      ],
    );
  }
}