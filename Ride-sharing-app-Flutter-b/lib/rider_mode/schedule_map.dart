// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_application_1/main_screens/route_details.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class SchedulePostingMap extends StatefulWidget {
//   @override
//   _ScheduleMapState createState() => _ScheduleMapState();
// }

// class _ScheduleMapState extends State<SchedulePostingMap> {
//   Set<Marker> _markers = {};
//   LatLng? _origin;
//   LatLng? _destination;
//   List<LatLng> _stops = [];

//   GoogleMapController? mapController;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Route'),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.green[300],
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Text('Save Route'),
//                     content: Text('Do you want to save the route?'),
//                     actions: [
//                       TextButton(
//                         child: Text('Cancel'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                       TextButton(
//                         child: Text('Save'),
//                         onPressed: () {
//                           saveRoute();
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () {
//               setState(() {
//                 _markers.clear();
//                 _origin = null;
//                 _destination = null;
//                 _stops.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       //       onPressed: () {
//       //         saveRoute();
//       //       },

//       //     ),
//       //   ],
//       // ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         markers: _markers,
//         polylines: {
//           if (_origin != null && _destination != null)
//             Polyline(
//               polylineId: PolylineId('route'),
//               color: const Color.fromARGB(255, 7, 79, 205),
//               width: 5,

//               points: [
//                 if (_origin != null) _origin!,
//                 ..._stops,
//                 if (_destination != null) _destination!
//               ],
//               geodesic: true,
//               startCap: Cap.roundCap,
//               endCap: Cap.roundCap,

//             ),
//         },
//         onTap: _onMapTap,
//         initialCameraPosition: CameraPosition(
//           target: LatLng(
//               24.8607, 67.0011), // Initial camera position (Karachi)
//           zoom: 10,
//         ),
//       ),
//     );
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     setState(() {
//       mapController = controller;
//     });
//   }

//   void _onMapTap(LatLng tappedPoint) {
//     setState(() {
//       // Adding marker at the tapped point
//       _markers.add(Marker(
//         markerId: MarkerId(tappedPoint.toString()),
//         position: tappedPoint,
//         icon: BitmapDescriptor.defaultMarker,
//       ));

//       // Adding tapped point to stops
//       _stops.add(tappedPoint);

//       // Set origin and destination based on the first and last stops
//       _origin = _stops.first;
//       _destination = _stops.last;

//       // Remove previous markers and add the updated set of markers
//       _markers.clear();
//       _markers.add(Marker(
//         markerId: MarkerId('origin'),
//         position: _origin!,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       ));
//       _markers.add(Marker(
//         markerId: MarkerId('destination'),
//         position: _destination!,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ));
//       _markers.addAll(_stops.map((stop) => Marker(
//             markerId: MarkerId(stop.toString()),
//             position: stop,
//             icon: BitmapDescriptor.defaultMarker,
//           )));

//       // Move camera to fit all markers
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngBounds(
//           LatLngBounds(
//             southwest: LatLng(_origin!.latitude, _origin!.longitude),
//             northeast: LatLng(_destination!.latitude, _destination!.longitude),
//           ),
//           100.0, // Padding
//         ),
//       );
//     });
//   }

//   void saveRoute() {
//     // Save the schedule details, including origin, destination, stops, date, time, and other information
//     // You can use Firebase to store this information or any other storage solution based on your requirements.
//     final DatabaseReference routeRef =
//         FirebaseDatabase.instance.reference().child('routes');

//     if (_origin == null || _destination == null) {
//       // Handle the case where origin or destination is not selected
//       Fluttertoast.showToast(
//         msg: 'Please select both origin and destination on the map.',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       return;
//     }
//     // Create a RouteDetails object with the necessary information
//     RouteDetails routeDetails = RouteDetails(
//       _origin!.latitude.toString() + ', ' + _origin!.longitude.toString(),
//       _destination!.latitude.toString() +
//           ', ' +
//           _destination!.longitude.toString(),
//       [
//         {'lat': _origin!.latitude, 'lng': _origin!.longitude},
//         // Add stops similarly
//         {'lat': _destination!.latitude, 'lng': _destination!.longitude},
//       ],
//     );

//     // Convert RouteDetails to JSON
//     Map<String, dynamic> routeMap = routeDetails.toJson();

//     // Save route details to Firebase
//     routeRef.push().set(routeMap);

//     // For this example, we'll just show a toast message.
//     Fluttertoast.showToast(
//       msg: 'Route saved successfully!',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );

//     // After saving, navigate back to the previous screen (AddSchedule)
//     Navigator.pop(context);
//   }
// }

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/rider_mode/home_screen.dart';
import 'package:flutter_application_1/user_mode/home_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SetTravelRouteScreen extends StatefulWidget {
  const SetTravelRouteScreen({super.key, required this.scheduleId});
  final String scheduleId;

  @override
  State<SetTravelRouteScreen> createState() => _SetTravelRouteScreenState();
}

class _SetTravelRouteScreenState extends State<SetTravelRouteScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  // List<LatLng> _polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  LatLng? _origin;
  LatLng? _destination;
  final List<LatLng> _stops = [];

  // onSave
  void onSave() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Route'),
          content: const Text('Do you want to save the route?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                //saveRoute();
                _saveRouteToDatabase();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//  save route to database
  void _saveRouteToDatabase() {
    if (_origin != null && _destination != null && _stops.isNotEmpty) {
      DatabaseReference routesRef =
          FirebaseDatabase.instance.ref().child('routesnew');

      // Create a unique ID for the route
      String? routeId = routesRef.push().key;

      // Construct route data
      Map<String, dynamic> routeData = {
        'origin': '${_origin!.latitude}, ${_origin!.longitude}',
        'destination': '${_destination!.latitude}, ${_destination!.longitude}',
        'stops': _stops
            .map((stop) => {'lat': stop.latitude, 'lng': stop.longitude})
            .toList(),
      };

      // Save the route to Firebase
      routesRef.child(routeId!).set(routeData).then((value) {
        print('Route saved successfully with ID: $routeId');
        // Perform any additional actions after saving the route

        // Save routeId to the corresponding schedule in the 'schedules' node
        DatabaseReference schedulesRef =
            FirebaseDatabase.instance.ref().child('schedules');
        schedulesRef.child(widget.scheduleId).update({
          'routeId': routeId,
        });

        Fluttertoast.showToast(
          msg: 'Route saved successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        // Go to Home Screen Rider Side
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return const MainScreene();
          },
        ));
      }).catchError((error) {
        print('Failed to save route: $error');
        // Handle the error
        // close the alert dialog box
        Navigator.pop(context);
      });
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Please Select your routes',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

// onDelete
  void onDelete() {
    setState(() {
      _markers.clear();
      _origin = null;
      _destination = null;
      _stops.clear();
      polylines.clear();
      Fluttertoast.showToast(
        msg: 'Route cleared successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Travel Route'),
        backgroundColor: Colors.green[300],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: onSave),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _getCurrentLocation(); // Fetch the device's current location
        },
        markers: _markers,
        polylines: Set<Polyline>.of(polylines.values),
        initialCameraPosition: CameraPosition(
          target: LatLng(24.8607, 67.0011),
          zoom: 15,
        ),
        onTap: (LatLng position) {
          _onMapTap(position);
        },
      ),
    );
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _origin = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(
        markerId: MarkerId('origin'),
        position: _origin!,
        infoWindow: InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _onMapTap(LatLng position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 160,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text('Set as Origin'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _origin = position;
                      _markers.add(Marker(
                        markerId: MarkerId('origin'),
                        position: _origin!,
                        infoWindow: InfoWindow(title: 'Origin'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                      ));
                    });
                  },
                ),
                ListTile(
                  title: Text('Set as Destination'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _destination = position;
                      _markers.add(Marker(
                        markerId: MarkerId('destination'),
                        position: _destination!,
                        infoWindow: InfoWindow(title: 'Destination'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure),
                      ));
                      _drawRoute();
                    });
                  },
                ),
                ListTile(
                  title: Text('Set as Stop'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (_stops.length < 4) {
                        _stops.add(position);
                        _markers.add(Marker(
                          markerId: MarkerId('stop${_stops.length}'),
                          position: position,
                          infoWindow:
                              InfoWindow(title: 'Stop ${_stops.length}'),
                          icon: BitmapDescriptor.defaultMarker,
                        ));
                        _drawRoute();
                      } else {
                        // Show a message or alert that the maximum number of stops is reached
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Maximum Number of Stops Reached'),
                              content: Text('You can only add up to 4 stops.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//   void _drawRoute() async {
//   if (_origin != null && _destination != null) {
//      print('Origin Coordinates: ${_origin!.latitude}, ${_origin!.longitude}');
//     print('Destination Coordinates: ${_destination!.latitude}, ${_destination!.longitude}');

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       'AIzaSyDl1pFZteFPZBB2vH2f8BHm6zplU0fp7xI', // Replace with your Google Maps API key
//       PointLatLng(_origin!.latitude, _origin!.longitude),
//       PointLatLng(_destination!.latitude, _destination!.longitude),
//     );

//     if (result.points.isNotEmpty) {
//       _polylineCoordinates = result.points
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList();

//       PolylineId id = PolylineId('route');
//       Polyline polyline = Polyline(
//         polylineId: id,
//         color: Colors.blue,
//         points: _polylineCoordinates,
//         width: 5,
//       );
//       setState(() {
//         polylines[id] = polyline;
//       });
//     }
//   }
// }

  void _drawRoute() {
    if (_origin != null && _destination != null) {
      // Manually create LatLng points for the route
      List<LatLng> routePoints = [_origin!, ..._stops, _destination!];

      PolylineId id = PolylineId('route');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Color.fromARGB(255, 7, 79, 205),
        points: routePoints,
        width: 5,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );

      setState(() {
        polylines[id] = polyline;
      });
      _animatePolyline(id);
    }
  }

  void _animatePolyline(PolylineId id) async {
    GoogleMapController controller = await _controller.future;
    int _duration = 5000;

    // Zoom out animation
    await Future.delayed(Duration(milliseconds: 1000));
    // controller.animateCamera(CameraUpdate.zoomOut());
    //zoom out to fit all the route coordinates
    controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          _origin!.latitude <= _destination!.latitude
              ? _origin!.latitude
              : _destination!.latitude,
          _origin!.longitude <= _destination!.longitude
              ? _origin!.longitude
              : _destination!.longitude,
        ),
        northeast: LatLng(
          _origin!.latitude >= _destination!.latitude
              ? _origin!.latitude
              : _destination!.latitude,
          _origin!.longitude >= _destination!.longitude
              ? _origin!.longitude
              : _destination!.longitude,
        ),
      ),
      100.0, // padding
    ));

    // Additional logic or actions after zoom-out can be added here

    // // Delay before zooming back in
    // await Future.delayed(Duration(milliseconds: 1000));

    // // Zoom in animation
    // controller.animateCamera(CameraUpdate.zoomIn());
  }

/*
// void _animatePolyline(PolylineId id) async {
//   GoogleMapController controller = await _controller.future;
//   int _duration = 5000;
//   double _speed = 2;
//   double _interval = _duration / (1000 / _speed);
//   List<LatLng> _routeCoords = polylines[id]!.points;
//   double _distance = 0;
//   for (int i = 0; i < _routeCoords.length - 1; i++) {
//     _distance += Geolocator.distanceBetween(
//       _routeCoords[i].latitude,
//       _routeCoords[i].longitude,
//       _routeCoords[i + 1].latitude,
//       _routeCoords[i + 1].longitude,
//     );
//   }
//   double _durationPerInterval = _duration / _interval;
//   double _distancePerInterval = _distance / _interval;
//   double _distanceTravelled = 0;
//   double _durationTravelled = 0;
//   Set<Marker> _carMarker = {};
//   LatLng _carPosition = _routeCoords[0];
//   _carMarker.add(Marker(
//     markerId: MarkerId('car'),
//     position: _carPosition,
//     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//   ));
//   setState(() {
//     _markers.addAll(_carMarker);
//   });
//   Timer.periodic(Duration(milliseconds: _durationPerInterval.toInt()), (timer) {
//     if (_distanceTravelled < _distance) {
//       _distanceTravelled += _distancePerInterval;
//       _durationTravelled += _durationPerInterval;
//       double t = _distanceTravelled / _distance;
//       LatLng interpolatedPosition = LatLng(
//         lerpDouble(_carPosition.latitude, _routeCoords[1].latitude, t)!,
//         lerpDouble(_carPosition.longitude, _routeCoords[1].longitude, t)!,
//       );
//       setState(() {
//         _carPosition = interpolatedPosition;
//         _markers.removeWhere((marker) => marker.markerId.value == 'car');
//         _markers.add(Marker(
//           markerId: MarkerId('car'),
//           position: _carPosition,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//         ));
//       });
//       controller.animateCamera(CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: _carPosition,
//           zoom: 15,
//         ),
//       ));
//     } else {
//       timer.cancel();
//     }
//   });
// }
*/

  // void main() {
  //   runApp(MaterialApp(
  //     home: SetTravelRouteScreen(scheduleId: 'scheduleId'),
  //   ));
  // }
}
