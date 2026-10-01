import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google 로그인 결과를 담는 객체.
class GoogleAuthResult {
  const GoogleAuthResult({
    this.uid,
    this.email,
    this.displayName,
    this.errorMessage,
  });

  final String? uid;
  final String? email;
  final String? displayName;

  /// 로그인 실패 시 원인. 'cancelled' = 사용자가 로그인을 취소함.
  final String? errorMessage;

  bool get success => uid != null;
}

/// Google 로그인 / 로그아웃을 담당하는 서비스 (google_sign_in 7.x API).
///
/// - [signIn]: Google 계정을 선택한 뒤 Firebase Auth에 인증한다.
/// - [signOut]: Firebase Auth와 Google 모두에서 로그아웃한다.
class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void>? _initFuture;

  /// [GoogleSignIn.initialize]는 반드시 앱 전체에서 한 번만 호출해야 한다.
  Future<void> _ensureInitialized() =>
      _initFuture ??= _googleSignIn.initialize(
        serverClientId: '101704680480-stqj0k4u5ive5amfltoqiqvc0e0itr2c.apps.googleusercontent.com',
      );

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  Future<GoogleAuthResult> signIn() async {
    try {
      await _ensureInitialized();

      // 이전 로그인 상태를 정리해 계정 선택 화면이 항상 표시되도록 한다.
      await _googleSignIn.signOut();

      final account = await _googleSignIn.authenticate();
      final auth = await account.authentication; // 💡 await 추가
      final idToken = auth.idToken;
      if (idToken == null) {
        return const GoogleAuthResult(errorMessage: 'no_id_token');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      return GoogleAuthResult(
        uid: user?.uid,
        email: user?.email,
        displayName: user?.displayName,
      );
    } on GoogleSignInException catch (e) {
      // 사용자가 다이얼로그를 닫거나 취소한 경우
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
        case GoogleSignInExceptionCode.uiUnavailable:
          return const GoogleAuthResult(errorMessage: 'cancelled');
        default:
          return GoogleAuthResult(errorMessage: e.toString());
      }
    } on Exception catch (e) {
      return GoogleAuthResult(errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}