import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_inv/data/const_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------------------
  // 1. [회원가입 단계 1] 계정 생성 및 인증 메일 발송
  // ------------------------------------------------------------------------
  Future<User?> createAccountForVerification({
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;

    try {
      // 1) 계정 생성
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // 2) 인증 메일 발송
      if (user != null) {
        try {
          await user.sendEmailVerification();
        } catch (e) {
          // 메일 발송 자체가 실패하면 계정 삭제 (자동 롤백)
          await user.delete();
          throw '이메일 주소가 올바르지 않아 인증 메일을 보낼 수 없습니다.';
        }
      }

      return user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        throw '이메일 형식이 잘못되었습니다.';
      } else if (e.code == 'weak-password') {
        throw '비밀번호는 6자리 이상이어야 합니다.';
      }
      throw '계정 생성 실패: ${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  // ------------------------------------------------------------------------
  // 2. [NEW] 회원가입 취소 (잘못된 이메일 입력 시 호출)
  // ------------------------------------------------------------------------
  Future<void> cancelRegistration() async {
    User? user = _auth.currentUser;
    // 유저가 있고, 아직 인증되지 않은 상태라면 삭제 진행
    if (user != null && !user.emailVerified) {
      await user.delete();
    }
  }

  // ------------------------------------------------------------------------
  // 3. [회원가입 단계 2] 이메일 인증 여부 확인 (타이머용)
  // ------------------------------------------------------------------------
  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.reload(); // 최신 상태 갱신
        return user.emailVerified;
      } on FirebaseAuthException {
        // 유저가 삭제되었거나 세션이 만료된 경우
        return false;
      }
    }
    return false;
  }

  // ------------------------------------------------------------------------
  // 4. [회원가입 단계 3] 최종 가입 완료 (비번 업데이트 및 DB 저장)
  // ------------------------------------------------------------------------
  Future<void> finalizeSignup({required String finalPassword}) async {
    User? user = _auth.currentUser;
    if (user == null) throw '인증된 사용자를 찾을 수 없습니다. 다시 시도해주세요.';

    try {
      // 최종 입력한 비밀번호로 변경
      await user.updatePassword(finalPassword);

      // Firestore 저장
      await _firestore.collection('users').doc(user.email).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': true,
      });

    } catch (e) {
      print("⚠️ 가입 마무리 실패: $e");
      throw '회원가입 마무리 중 오류가 발생했습니다.';
    }
  }

  // ------------------------------------------------------------------------
  // 5. 로그인 (이메일 인증 체크 포함)
  // ------------------------------------------------------------------------
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        print('❌ 이메일 인증이 완료되지 않았습니다.');
        return null;
      }

      user_email = email;
      return user;

    } catch (e) {
      return null;
    }
  }

  // ------------------------------------------------------------------------
  // 6. 기타 함수들 (접속코드, 로그아웃 등)
  // ------------------------------------------------------------------------
  Future<bool> verifyAccessCode(String inputCode) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('settings').doc('accessCode').get();
      if (!snapshot.exists) return false;
      String serverCode = snapshot.get('code').toString();
      return serverCode.trim() == inputCode.trim();
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user_email = null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}