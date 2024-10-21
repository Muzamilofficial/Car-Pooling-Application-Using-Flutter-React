
import 'package:flutter/material.dart';
import 'package:flutter_application_1/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';

// ignore: deprecated_member_use
final DatabaseReference databaseReference =
    FirebaseDatabase.instance.reference();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var email = "fredrik@gmail.com";
  assert(EmailValidator.validate(email));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carpool App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Set SplashScreen as the initial screen.
      debugShowCheckedModeBanner: false,
    );
  }
}
