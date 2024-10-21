import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/rider_mode/available_ride_screen.dart';
import 'add_schedule.dart';
import 'userprofile.dart';
import 'package:flutter_application_1/rider_mode/original_map.dart';
import 'package:flutter_application_1/rider_mode/schedulded.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MainScreene extends StatefulWidget {
  const MainScreene({Key? key}) : super(key: key);
  @override
  State<MainScreene> createState() => _MainScreeneState();
}

class _MainScreeneState extends State<MainScreene>
    with SingleTickerProviderStateMixin {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  bool isOnline = false;
  final Location _locationController = new Location();
  LatLng? _currentP;

  void updateDriverStatus() {
    String currentUser = AuthService.getCurrentUser()!.uid.toString();
    Map<String, Object> data = {"status": isOnline ? "Online" : "Offline"};
    ref.child('drivers').child(currentUser).update(data).catchError((e) {
      log("ERROR" + e);
    });
  }

  // get user status - Online/Offline
  void getStatus() async {
    String currentUser = AuthService.getCurrentUser()!.uid.toString();
    DataSnapshot statusSnapshot =
        await ref.child('drivers').child(currentUser).child('status').get();

    if (statusSnapshot.exists) {
      String status = statusSnapshot.value.toString();
      if (status == 'Online') {
        isOnline = true;
      } else {
        isOnline = false;
      }
    } else {
      isOnline = false;
    }
    setState(() {});
  }

  @override
  void initState() {
    getStatus();
    getLocationUpdates();
    super.initState();
  }

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.872477335184385, 67.03532103449106),
    zoom: 12,
  );
  Position? driverCurrentPosition;
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  TabController? tabController;
  int selectedIndex = 0;
  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text("Driver Mode"),
        actions: [
          Switch(
              activeColor: Colors.green,
              activeTrackColor: Colors.white,
              value: isOnline,
              onChanged: (value) {
                isOnline = !isOnline;
                setState(() {});
                updateDriverStatus();
                print(value);
              }),
          const SizedBox(width: 20),
        ],
      ),
      body: Stack(
        children: [
          _currentP == null
              ? const Center(
                  child: Text('Loading....'),
                )
              : GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;

                    Marker(
                        markerId: const MarkerId("_destinationLocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _currentP!);
                    const Marker(
                      markerId: MarkerId("_currentLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                    );
                    const Marker(
                        markerId: MarkerId("_sourceLocation"),
                        icon: BitmapDescriptor.defaultMarker);
                  },
                ),
          !isOnline
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: const Text("You are in Offline mode."),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(top: 540, right: 3),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          // Define the route you want to navigate to here.
                          // For example, you can navigate to a new screen.
                          return AvailableRideScreen();
                        }),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.green[300]),
                      minimumSize:
                          MaterialStateProperty.all(const Size(100, 60)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Available Rides',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isOnline
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                // Define the route you want to navigate to here.
                                // For example, you can navigate to a new screen.
                                return AddSchedule();
                              }),
                            );
                          }
                        : null,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.green[300]),
                      minimumSize:
                          MaterialStateProperty.all(const Size(70, 60)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_clock, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Add Schedule',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "location",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "account",
          ),
        ],
        onTap: (int index) {
          // Handle navigation based on the tapped item
          if (index == 3) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileManagement()),
            );
          }
          if (index == 0) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreene()),
            );
          }
          if (index == 1) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OriginalMap()),
            );
          }
          if (index == 2) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Scheduleded()),
            );
          }
        },

        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.green[300],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,

        // onTap: onItemClicked,
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
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(_currentP);
        });
      }
    });
  }
}
