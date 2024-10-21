import 'dart:async';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/utils.dart/google_map_services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;

class UserRideTrackingScreen extends StatefulWidget {
  final String routesId;
  final String driverId;
  const UserRideTrackingScreen(
      {super.key, required this.routesId, required this.driverId});

  @override
  State<UserRideTrackingScreen> createState() => _UserRideTrackingScreenState();
}

class _UserRideTrackingScreenState extends State<UserRideTrackingScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  final Location _locationController = Location();
  LatLng? _currentP;
  String _distance = '';
  String _duration = '';
  Set<Marker> _stopsMarkers = {};
  final GoogleMapsService _googleMapsService = GoogleMapsService();

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final String googleAPiKey = "AIzaSyCdLAHV2BMZg_vfQcb8PZc9WggHr0w_U0A";

  Future<void> _calculateDistanceAndTime(
      LatLng _origin, LatLng _destination) async {
    final String origin = '${_origin.latitude},${_origin.longitude}';
    final String destination =
        '${_destination.latitude},${_destination.longitude}';
    try {
      final result =
          await _googleMapsService.getDistanceTime(origin, destination);
      setState(() {
        _distance = result['distance'];
        _duration = result['duration'];

        // Log Duration
        log("Duration $_duration");
        // print(""_duration);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _createPolylines(LatLng start, LatLng destination) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId("polyline"),
        width: 5,
        color: Colors.blue,
        points: polylineCoordinates,
      ));
    });
  }

//  map images

  Future<Uint8List> markerImage() async {
    ByteData data = await rootBundle.load('assets/images/car.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // get Routes Data
  Map routes = {};
  List stops = [];

  void getRoutesData() async {
    DataSnapshot snapshot =
        await ref.child('routesnew').child(widget.routesId).get();
    if (snapshot.exists) {
      setState(() {
        routes = snapshot.value as Map;
        Map origin = convertStringToDouble(routes['origin']);
        Map dest = convertStringToDouble(routes['destination']);
        print(routes);
        print("stops -->");
        print(routes['stops']);
        stops = routes['stops'];
        addStopsMarker();
        _createPolylines(LatLng(origin['lat'], origin['long']),
            LatLng(dest['lat'], dest['long']));
      });
    } else {
      log("No Routes Found");
    }
  }

  addStopsMarker() {
    var i = 1;
    for (var stop in stops) {
      LatLng stopLatLng = LatLng(stop['lat'], stop['lng']);
      setState(() {
        _stopsMarkers.add(
          Marker(
              infoWindow: InfoWindow(title: "Stop $i"),
              position: stopLatLng,
              markerId: MarkerId("stops$i"),
              icon: BitmapDescriptor.defaultMarker,
              onTap: () {
                print("stops$i");
              }),
        );
      });
      i++;
    }
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return Future.error("Permission is Denied");
    }

    permissionGranted = await _locationController.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted == PermissionStatus.granted) {
        return Future.error("Permission is Granted");
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          log("Current");
          // print(_currentP);
          // print(routes['destination']);
          double dest_lat = double.parse(
              routes['destination'].toString().split(', ')[0].toString());
          double dest_long = double.parse(
              routes['destination'].toString().split(', ')[1].toString());
          LatLng destination = LatLng(dest_lat, dest_long);
          _calculateDistanceAndTime(_currentP!, destination);
          // add live location to driver database
          // addLiveLocation();
          // print(_currentP);
        });
      }
    });
  }

  // convert String to double
  Map<String, double> convertStringToDouble(String locations) {
    double lat = double.parse(locations.split(', ')[0]);
    double long = double.parse(locations.split(', ')[1]);
    return {"lat": lat, "long": long};
  }

  // add live location to driver database
  void addLiveLocation() {
    String currentUser = AuthService.getCurrentUser()!.uid.toString();
    ref.child("drivers").child(currentUser).update(
      {"location": "${_currentP!.latitude}, ${_currentP!.longitude}"},
    ).then((value) {
      log("Data Updated");
    }).catchError((e) {
      log("Error");
    });
  }

  Uint8List? markIcon;

  // set markerImage
  void setMarkerImage() async {
    markIcon = await markerImage();
    setState(() {});
  }

  @override
  void initState() {
    getRoutesData();
    setMarkerImage();
    // setPolyLines();
    getLocationUpdates();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("Markers : " + _stopsMarkers.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text(
          "Ride Tracking",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _currentP != null
          ? StreamBuilder(
              stream: ref
                  .child('drivers')
                  .child(widget.driverId)
                  .child('location')
                  .onValue,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  ); // Display a loading spinner
                }
                Map dest = convertStringToDouble(routes['destination']);
                Map origin = convertStringToDouble(routes['origin']);

                // Extract data from snapshot
                DataSnapshot data = snapshot.data.snapshot;
                print("DATA ---> " + data.value.toString());
                double lat = double.parse(data.value.toString().split(', ')[0]);
                double long =
                    double.parse(data.value.toString().split(', ')[1]);
                return Stack(
                  children: [
                    GoogleMap(
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(origin['lat'], origin['long']),
                          zoom: 13),
                      onMapCreated: (controller) {
                        _locationController;
                      },
                      polylines: _polylines,
                      markers: {
                        Marker(
                            infoWindow: const InfoWindow(title: "Destination"),
                            position: LatLng(dest['lat'], dest['long']),
                            markerId: const MarkerId("_destinationLocation"),
                            icon: BitmapDescriptor.defaultMarker,
                            onTap: () {
                              print("Destination");
                            }),
                        Marker(
                            infoWindow: const InfoWindow(title: "Origin"),
                            position: LatLng(origin['lat'], origin['long']),
                            markerId: const MarkerId("originLocation"),
                            icon: BitmapDescriptor.defaultMarker,
                            onTap: () {
                              print("Origin");
                            }),
                        // Driver Location
                        Marker(
                            position: LatLng(lat, long),
                            markerId: const MarkerId("driverLocation"),
                            icon: BitmapDescriptor.fromBytes(markIcon!),
                            infoWindow: const InfoWindow(title: "Driver"),
                            onTap: () {
                              print("Driver");
                            }),
                      }.union(_stopsMarkers),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 10,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Card(
                            color: Colors.green[100],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Distance: $_distance'),
                                  Text('Duration: $_duration'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              })
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
    );
  }
}
