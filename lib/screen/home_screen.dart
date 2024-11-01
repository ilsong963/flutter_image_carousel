import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
      print(nextPage);
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
    imageList = [1, 2, 3, 4, 5].map((number) => Image.asset('asset/img/image_$number.jpeg', fit: BoxFit.cover)).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () => addImage(), child: const Icon(Icons.add)),
        body: PageView(
          controller: _pageController,
          children: imageList,
        ));
  }

  void addImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    imageList.add(Image.file(File(image.path), fit: BoxFit.cover));
  }
}
