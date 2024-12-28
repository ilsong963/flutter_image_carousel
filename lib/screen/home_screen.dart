import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as googledrive;
import 'package:googleapis_auth/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../auth/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum ImageType {
  gallery('gallery', Icon(Icons.photo)),
  web('web', Icon(Icons.web)),
  googleDrive('googleDrive', Icon(Icons.cloud));

  final String name;
  final Icon icon;

  const ImageType(this.name, this.icon);
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  List<Widget> imageList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initializeImage();

    Timer.periodic(const Duration(seconds: 3), (timer) {
      int? nextPage = _pageController.page?.toInt();
      log(nextPage.toString());
      if (nextPage == null) {
        return;
      }

      if (nextPage >= imageList.length - 1) {
        nextPage = 0;
      } else {
        nextPage++;
      }
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  _initializeImage() {
    imageList =
        [1, 2, 3, 4, 5].map((number) => Image.asset('asset/img/image_$number.jpeg', fit: BoxFit.cover)).toList();
  }

  String? accessToken;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () => showAddImageDialog(), child: const Icon(Icons.add)),
        body: PageView(
          controller: _pageController,
          children: imageList,
        ));
  }

  void showAddImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageDialogListTile(ImageType.gallery),
              _imageDialogListTile(ImageType.web),
              _imageDialogListTile(ImageType.googleDrive),
            ],
          ),
        );
      },
    );
  }

  Widget _imageDialogListTile(ImageType imageType) {
    return ListTile(
      leading: imageType.icon,
      title: Text(imageType.name),
      onTap: () {
        _addImage(imageType);
      },
    );
  }

  void _addImage(ImageType imageType) async {
    Widget? newImage;
    switch (imageType) {
      case ImageType.gallery:
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) {
          return;
        }
        newImage = Image.file(File(image.path), fit: BoxFit.cover);

        break;
      case ImageType.web:
        newImage = Image.network('https://picsum.photos/200/300', fit: BoxFit.cover);
        break;
      case ImageType.googleDrive:
        signInWithGoogle();
        googledrive.FileList list = await getListDriveFiles(accessToken!);

        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select File'),
              content: SizedBox(
                height: 300,
                width: 300,
                child: ListView.builder(
                  itemCount: list.items!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        children: [
                          list.items![index].thumbnailLink != null
                              ? Image.network(list.items![index].thumbnailLink!, width: 50, height: 50)
                              : const SizedBox(width: 50, height: 50),
                          Expanded(child: Text(list.items![index].title!))
                        ],
                      ),
                      onTap: () async {
                        showDialog(
                            context: context, builder: (context) => const Center(child: CircularProgressIndicator()));

                        File file = await downLoad(list.items![index]);
                        newImage = Image.file(file, fit: BoxFit.cover);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
        imageList.add(newImage!);

        break;
    }
  }


  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/drive',
      ],
    );

    //이미 로그인되어 있는 경우
    googleSignIn.isSignedIn().then((isSignedIn) {
      return;
    });

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
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
    print('Access Token: ${googleAuth.accessToken}');
    accessToken = googleAuth.accessToken;
  }

  Future<googledrive.FileList> getListDriveFiles(String accessToken) async {
    final credentials = AccessCredentials(
      AccessToken('Bearer', accessToken, DateTime.now().add(const Duration(hours: 1)).toUtc()),
      null, // Refresh token 필요 없을 경우 null
      ['https://www.googleapis.com/auth/drive'],
    );

    final authClient = authenticatedClient(http.Client(), credentials);

    // Google Drive API 객체 생성
    final driveApi = googledrive.DriveApi(authClient);

    // Google Drive 파일 목록 가져오기
    return await driveApi.files.list();
  }

  Future<File> downLoad(googledrive.File driveFile) async {
    final credentials = AccessCredentials(
      AccessToken('Bearer', accessToken!, DateTime.now().add(const Duration(hours: 1)).toUtc()),
      null, // Refresh token 필요 없을 경우 null
      ['https://www.googleapis.com/auth/drive'],
    );

    final authClient = authenticatedClient(http.Client(), credentials);

    // Google Drive API 객체 생성
    final driveApi = googledrive.DriveApi(authClient);


    googledrive.Media media = await driveApi.files
        .get(driveFile.id!, downloadOptions: googledrive.DownloadOptions.fullMedia) as googledrive.Media;

    List<int> data = [];

    await media.stream.forEach((element) {
      data.addAll(element);
    });
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
    File file = File("${downloadDirPath!}/${driveFile.title!}");
    file.writeAsBytesSync(data);

    return file;
  }
}
