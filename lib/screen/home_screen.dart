import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  Timer.periodic(const Duration(seconds: 3), (timer) {

    int? nextPage = _pageController.page?.toInt();
    if(nextPage == null){
      return;
    }

    if(nextPage >= 4) {
      nextPage = 0;
    }
    else{
      nextPage++;
    }
    _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
        body: PageView(
          controller: _pageController,
          children: [1, 2, 3, 4, 5].map((number) => Image.asset('asset/img/image_$number.jpeg',
              fit:BoxFit.cover)).toList(),
        ));
  }
}



