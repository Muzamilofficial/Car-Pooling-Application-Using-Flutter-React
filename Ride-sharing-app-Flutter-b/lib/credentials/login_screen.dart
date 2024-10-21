import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/singup_screen.dart';
import 'package:flutter_application_1/resetpassword.dart';
import 'package:flutter_application_1/user_mode/home_screen.dart';
import 'auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    String email = ''; // Define the email and password variables.
    String password = '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in to Drivecarte'),foregroundColor: Colors.white,
        backgroundColor: Colors.green[300],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/images/app-logo-main.png', // Replace with the path to your logo image asset.
                height: 200, // Adjust the height as needed.
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Open Sans',
                ),
              ),
              const SizedBox(height: 30),

              //
              // Styled email text field
              TextField(
                onChanged: (value) {
                  email = value;
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
                  password = value;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ResetPassword()),
                      );
                    },
                    child: const Text('Forgot Password'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  // Handle the login action here using the signIn function.
                  UserCredential? user =
                      await _authService.signIn(email, password);

                  if (user != null) {
                    Fluttertoast.showToast(
                        msg: "Login successfull",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    // Handle the login action here.
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  } else {
                    // Login failed, display an error message.
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text('Login failed.'),
                    //   ),
                    // );
                    Fluttertoast.showToast(
                       msg: "Login failed",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    print('Login failed');
                  }
                },
                // style: ElevatedButton.styleFrom(primary: Colors.green),
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
                child: const Text('Sign in', style:
                          TextStyle(color: Colors.white, fontSize: 16)),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to the signup screen here.
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text('Sign up'),
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
