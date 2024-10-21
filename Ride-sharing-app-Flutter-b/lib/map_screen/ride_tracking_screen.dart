import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:ui' as ui;

class RideTrackingScreen extends StatefulWidget {
  final String routesId;
  const RideTrackingScreen({super.key, required this.routesId});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final String googleAPiKey = "AIzaSyCdLAHV2BMZg_vfQcb8PZc9WggHr0w_U0A";

  DatabaseReference ref = FirebaseDatabase.instance.ref();
  final Location _locationController = Location();
  bool _isLoading = true;
  LatLng? _currentP;

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  Set<Marker> _stopsMarkers = {};
  PolylinePoints polylinePoints = PolylinePoints();

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
        // print(routes);
        // print("stops -->");
        // print(routes['stops']);
        stops = routes['stops'];
        addStopsMarker();
        _createPolylines(LatLng(origin['lat'], origin['long']),
            LatLng(dest['lat'], dest['long']));
        _isLoading = false;
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
              position: stopLatLng,
              infoWindow: InfoWindow(title: "stops $i"),
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
          addLiveLocation();
          print(_currentP);
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

  Future<Uint8List> markerImage() async {
    ByteData data = await rootBundle.load('assets/images/car.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // set markerImage
  void setMarkerImage() async {
    markIcon = await markerImage();
    setState(() {});
  }

  @override
  void initState() {
    getRoutesData();
    getLocationUpdates();
    setMarkerImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Map dest = convertStringToDouble(routes['destination']);
    // Map origin = convertStringToDouble(routes['origin']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text(
          "Ride Tracking",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : _currentP != null
              ? Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target:
                            LatLng(_currentP!.latitude, _currentP!.longitude),
                        zoom: 12,
                      ),
                      onMapCreated: (controller) {
                        _locationController;
                      },
                      markers: {
                        Marker(
                          position: _currentP!,
                          markerId: const MarkerId("driverLocation"),
                          icon: BitmapDescriptor.fromBytes(markIcon!),
                          infoWindow: const InfoWindow(title: "Driver"),
                        ),
                        Marker(
                          infoWindow: const InfoWindow(title: "Origin"),
                          position: LatLng(
                              convertStringToDouble(routes['origin'])['lat']!,
                              convertStringToDouble(routes['origin'])['long']!),
                          markerId: const MarkerId("originLocation"),
                          icon: BitmapDescriptor.defaultMarker,
                        ),
                        Marker(
                            infoWindow: const InfoWindow(title: "Destination"),
                            position: LatLng(
                                convertStringToDouble(
                                    routes['destination'])['lat']!,
                                convertStringToDouble(
                                    routes['destination'])['long']!),
                            markerId: const MarkerId("_destinationLocation"),
                            icon: BitmapDescriptor.defaultMarker),
                      }.union(_stopsMarkers),
                      polylines: _polylines,
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
    );
  }
}
