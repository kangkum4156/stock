import 'package:flutter/material.dart';
import 'model_signup.dart';
import 'button_signup.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupViewModel _vm = SignupViewModel();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, child) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            // 뒤로가기 제어 로직이 필요하다면 여기에 작성
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('회원가입')),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                              child: Text('계정 생성하기',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold))),
                          const SizedBox(height: 30),
                          EmailInputSection(vm: _vm),
                          const SizedBox(height: 24),
                          PasswordInputSection(vm: _vm),
                          if (_vm.isVerificationSent && !_vm.isEmailVerified)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Center(
                                  child: Text(
                                    '인증 메일을 확인 중입니다...\n메일이 스팸으로 분류될 수 있습니다.',
                                    style: TextStyle(
                                        color: Colors.orange[800]),
                                    textAlign: TextAlign.center,
                                  )
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ---------------------------------------------------------
                  // [수정된 부분] 회원가입 버튼
                  // ---------------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        // async 키워드 추가
                        onPressed: _vm.isRegisterEnabled
                            ? () async {
                          // 1. ViewModel의 최종 가입 로직 실행
                          // (주의: finalRegister가 Future<bool>을 반환하도록 model_signup.dart를 수정하는 것을 권장합니다)
                          bool isSuccess = await _vm.finalRegister(context);

                          // 2. 성공 시 로그인 화면으로 복귀
                          if (isSuccess && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인 해주세요.')),
                            );
                            // 로그인 화면(이전 화면)으로 돌아가기
                            Navigator.pop(context);
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _vm.isRegisterEnabled
                              ? Colors.blueAccent
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('회원가입',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}