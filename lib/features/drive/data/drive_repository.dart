import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/drive/v2.dart' as googlrDrive;

import 'package:path_provider/path_provider.dart';



class DriveRepository {
  late final googlrDrive.DriveApi _driveApi;
  DriveRepository(this._driveApi);


  // Google Drive API 객체 생성
  void setDriveApi(AuthClient authClient) {
    _driveApi = googlrDrive.DriveApi(authClient);
  }

  // Google Drive 파일 목록 가져오기
  Future<googlrDrive.FileList> getDriveFileList() async {
    return await _driveApi.files.list();
  }

  Future<File> downLoadFile(googlrDrive.File driveFile) async {
    googlrDrive.Media media = await _driveApi.files.get(driveFile.id!, downloadOptions: googlrDrive.DownloadOptions.fullMedia) as googlrDrive.Media;

    List<int> data = [];

    await media.stream.forEach((element) {
      data.addAll(element);
    });

    File file = File(await _getDownloadDirPath(driveFile.title!));
    file.writeAsBytesSync(data);
    return file;
  }

  Future<String> _getDownloadDirPath(String fileTitle) async {
    String? downloadDirPath;
    if (Platform.isAndroid) {
      downloadDirPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
      Directory dir = Directory(downloadDirPath);

      if (!dir.existsSync()) {
        downloadDirPath = (await getExternalStorageDirectory())!.path;
      }
    } else if (Platform.isIOS) {
      downloadDirPath = (await getApplicationDocumentsDirectory()).path;
    }
    return "${downloadDirPath!}/$fileTitle";
  }
}
