import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'google_auth_client.dart';

class BackUpRepository {

  //로그인
  Future<GoogleSignInAccount?> signIn() async {
    GoogleSignIn googleSignIn =
    GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

    return await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
  }

  //로그아웃
  Future<void> signOut() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  Future<drive.DriveApi?> getDriveApi(
      GoogleSignInAccount googleSignInAccount) async {
    final header = await googleSignInAccount.authHeaders;
    GoogleAuthClient googleAuthClient = GoogleAuthClient(header: header);
    return drive.DriveApi(googleAuthClient);
  }

  Future<File> downLoad(
      {required String driveFileId,
        required drive.DriveApi driveApi,
        required String localPath}) async {
    drive.Media media = await driveApi.files.get(driveFileId,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

    List<int> data = [];

    await media.stream.forEach((element) {
      data.addAll(element);
    });

    File file = File(localPath);
    file.writeAsBytesSync(data);

    return file;
  }

}