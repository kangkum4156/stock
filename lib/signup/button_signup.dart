// signup_components.dart
import 'package:flutter/material.dart';
import 'model_signup.dart'; // 위에서 만든 로직 파일 import

// 1. 이메일 입력 + 버튼 Row
class EmailInputSection extends StatelessWidget {
  final SignupViewModel vm; // 로직 덩어리를 통째로 받음

  const EmailInputSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: vm.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                enabled: !vm.isVerificationSent, // 로직 상태에 따라 제어
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 50,
              child: _buildButton(context),
            ),
          ],
        ),
        if (vm.isVerificationSent && !vm.isEmailVerified)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              '메일이 오지 않나요? 오타가 있다면 [취소/수정]을 눌러주세요.',
              style: TextStyle(color: Colors.red[400], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    if (vm.isChecking) {
      return ElevatedButton(
        onPressed: null,
        child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (vm.isEmailVerified) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('완료', style: TextStyle(color: Colors.white)),
      );
    }
    if (vm.isVerificationSent) {
      return OutlinedButton(
        onPressed: () => vm.cancelRegistration(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Text('취소/수정'),
      );
    }
    return ElevatedButton(
      onPressed: () => vm.verifyEmail(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      child: const Text('인증'),
    );
  }
}

// 2. 비밀번호 입력 섹션
class PasswordInputSection extends StatelessWidget {
  final SignupViewModel vm;

  const PasswordInputSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    bool formatOk = vm.isPwFormatValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: vm.pwCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '비밀번호',
            border: OutlineInputBorder(),
          ),
        ),
        if (!formatOk && vm.pwCtrl.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              '영문, 숫자를 포함하여 8자 이상 입력해주세요.',
              style: TextStyle(color: Colors.red[400], fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: vm.pwConfirmCtrl,
          obscureText: true,
          enabled: formatOk,
          decoration: InputDecoration(
            labelText: '비밀번호 재확인',
            border: const OutlineInputBorder(),
            filled: !formatOk,
            fillColor: !formatOk ? Colors.grey[200] : null,
            errorText: (formatOk && vm.pwConfirmCtrl.text.isNotEmpty && !vm.isPwMatch)
                ? '비밀번호가 일치하지 않습니다.'
                : null,
          ),
        ),
      ],
    );
  }
}