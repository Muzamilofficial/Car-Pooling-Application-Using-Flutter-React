// import 'package:flutter/widgets.dart';
// import 'package:flutter_application_1/credentials/login_screen.dart';
// import 'package:flutter_application_1/onboardingscreen.dart';
// import 'package:lottie/lottie.dart';
// import 'package:flutter/material.dart';

// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Padding(
//           padding: const EdgeInsets.only(top: 10.0), // Adjust the top padding.
//           child: Text(
//             'DriveCarte',
//             style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green[300]),
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [

//             Lottie.asset(
//               'assets/images/animatedlogo.json',
//               // height: 100,
//               // width: 900,
//             ),

//             // const SizedBox(height: 25),
//             // const Text(
//             //   '',
//             //   style: TextStyle(fontSize: 20),
//             // ),
//             // const SizedBox(height: 20),
//             // const IntroSequence(),

//             const SizedBox(
//                 height: 60), // Custom widget for swipeable intro screens.
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the LoginScreen when "Let's go" is clicked.
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//                 backgroundColor: Colors.green[300],
//                 shape: RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(20.0), // Set the border radius
//                 ),
//                 fixedSize: const Size(200.0, 50.0),
//               ), // Change button color to red.

//               child: const Text(
//                 "Sign in",
//                 style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the LoginScreen when "Let's go" is clicked.
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (context) => OnBoardingScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//                 backgroundColor:
//                     Colors.green[300], // Change button color to red.
//                 shape: RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(20.0), // Set the border radius
//                 ),
//                 fixedSize: const Size(200.0, 50.0),
//               ),
//               child: const Text(
//                 "Sign up",
//                 style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_1/onboardingscreen.dart';

// Color myColor = hexToColor('#50c878');
// backgroundcolor: myColor,
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: AppBar(
      //   title: Padding(
      //     padding: const EdgeInsets.only(top: 10.0), // Adjust the top padding.
      //     child: Text(
      //       'Welcome to DriveCarte',
      //       style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green[300]),
      //     ),
      //   ),
      //   centerTitle: true,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app-logo-main.png', // Replace with your logo image asset.
              height: 300, width: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              '',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // IntroSequence(),

            const SizedBox(
                height: 60), // Custom widget for swipeable intro screens.
            ElevatedButton(
              onPressed: () {
                // Navigate to the LoginScreen when "Let's go" is clicked.
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                backgroundColor:
                    Colors.green[300], // Change button color to red.
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // Set the border radius
                ),
                fixedSize: const Size(300.0, 50.0),
              ),
              child: const Text(
                "Let's go",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
