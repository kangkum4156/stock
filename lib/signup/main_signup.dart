import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_inv/signin/firebase_service_login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();

  final _authService = AuthService();

  // 상태 변수들
  bool _isVerificationSent = false; // 메일 발송 여부
  bool _isEmailVerified = false;    // 인증 완료 여부
  bool _isChecking = false;         // 로딩 표시용
  Timer? _timer;                    // 3초 확인 타이머

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------------
  // 1. [인증] 버튼 클릭
  // ------------------------------------------------------------------------
  void _onVerifyEmailPressed() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이메일을 입력해주세요.')));
      return;
    }

    setState(() => _isChecking = true);

    try {
      // 비밀번호가 비어있으면 임시 비밀번호 사용
      String tempPassword = _pwCtrl.text.isEmpty ? "TempPass1234!@" : _pwCtrl.text.trim();

      await _authService.createAccountForVerification(
          email: email,
          password: tempPassword
      );

      // 성공 시 상태 업데이트
      setState(() {
        _isVerificationSent = true;
        _isChecking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📧 인증 메일 발송! 메일함을 확인해주세요.')),
      );

      // 타이머 시작
      _startVerificationCheckTimer();

    } catch (e) {
      // 실패 시 리셋
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    }
  }

  // ------------------------------------------------------------------------
  // 2. [취소/수정] 버튼 클릭 (NEW: 사용자가 직접 리셋)
  // ------------------------------------------------------------------------
  void _onCancelPressed() async {
    setState(() => _isChecking = true);

    try {
      // 1) Firebase에서 계정 삭제
      await _authService.cancelRegistration();
    } catch (e) {
      // 이미 삭제되었거나 에러가 나도, UI 리셋은 진행
      print("삭제 중 에러(무시 가능): $e");
    }

    // 2) 타이머 중지
    _timer?.cancel();

    // 3) UI 상태 완전 초기화 (처음으로 되돌림)
    setState(() {
      _isVerificationSent = false; // 이메일 입력창 다시 활성화
      _isEmailVerified = false;
      _isChecking = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔄 초기화되었습니다. 이메일을 다시 입력하세요.')),
    );
  }

  // ------------------------------------------------------------------------
  // 3. 타이머 (3초마다 확인)
  // ------------------------------------------------------------------------
  void _startVerificationCheckTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      bool isVerified = await _authService.checkEmailVerified();
      if (isVerified) {
        timer.cancel();
        setState(() {
          _isEmailVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 인증 완료! 비밀번호 확인 후 가입 버튼을 눌러주세요.')),
        );
      }
    });
  }

  // ------------------------------------------------------------------------
  // 4. [Sign Up] 버튼 (최종 가입)
  // ------------------------------------------------------------------------
  void _onFinalRegisterPressed() async {
    final finalPassword = _pwCtrl.text.trim();

    if (finalPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호를 입력해주세요.')));
      return;
    }

    setState(() => _isChecking = true);

    try {
      await _authService.finalizeSignup(finalPassword: finalPassword);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 회원가입 완료! 로그인해주세요.')));
      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool pwMatch = _pwCtrl.text.isNotEmpty && (_pwCtrl.text == _pwConfirmCtrl.text);
    // 이메일 인증됨 AND 비밀번호 일치함 -> 가입 버튼 활성화
    bool isRegisterButtonEnabled = _isEmailVerified && pwMatch;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // [이메일 입력 Row]
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    // 인증 메일 보낸 뒤에는 수정 막음 (취소 버튼 눌러야 풀림)
                    enabled: !_isVerificationSent,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 버튼 영역 (상태에 따라 3가지 모양으로 변함)
                SizedBox(
                  height: 50,
                  child: Builder(
                    builder: (context) {
                      // 1. 로딩 중일 때
                      if (_isChecking) {
                        return ElevatedButton(
                          onPressed: null,
                          child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }

                      // 2. 인증 완료되었을 때
                      if (_isEmailVerified) {
                        return ElevatedButton(
                          onPressed: null, // 클릭 불가
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('완료', style: TextStyle(color: Colors.white)),
                        );
                      }

                      // 3. 메일은 보냈는데 아직 인증 안 된 경우 (취소/수정 버튼 표시)
                      if (_isVerificationSent) {
                        return OutlinedButton(
                          onPressed: _onCancelPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('취소/수정'),
                        );
                      }

                      // 4. 기본 상태 (인증 버튼)
                      return ElevatedButton(
                        onPressed: _onVerifyEmailPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('인증'),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 안내 문구 (메일 안 올 때 팁)
            if (_isVerificationSent && !_isEmailVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '메일이 오지 않나요? 오타가 있다면 [취소/수정]을 눌러주세요.',
                    style: TextStyle(color: Colors.red[400], fontSize: 12),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // [비밀번호 입력]
            TextField(
              controller: _pwCtrl,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwConfirmCtrl,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                errorText: (_pwConfirmCtrl.text.isNotEmpty && !pwMatch) ? '비밀번호가 일치하지 않습니다.' : null,
              ),
            ),
            const SizedBox(height: 30),

            // [Sign Up 버튼]
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isRegisterButtonEnabled ? _onFinalRegisterPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRegisterButtonEnabled ? Colors.blueAccent : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Up'),
              ),
            ),

            // 상태 메시지
            if (_isVerificationSent && !_isEmailVerified)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('인증 메일을 확인 중입니다...', style: TextStyle(color: Colors.orange[800])),
              ),
          ],
        ),
      ),
    );
  }
}