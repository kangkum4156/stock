import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_inv/data/const_data.dart'; // user_email 변수가 있는 파일이라 가정

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------------------
  // [핵심] 현재 로그인된 계정이 Firestore(DB)에도 존재하는지 확인
  // ------------------------------------------------------------------------
  Future<bool> hasFirestoreData() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    try {
      // 'users' 컬렉션에서 내 이메일(ID)로 된 문서가 있는지 확인
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.email).get();
      return doc.exists; // 문서가 존재하면 true, 없으면 false (유령 계정)
    } catch (e) {
      print("DB 확인 중 오류: $e");
      return false;
    }
  }

  // ------------------------------------------------------------------------
  // 1. 회원가입 단계 1 (계정 생성 및 메일 발송)
  // ------------------------------------------------------------------------
  Future<User?> createAccountForVerification({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        try {
          await user.sendEmailVerification();
        } catch (e) {
          await user.delete();
          throw '이메일 주소가 올바르지 않아 인증 메일을 보낼 수 없습니다.';
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw '이미 사용 중인 이메일입니다.';
      if (e.code == 'invalid-email') throw '이메일 형식이 잘못되었습니다.';
      if (e.code == 'weak-password') throw '비밀번호는 8자리 이상이어야 합니다.';
      throw '계정 생성 실패: ${e.message}';
    } catch (e) {
      throw e.toString();
    }
  }

  // ------------------------------------------------------------------------
  // 2. 회원가입 취소 (잘못된 이메일 입력 시 호출)
  // ------------------------------------------------------------------------
  Future<void> cancelRegistration() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.delete();
    }
  }

  // ------------------------------------------------------------------------
  // 3. 이메일 인증 여부 확인
  // ------------------------------------------------------------------------
  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.reload();
        return user.emailVerified;
      } on FirebaseAuthException {
        return false;
      }
    }
    return false;
  }

  // ------------------------------------------------------------------------
  // 4. 최종 가입 완료 (비번 업데이트 및 DB 저장)
  // ------------------------------------------------------------------------
  Future<void> finalizeSignup({required String finalPassword}) async {
    User? user = _auth.currentUser;
    if (user == null) throw '인증된 사용자를 찾을 수 없습니다. 다시 시도해주세요.';

    try {
      await user.updatePassword(finalPassword);

      // ★ 이 시점에 DB 생성
      await _firestore.collection('users').doc(user.email).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': true,
      });
    } catch (e) {
      print("가입 마무리 실패: $e");
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
        print('이메일 인증이 완료되지 않았습니다.');
        return null;
      }

      user_email = email;
      return user;
    } catch (e) {
      return null;
    }
  }

  // ------------------------------------------------------------------------
  // 6. 기타 함수들
  // ------------------------------------------------------------------------
  Future<bool> verifyAccessCode(String inputCode) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('settings').doc('accessCode').get();
      if (!snapshot.exists) return false;
      return snapshot.get('code').toString().trim() == inputCode.trim();
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