// ignore_for_file: camel_case_types

// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class intropage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                "assets/images/screen1.json",
              ),
            ),
            // CircularProgressIndicator.adaptive(),
            Text(
              'Discover Carpools',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[300]),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Create your account and share your ride preferences. \n Find carpools that match your schedule.',
              textAlign:
                  TextAlign.center, // or TextAlign.left for left alignment
              strutStyle: StrutStyle(
                height: 1.3, // Adjust the line height
              ),
            )
          ],
        ),
      ),
    );
  }
}
