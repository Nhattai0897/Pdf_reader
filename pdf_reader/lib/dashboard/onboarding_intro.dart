import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pdf_reader/utils/base_multi_language.dart';

import 'dashboard_page.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    var conutPermissBox = Hive.box('introuctionBox');
    conutPermissBox.put('isFirst', false);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => DashboardHome()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      autoScrollDuration: 3000,
      globalFooter: Container(
        color: Color.fromRGBO(250, 127, 253, 0.85),
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: Text(
            'Let\'s go right away!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Edit your pdf files",
          body:
              "Insert images, text, sign, draw and share pdf files with everyone",
          image: Stack(
            children: [
              Image.asset('assets/bg_intro.jpg', width: 170),
              Positioned(
                bottom: 45,
                right: 25,
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    child: Image.asset('assets/future_intro.jpg', width: 115)),
              )
            ],
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Private file",
          body: "Allows you to hide files that you don't want anyone to see.",
          image: Stack(
            children: [
              Image.asset('assets/bg_intro.jpg', width: 170),
              Positioned(
                bottom: 35,
                right: 30,
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    child: Image.asset('assets/padlock-4.png', width: 50)),
              )
            ],
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get image from pdf",
          body: "allows to select and convert pdf files to images",
          image: Stack(
            children: [
              Image.asset('assets/bg_intro.jpg', width: 170),
              Positioned(
                bottom: 40,
                right: 28,
                child: Image.asset('assets/replace.png', width: 55),
              )
            ],
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text("This is the screen after Introduction")),
    );
  }
}
