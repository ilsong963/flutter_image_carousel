import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../../service/http_service.dart';

class AuthRepository{

  final HttpService _httpService;
  late final GoogleSignIn _googleSignIn;
  late String accessToken;
  late AuthClient authClient;

  AuthRepository(this._googleSignIn, this._httpService);

Future<bool> isSignIn() async {
    return await _googleSignIn.isSignedIn();
  }
  AccessCredentials _getAccessCredentials() {
   return AccessCredentials(
      AccessToken('Bearer', accessToken, DateTime.now().add(const Duration(hours: 1)).toUtc()),
      null, // Refresh token 필요 없을 경우 null
      ['https://www.googleapis.com/auth/drive'],
    );

  }


  void setAuthClient() {
     authClient = authenticatedClient(_httpService.getHttpClients(), _getAccessCredentials());
  }

  void setScope(List<String> scopes){
    _googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/drive',
      ],
    );
  }

  Future<void> signIn() async {


    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // 사용자가 로그인 취소
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase 인증
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Access Token 출력
    accessToken = googleAuth.accessToken!;
  }
}
