import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/credentials/singup_screen.dart';
import 'package:flutter_application_1/user_mode/home_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_screen.dart';
import 'package:flutter_application_1/otp.dart';

class CarInfoScreen extends StatefulWidget {
  @override
  _CarInfoScreenState createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _modelController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  List<String> carTypeList = ["Car AC", "Car Non-AC"];
  String selectedCarType = 'Car AC';

  Future<void> _saveCarInfo() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String model = _modelController.text;
      String color = _colorController.text;
      String number = _numberController.text;
      String type = selectedCarType;

      try {
        await _database.child('drivers/${user.uid}/car_details').set({
          'car_model': model,
          'car_color': color,
          'car_number': number,
          'type': type,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car information saved.')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save car info.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  "assets/images/app-logo-main.png",
                  height: 190,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Please enter your\ncar details",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                strutStyle: StrutStyle(
                  height: 2,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    hintText: 'eg: Civic',
                    labelText: 'Car Model',
                    suffixIcon: Icon(
                      Icons.check,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    hintText: 'eg: XYZ 007',
                    labelText: 'Car No.',
                    suffixIcon: Icon(
                      Icons.check,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    hintText: 'eg: Black',
                    labelText: 'Car Color',
                    suffixIcon: Icon(
                      Icons.check,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                child: DropdownButton(
                  iconSize: 26,
                  dropdownColor: Colors.white,
                  hint: const Text(
                    "Your Car Type",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  value: selectedCarType,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCarType = newValue.toString();
                    });
                  },
                  items: carTypeList.map((car) {
                    return DropdownMenuItem(
                      child: Text(
                        car,
                        style: const TextStyle(color: Colors.black),
                      ),
                      value: car,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _saveCarInfo();
                  Fluttertoast.showToast(
                      msg: "Car Info Saved",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green[300],
                      textColor: Colors.white,
                      fontSize: 16.0);

                  if (SignupScreen.selectedType == "Driver") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => const MyPhone(),
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainScreene()));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300],
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  fixedSize: const Size(200, 50),
                  elevation: 0, // Adjust the shadow elevation
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _numberController.dispose();
    _typeController.dispose();
    super.dispose();
  }
}
