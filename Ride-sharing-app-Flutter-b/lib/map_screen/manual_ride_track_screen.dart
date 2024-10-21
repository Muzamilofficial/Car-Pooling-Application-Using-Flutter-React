import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils.dart/google_map_services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class ManualRideTrackScreen extends StatefulWidget {
  final Map<String, dynamic> location;
  final String riderId;
  const ManualRideTrackScreen(
      {super.key, required this.location, required this.riderId});

  @override
  State<ManualRideTrackScreen> createState() => _ManualRideTrackScreenState();
}

class _ManualRideTrackScreenState extends State<ManualRideTrackScreen> {
  final Location _locationController = Location();
  bool _isLoading = true;
  LatLng? _currentP;
  String _distance = '';
  String _duration = '';

  final GoogleMapsService _googleMapsService = GoogleMapsService();

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final String googleAPiKey = "AIzaSyCdLAHV2BMZg_vfQcb8PZc9WggHr0w_U0A";

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

  void getDriverLocation() async {
    // TODO: GetDriver Location
    // DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(widget.riderId).child("");
  }

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
      });
    } catch (e) {
      print('Error: $e');
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
          _isLoading = false;
          var destination = LatLng(widget.location['dropOff']['lat'],
              widget.location['dropOff']['lng']);
          _calculateDistanceAndTime(_currentP!, destination);
          print(_currentP);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
    _createPolylines(
      LatLng(
          widget.location['pickup']['lat'], widget.location['pickup']['lng']),
      LatLng(
          widget.location['dropOff']['lat'], widget.location['dropOff']['lng']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text(
          "Track Routes",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.location['pickup']['lat'],
                        widget.location['pickup']['lng']),
                    zoom: 12,
                  ),
                  onMapCreated: (controller) {
                    _locationController;
                  },
                  markers: {
                    Marker(
                      position: LatLng(widget.location['pickup']['lat'],
                          widget.location['pickup']['lng']),
                      markerId: const MarkerId("originLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                    Marker(
                      position: LatLng(widget.location['dropOff']['lat'],
                          widget.location['dropOff']['lng']),
                      markerId: const MarkerId("originLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                  },
                  polylines: _polylines,
                ),

                // Duration
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
            ),
    );
  }
}
