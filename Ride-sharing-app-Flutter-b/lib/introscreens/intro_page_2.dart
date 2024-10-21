import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class intropage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                "assets/images/screen2.json",
              ),
            ),
            const SizedBox(
              height: 20,
            ), // CircularProgressIndicator.adaptive(),
            Text(
              'Convenient Rides',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[300]),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Book rides hassle-free. Experience comfort and \n convenience while sharing rides with others.',
              textAlign:
                  TextAlign.center, // or TextAlign.left for left alignment
              strutStyle: StrutStyle(
                height: 1.3,
              ),
            )
          ],
        ),
      ),
    );
  }
}
