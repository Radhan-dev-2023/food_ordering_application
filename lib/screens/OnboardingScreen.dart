
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../Screens/LoginScreen.dart';


class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({Key? key}) : super(key: key);
  final PageController _pageController = PageController(initialPage: 0);

  final List<PageViewModel> pages = [
    PageViewModel(
      title: '\nAll Your Favorites !',
      body:
          '\nGet all your loved foods in one place,you just place the order we do the rest',
      image: Center(
        child: Image.asset('assets/images/onb1.png'),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.orange),
        bodyTextStyle: TextStyle(
            fontSize: 22,
            height: 1.5,
            fontWeight: FontWeight.bold,
            color: Colors.brown),
      ),
    ),
    PageViewModel(
        title: '\nAccess Everywhere !',
        body:
            '\nLocate your address,choose your favorite foods with our restaurants',
        image: Center(
          child:Image.network("https://lh3.googleusercontent.com/7JD9FBO0w1Spmxu8jr9Ebd9tKonhyaxNqJybfm6_3pVf8mXCQSC_dZMcBwPD90x-Bwk")
          //Image.asset('assets/images/onb2.png'),
        ),
        decoration: const PageDecoration(
            titleTextStyle: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange),
            bodyTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.5,
                color: Colors.brown))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 80, 12, 12),
        child: IntroductionScreen(
          pages: pages,
          dotsDecorator: const DotsDecorator(
            size: Size(8, 8),
            color: Colors.orange,
            activeSize: Size.square(15),
            activeColor: Colors.black12,
          ),
          showDoneButton: true,
          done: const Text(
            ' Done',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          showSkipButton: true,
          skip: InkWell(
            onTap: (){
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MobileLogin()));
            },
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          showNextButton: true,
          next: const Icon(
            Icons.arrow_forward,
            size: 25,
            color: Colors.black54,
          ),
          onDone: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MobileLogin()));
          },
          curve: Curves.bounceOut,
        ),
      ),
    );
  }
}
