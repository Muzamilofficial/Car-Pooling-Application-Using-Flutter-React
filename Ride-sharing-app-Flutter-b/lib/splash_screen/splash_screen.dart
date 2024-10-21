import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/main_screen.dart';
import 'package:flutter_application_1/user_mode/home_screen.dart';
import 'package:lottie/lottie.dart';
// import 'package:rider/main_screens/main_screen.dart'; // Import the main screen or the screen you want to navigate to after the Splash screen.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a time-consuming operation, like loading data or assets.
    // You can replace this with your own initialization code.
    isLogin();
  }

  void isLogin() async {
    if (AuthService.getCurrentUser() != null) {
      // login success
      Future.delayed(const Duration(seconds: 5), () {
        // Navigate to the main screen after the splash screen.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        // Navigate to the main screen after the splash screen.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                "assets/images/splashanimation.json",
                // width: 400,
                // height: 500,
                // fit: BoxFit.fill,
              ),
            ),
            // CircularProgressIndicator.adaptive(),
            Text(
              'DriveCarte',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[300]),
            ),
            const SizedBox(height: 90),
            Lottie.asset(
              "assets/images/loading.json",
              width: 90,
              height: 90,
            )
            // const CircularProgressIndicator.adaptive(
            //   valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            // ),
            // const CircularProgressIndicator(), // Loading indicator or any other widget.
          ],
        ),
      ),
    );
  }
}
