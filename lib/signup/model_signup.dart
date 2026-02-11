// model_signup.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_inv/signin/firebase_service_login.dart';

class SignupViewModel extends ChangeNotifier {
  final authService = AuthService();

  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  final pwConfirmCtrl = TextEditingController();

  // 상태 변수
  bool isVerificationSent = false;
  bool isEmailVerified = false;
  bool isChecking = false;

  // [핵심] 최종 가입 성공 여부를 체크하는 플래그
  // 이 값이 false인 상태에서 화면이 꺼지면(dispose) 계정을 삭제합니다.
  bool _isFinalSuccess = false;

  Timer? _timer;

  SignupViewModel() {
    pwCtrl.addListener(notifyListeners);
    pwConfirmCtrl.addListener(notifyListeners);
  }

  // ------------------------------------------------------------------------
  // 화면이 꺼질 때(dispose) '성공한 가입'이 아니면 유령 계정 삭제
  // ------------------------------------------------------------------------
  @override
  void dispose() {
    _timer?.cancel();

    // 이메일 인증은 시도했으나(_isVerificationSent),
    // 최종 가입 완료 도장(_isFinalSuccess)을 못 받았다면 -> 가입 중단으로 간주하고 삭제
    if (isVerificationSent && !_isFinalSuccess) {
      print("회원가입 중도 포기: 임시 계정을 삭제합니다.");
      authService.cancelRegistration();
    }

    emailCtrl.dispose();
    pwCtrl.dispose();
    pwConfirmCtrl.dispose();
    super.dispose();
  }

  // 비밀번호 정규식 검사 (영문+숫자 8자리 이상)
  bool get isPwFormatValid {
    RegExp regExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return regExp.hasMatch(pwCtrl.text);
  }

  // 비밀번호 일치 여부
  bool get isPwMatch => pwCtrl.text.isNotEmpty && (pwCtrl.text == pwConfirmCtrl.text);

  // 버튼 활성화 여부
  bool get isRegisterEnabled => isEmailVerified && isPwFormatValid && isPwMatch;

  // 1. 이메일 인증 시작 (임시 계정 생성 -> 메일 발송)
  Future<void> verifyEmail(BuildContext context) async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnackBar(context, '이메일을 입력해주세요.');
      return;
    }

    _setLoading(true);

    try {
      // Firebase 규칙: 메일을 보내려면 일단 계정이 있어야 함 (임시 비번으로 생성)
      await authService.createAccountForVerification(
        email: email,
        password: "TempPass1234!@",
      );

      isVerificationSent = true;
      _setLoading(false);

      if (context.mounted) _showSnackBar(context, '📧 인증 메일 발송! 메일함을 확인해주세요.');
      _startTimer(context);

    } catch (e) {
      _setLoading(false);
      String errorMsg = '오류가 발생했습니다.';
      if (e.toString().contains('invalid-email')) {
        errorMsg = '이메일 형식이 올바르지 않습니다.';
      } else if (e.toString().contains('email-already-in-use')) {
        errorMsg = '이미 사용 중인 이메일입니다.';
      }
      if (context.mounted) _showSnackBar(context, errorMsg);
    }
  }

  // 2. 사용자가 직접 취소 버튼 누름
  Future<void> cancelRegistration(BuildContext context) async {
    _setLoading(true);
    try {
      await authService.cancelRegistration();
    } catch (e) {
      print("삭제 중 에러(무시 가능): $e");
    }
    _timer?.cancel();

    isVerificationSent = false;
    isEmailVerified = false;
    _setLoading(false);

    if (context.mounted) _showSnackBar(context, '🔄 초기화되었습니다.');
  }

  // 3. 타이머 로직 (이메일 인증 확인)
  void _startTimer(BuildContext context) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!context.mounted) {
        timer.cancel();
        return;
      }

      try {
        bool verified = await authService.checkEmailVerified();
        if (verified) {
          timer.cancel();
          isEmailVerified = true;
          notifyListeners();
          if (context.mounted) _showSnackBar(context, '✅ 인증 완료! 비밀번호를 설정해주세요.');
        }
      } catch (e) {
        timer.cancel();
      }
    });
  }

  // ------------------------------------------------------------------------
  // [수정됨] 4. 최종 가입 (성공 시 true 반환)
  // ------------------------------------------------------------------------
  Future<bool> finalRegister(BuildContext context) async {
    if (!isPwFormatValid) return false;

    _setLoading(true);
    try {
      // 진짜 비밀번호로 업데이트 및 DB 저장
      await authService.finalizeSignup(finalPassword: pwCtrl.text.trim());

      // ★ 성공 플래그 true (그래야 dispose 될 때 계정이 삭제 안 됨)
      _isFinalSuccess = true;

      // 여기서 Navigator.pop을 하지 않고 true만 반환합니다.
      // 화면 이동은 View(UI) 파일에서 처리합니다.
      return true;

    } catch (e) {
      if (context.mounted) _showSnackBar(context, '가입 마무리 중 오류: $e');
      return false; // 실패 반환
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isChecking = value;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}