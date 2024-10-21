import 'dart:async';

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'userprofile.dart';
import 'schedulded.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OriginalMap extends StatefulWidget {
  const OriginalMap({Key? key}) : super(key: key);
  @override
  State<OriginalMap> createState() => _OriginalMap();
}

class _OriginalMap extends State<OriginalMap>
    with SingleTickerProviderStateMixin {
  final Location _locationController = new Location();
  LatLng? _currentP = null;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
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
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              //black theme google map

              const Marker(
                  markerId: MarkerId("_destinationLocation"),
                  icon: BitmapDescriptor.defaultMarker);
              // Check This Later
              // Marker(
              //     markerId: const MarkerId("_currentLocation"),
              //     icon: BitmapDescriptor.defaultMarker,
              //     position: _currentP!);
              const Marker(
                  markerId: MarkerId("_sourceLocation"),
                  icon: BitmapDescriptor.defaultMarker);
            },
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
            label: "Account",
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
              MaterialPageRoute(builder: (context) => MainScreene()),
            );
          }
          if (index == 1) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OriginalMap()),
            );
          }
          if (index == 2) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Scheduleded()),
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
