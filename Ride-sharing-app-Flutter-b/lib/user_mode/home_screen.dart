import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/rider_mode/home_screen.dart';
import 'package:flutter_application_1/user_mode/places_list_screen.dart';
import 'package:flutter_application_1/user_mode/user_booking.dart';
import 'package:flutter_application_1/user_mode/user_history_screen.dart';
import 'package:flutter_application_1/utils.dart/const.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_application_1/credentials/login_screen.dart';
import 'view_schedules.dart';
import 'userprofile.dart';
import 'package:flutter_application_1/rider_mode/car_info.dart';
import 'package:uuid/uuid.dart';
import "package:http/http.dart" as http;

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController dropLocationController = TextEditingController();

  var uuid = const Uuid();
  String _sessionToken = "12345";

  GoogleMapController? mapController;
  final Location _locationController = Location();
  LatLng? _currentP = null;
  String? selectedCarType;
  String? selectedPassengerType;
  List<String> carTypes = ['Car AC', 'Car Non-AC'];
  List<String> passengerTypes = ['1', '2', '3', '4'];

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  List<dynamic> placesList = [];

  // On Driver Request
  void onDriverRrquest() async {
    String rideId = ref.child('rideRequest').push().key.toString();
    String currentUser = AuthService.getCurrentUser()!.uid.toString();
    Map<String, Object> request = {
      "requestId": rideId,
      "rideStatus": bookingStatus['pending']!,
      "pickupLocation": pickupLocationController.text,
      "dropOffLocation": dropLocationController.text,
      "noOfPassengers": selectedPassengerType.toString(),
      "CarType": selectedCarType.toString(),
    };

    ref.child('rideRequest').child(rideId).set(request).then((value) {
      pickupLocationController.clear();
      dropLocationController.clear();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Ride Request"),
            content: const Text("Your Request has been sent"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Ok"))
            ],
          );
        },
      );
    }).catchError((e) {
      log("ERROR -> $e");
    });

    // Update User

    DataSnapshot rideSnap =
        await ref.child('users').child(currentUser).child('rideRequest').get();

    List userRides = [];
    if (rideSnap.exists) {
      List ridesID = rideSnap.value as List;
      userRides.addAll(ridesID);
    }

    userRides.add(rideId);

    ref.child('users').child(currentUser).update({"rideRequest": userRides});
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggestion(pickupLocationController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyCdLAHV2BMZg_vfQcb8PZc9WggHr0w_U0A";

    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request = "$baseUrl?input=$input&key=$kPLACES_API_KEY";

    var response = await http.get(Uri.parse(request));

    print(response.body.toString());
    if (response.statusCode == 200) {
      print("Success");
      setState(() {
        placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      log(response.statusCode.toString());
      throw Exception("Failed to load Data");
    }
  }

  String dataFromSecondScreen = '';

  Future<void> _navigateAndGetData(
      BuildContext context, Widget screen, bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result != null) {
      if (isPickup) {
        setState(() {
          dataFromSecondScreen = result;
          pickupLocationController.text = result;
          print(result);
        });
      } else {
        dropLocationController.text = result;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    getLocationUpdates();

    // pickupLocationController.addListener(() {
    //   onChange();
    // });
  }

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 20,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green[300],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 540,
              child: GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;

                  const Marker(
                      markerId: MarkerId("_destinationLocation"),
                      icon: BitmapDescriptor.defaultMarker);
                  // TODO: SEE LATER
                  // Marker(
                  //     markerId: const MarkerId("_currentLocation"),
                  //     icon: BitmapDescriptor.defaultMarker,
                  //     position: _currentP!);
                  const Marker(
                      markerId: MarkerId("_sourceLocation"),
                      icon: BitmapDescriptor.defaultMarker);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  top: 550, right: 20, bottom: 40, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    onTap: () {
                      _navigateAndGetData(
                        context,
                        const PlacesListScreen(),
                        true,
                      );
                    },
                    readOnly: true,
                    controller: pickupLocationController,
                    decoration: InputDecoration(
                      labelText: 'Pick Up Location',
                      prefixIcon: const Icon(Icons.location_on),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 9.0),
                  TextFormField(
                    onTap: () {
                      _navigateAndGetData(
                        context,
                        const PlacesListScreen(),
                        false,
                      );
                    },
                    readOnly: true,
                    controller: dropLocationController,
                    decoration: InputDecoration(
                      labelText: 'Drop Off Location',
                      prefixIcon: const Icon(Icons.pin_drop),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 9.0),
                  DropdownButtonFormField<String>(
                    value: selectedPassengerType,
                    onChanged: (value) {
                      setState(() {
                        selectedPassengerType = value;
                      });
                    },
                    items: passengerTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type,
                            style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Passengers',
                      prefixIcon: const Icon(Icons.people),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 9.0),
                  DropdownButtonFormField<String>(
                    value: selectedCarType,
                    onChanged: (value) {
                      setState(() {
                        selectedCarType = value;
                      });
                    },
                    items: carTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type,
                            style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Choose Car Type',
                      prefixIcon: const Icon(Icons.car_rental),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      // on driver request
                      onDriverRrquest();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      backgroundColor: Colors.green[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      fixedSize: const Size(300.0, 50.0),
                    ),
                    child: const Text('Find a driver',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: FutureBuilder(
          future: fetchUserName(),
          builder: (context, snapshot) {
            String userName = snapshot.data ?? "User";
            return Column(
              // padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                    ),
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Update Profile'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileManagement(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('History'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UserHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Schedules'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ViewSchedulesScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Bookings'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UserBookingScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: const Text('Driver mode'),
                        onTap: () async {
                          User? user = _auth.currentUser;
                          if (user != null) {
                            final DatabaseReference Ref = FirebaseDatabase
                                .instance
                                .reference()
                                .child('drivers/${user.uid}/car_details');
                            Ref.onValue.listen((event) {
                              final DataSnapshot snapshot = event.snapshot;
                              final Map<dynamic, dynamic>? values =
                                  snapshot.value as Map?;
                              if (values != null) {
                                // User data exists under 'car_details' node
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreene(),
                                  ),
                                );
                              } else {
                                // User data doesn't exist under 'car_details' node
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CarInfoScreen(),
                                  ),
                                );
                              }
                            });
                          }
                        }),
                  ],
                ),
                const Spacer(),
                ListTile(
                  tileColor: Colors.green,
                  textColor: Colors.white,
                  leading: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  title: const Text('Sign out'),
                  onTap: () {
                    AuthService().signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        return;
      }
    }

    // TODO: Error Resolve
    // _locationController.onLocationChanged
    //     .listen((LocationData currentLocation) {
    //   if (currentLocation.latitude != null &&
    //       currentLocation.longitude != null) {
    //     setState(() {
    //       _currentP =
    //           LatLng(currentLocation.latitude!, currentLocation.longitude!);
    //       print(_currentP);
    //     });
    //   }
    // });
  }

  Future<String?> fetchUserName() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      final DatabaseReference userRef =
          FirebaseDatabase.instance.reference().child('users/${user.uid}/name');

      DatabaseEvent event = await userRef.once(); // Use DatabaseEvent

      if (event.snapshot.value != null) {
        return event.snapshot.value.toString(); // Access snapshot property
      }
    }
    return null;
  }
}
