import 'package:flutter/material.dart';
import 'package:flutter_application_1/user_mode/home_screen.dart';
import 'login_screen.dart'; // Import the login screen.
import 'package:flutter_application_1/otp.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application_1/rider_mode/car_info.dart';

void main() {
  var email = "fredrik@gmail.com";

  assert(EmailValidator.validate(email));
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
  static String? selectedType;
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  List<String> personType = ['Passenger', 'Driver'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up to Drivecarte'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[300],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Reuse the same styling for the logo and "Login as user" text.
              Image.asset(
                'assets/images/app-logo-main.png', // Replace with your logo image asset.
                height: 200,
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  // fontFamily: 'Open Sans',
                ),
              ),
              const SizedBox(height: 15),
              // Styled name text field
              TextField(
                onChanged: (value) {
                  nameController = TextEditingController(text: value);
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              // Styled email text field
              TextField(
                onChanged: (value) {
                  emailController = TextEditingController(text: value);
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Styled password text field
              TextField(
                onChanged: (value) {
                  passwordController = TextEditingController(text: value);
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                obscureText: true,
                maxLength: 8, // Hide the password text.
              ),
              const SizedBox(height: 16),
              // Styled phone number text field
              TextField(
                onChanged: (value) {
                  phoneNumberController = TextEditingController(text: value);
                },
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                maxLength: 11,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: SignupScreen.selectedType,
                onChanged: (value) {
                  setState(() {
                    SignupScreen.selectedType = value;
                  });
                },
                items: personType.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Call the signUp function from the authentication service.
                  String name = nameController.text;
                  String email = emailController.text;
                  String password = passwordController.text;
                  String phoneNumber = phoneNumberController.text;

                  // Call the signUp function and wait for the result.
                  UserCredential? result = await _authService.signUp(
                      email,
                      password,
                      name,
                      phoneNumber,
                      SignupScreen.selectedType.toString());

                  if (result != null) {
                    Fluttertoast.showToast(
                        msg: "Sign up successfull.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    if (SignupScreen.selectedType == "Driver") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CarInfoScreen()),
                      );
                    } else if (SignupScreen.selectedType == "Passenger") {
                      Navigator.of(context).push(
                        // MaterialPageRoute(
                        //     builder: (context) => const MyPhone()),
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: "Sign up failed.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
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
                child: const Text('Sign up',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to the login screen here.
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
