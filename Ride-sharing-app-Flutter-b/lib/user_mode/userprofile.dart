import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileManagement extends StatefulWidget {
  @override
  _ProfileManagementState createState() => _ProfileManagementState();
}

class _ProfileManagementState extends State<ProfileManagement> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _ref = FirebaseDatabase.instance.reference();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _updateUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      final userId = user.uid;
      try {
        await user.updatePassword(_passwordController.text);

        _ref.child('users').child(userId).update({
          'id': userId,
          'name': _nameController.text,
          'phoneNumber': _phoneController.text,
        });

        _ref.child('drivers').child(userId).update({
          'id': userId,
          'name': _nameController.text,
          'phoneNumber': _phoneController.text,
        });

        Fluttertoast.showToast(
            msg: "Profile updated successfully.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Failed to update profile: $e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      print('User not signed in');
    }
  }

  void getUserData() async {
    User? user = _auth.currentUser;
    final userId = user!.uid;
    DataSnapshot userSnapshot = await _ref.child('drivers').child(userId).get();
    if (userSnapshot.exists) {
      Map user = userSnapshot.value as Map;
      _nameController.text = user['name'];
      _phoneController.text = user['phoneNumber'];
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: Colors.green[300],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    )),
                maxLength: 15),
            const SizedBox(height: 16.0),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    )),
                maxLength: 8,
                obscureText: true),
            const SizedBox(height: 16.0),
            TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    )),
                maxLength: 11),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: const Text('Update'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                foregroundColor: Colors.white,
                backgroundColor:
                    Colors.green[300], // Change button color to red.
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // Set the border radius
                ),
                fixedSize: const Size(400.0, 50.0),
              ),
              // style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
