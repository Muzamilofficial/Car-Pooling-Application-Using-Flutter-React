import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/singup_screen.dart';
import 'package:flutter_application_1/introscreens/intro_page_1.dart';
import 'package:flutter_application_1/introscreens/intro_page_2.dart';
import 'package:flutter_application_1/introscreens/intro_page_3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  bool onLastpage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              onLastpage = index == 2;
            });
          },
          children: [intropage1(), intropage2(), intropage3()],
        ),
        Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return SignupScreen();
                      })));
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 17, color: Colors.green[300]),
                    )),
                SmoothPageIndicator(controller: _controller, count: 3),
                onLastpage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SignupScreen();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Done',
                          style:
                              TextStyle(fontSize: 17, color: Colors.green[300]),
                        ))
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: Text(
                          'Next',
                          style:
                              TextStyle(fontSize: 17, color: Colors.green[300]),
                        )),
              ],
            )),
      ],
    ));
  }
}
