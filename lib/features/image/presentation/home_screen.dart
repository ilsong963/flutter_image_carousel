import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v2.dart' as googlrDrive;
import 'package:image_picker/image_picker.dart';

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
        googlrDrive.FileList list = await getListDriveFiles(accessToken!);

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

}
