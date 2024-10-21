import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class intropage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                "assets/images/screen3.json",
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            // CircularProgressIndicator.adaptive(),
            Text(
              '24/7 Accessibility',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[300]),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Our service is available around the clock. Enjoy the \n flexibility of booking rides whenever you need them.',
              textAlign: TextAlign.center,
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
