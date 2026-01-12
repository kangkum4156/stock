library stock_inv.globals;

// 현재 로그인한 사용자의 이메일 (앱 전역에서 식별자로 사용)
String? user_email;

/*
lib/body/home_body.dart
HomeBody - 로그인 성공 후 보여지는 홈 화면 위젯
_HomeBodyState - 현재 접속한 이메일 표시 및 로그아웃 기능 처리

lib/signin/button_login.dart
LoginForm - 이메일, 비밀번호, 접속 코드를 입력받는 폼(Form) 위젯
_LoginFormState - 입력된 정보를 바탕으로 1차 로그인 및 2차 접속 코드 검증 실행

lib/signin/main_login.dart
LoginScreen - 앱 로고와 LoginForm을 배치하여 보여주는 전체 로그인 페이지
lib/signin/firebase_service_login.dart
AuthService - Firebase 인증(로그인, 가입)과 Firestore 데이터(코드 검증) 통신을 담당하는 기능 클래스

lib/signup/main_signup.dart
SignupScreen - 회원가입 화면 위젯
_SignupScreenState - 이메일과 비밀번호 입력을 받아 회원가입 요청을 처리

lib/signin/find_passward_login.dart
FindPassword - 비밀번호 재설정 화면 위젯
_FindPasswordState - 이메일을 입력받아 비밀번호 재설정 링크 발송 처리

lib/main.dart
MyApp - 앱의 전반적인 테마 설정 및 초기 실행 위젯
AuthWrapper - 로그인 여부를 판단하는 위젯
_AuthWrapperState - 실시간 인증 상태를 감지하여 로그인 화면 또는 홈 화면으로 자동 전환
 */