import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 직접 사용
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
  // 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // 로그인 처리 로직
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
      // [NEW] 1.5단계: 유령 계정 체크 (인증은 됐으나 DB가 없는 경우 로그인 방지)
      bool hasData = await _authService.hasFirestoreData();

      if (!hasData) {
        // 유령 계정임 -> 로그아웃 시키고 가입 안내
        await _authService.signOut();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되지 않은 계정입니다. [회원가입] 버튼을 눌러 다시 가입해주세요.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 2단계: Firestore 접속 코드 검증 (정상 유저인 경우)
      final isCodeValid = await _authService.verifyAccessCode(code);

      if (isCodeValid) {
        // [성공] 홈 화면으로 이동
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeBody()),
        );
      } else {
        // [실패] 코드가 틀림 -> 로그아웃
        await _authService.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('접속 코드가 올바르지 않습니다.')),
        );
      }
    } else {
      // [실패] 이메일/비번 틀림
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 실패. 계정 정보를 확인하세요.')),
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
            labelText: '이메일',
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
            labelText: '비밀번호',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        // 접속 코드 입력
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: '접속 코드',
            prefixIcon: Icon(Icons.vpn_key),
            border: OutlineInputBorder(),
            hintText: '전달받은 접속 코드를 입력하세요',
          ),
        ),

        // 비밀번호 찾기
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
                : const Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),

        // ------------------------------------------------------------------
        // [핵심 기능] 회원가입 버튼 (유령 계정 삭제 로직 적용)
        // ------------------------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () async {
              User? currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser != null) {
                try {
                  await currentUser.reload(); // 최신 상태 갱신

                  // Case 1: 이메일 인증을 아예 안 한 경우 -> 삭제
                  if (!currentUser.emailVerified) {
                    print("🧹 미인증 계정 삭제");
                    await currentUser.delete();
                  }
                  // Case 2: 인증은 했지만(Verified), DB에 정보가 없는 경우 -> 삭제 (NEW)
                  else {
                    bool hasData = await _authService.hasFirestoreData();
                    if (!hasData) {
                      print("👻 인증된 유령 계정(DB 없음) 삭제");
                      await currentUser.delete();
                    } else {
                      // DB도 있고 정상 계정이면 삭제하면 안됨! 그냥 로그아웃만.
                      await FirebaseAuth.instance.signOut();
                    }
                  }
                } catch (e) {
                  // 삭제 실패 시(토큰 만료 등) -> 로그아웃이라도 시켜서 초기화
                  print("⚠️ 청소 실패(로그아웃 진행): $e");
                  await FirebaseAuth.instance.signOut();
                }
              }

              // 청소가 끝난 후, 깨끗한 상태로 회원가입 화면 이동
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              }
            },
            child: const Text('회원가입'),
          ),
        ),
      ],
    );
  }
}