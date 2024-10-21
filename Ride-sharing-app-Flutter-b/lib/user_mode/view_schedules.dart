import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/user_mode/schedule_details.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';

class ViewSchedulesScreen extends StatefulWidget {
  const ViewSchedulesScreen({super.key});

  @override
  State<ViewSchedulesScreen> createState() => _ViewSchedulesScreenState();
}

class _ViewSchedulesScreenState extends State<ViewSchedulesScreen> {
  bool _isLoading = true;
  final DatabaseReference scheduleRef =
      FirebaseDatabase.instance.ref().child('schedules');
  List<Map<dynamic, dynamic>> schedules = [];

// isDeleted: true

  void getSchedules() async {
    // Use the database event stream to fetch schedules
    scheduleRef.onValue.listen((event) async {
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? values = snapshot.value as Map?;

      if (values != null) {
        schedules = values.entries
            .map<Map<dynamic, dynamic>>((e) {
              // print("Value --> " + e.value.toString());
              if (e.value["isDeleted"]) {
                // print("Continue...");
                return {};
              }
              return Map.from(e.value);
            })
            .where((ride) => ride.isNotEmpty)
            .toList();
      }
      await getRoutes();

      setState(() {});
    });
  }

  // Get Route Data
  List<Map> routesList = [];
  Future<void> getRoutes() async {
    routesList.clear();
    for (var routes in schedules) {
      print("id:- " + routes['routeId']);
      DataSnapshot routesSnap = await FirebaseDatabase.instance
          .ref()
          .child('routesnew')
          .child(routes['routeId'])
          .get();

      if (routesSnap.exists) {
        print("=" * 20);
        print(routesSnap.value);
        print("=====");
        Map routesData = routesSnap.value as Map;
        print("ORIGIN " + routesData['origin']);
        // routeName(routesData['origin']);
        // routesData['origin'] = await routeName(routesData['origin']);
        // routesData['destination'] = await routeName(routesData['destination']);
        routesData['origin'] =
            await _getAddressFromLatLng(routesData['origin']);
        routesData['destination'] =
            await _getAddressFromLatLng(routesData['destination']);
        routesList.add(routesData);
      } else {
        log("Data Not Exist");
      }
    }
    _isLoading = false;
    setState(() {});
  }

  // get Full arddess with lat_long
  Future<String> _getAddressFromLatLng(String lat_long) async {
    double lat = double.parse(lat_long.split(',')[0]);
    double long = double.parse(lat_long.split(', ')[1]);
    String address = "";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          address =
              "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
        return address;
      } else {
        return address;
      }
    } catch (e) {
      print(e);
      throw ("Address Not Found");
    }
  }

  // get routes name from co-ordinates
  // Future<String> routeName(String lat_long) async {
  //   // print("lat Long");
  //   // print(lat_long.split(','));
  //   double lat = double.parse(lat_long.split(',')[0]);
  //   double long = double.parse(lat_long.split(', ')[1]);
  //   final coordinates = Coordinates(lat, long);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var first = addresses.first;
  //   print("${first.featureName} : ${first.addressLine}");
  //   return first.addressLine?.split(',')[1] ?? "";
  // }

  @override
  void initState() {
    super.initState();
    getSchedules();
    setState(() {});
  }

  Widget buildRowText(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          key,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpool Schedules'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[300],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : schedules.isNotEmpty
              ? ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    Map<dynamic, dynamic> schedule = schedules[index];
                    String routeName = 'Route ${index + 1}';
                    log(schedules.length.toString());
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScheduleDetailsScreen(schedule: schedule),
                          ),
                        );
                      },
                      child: Card(
                        // elevation: ,
                        color: Colors.green[300],

                        margin: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(routeName),
                              buildRowText("Car Type", schedule['carType']),
                              buildRowText("Available Seats",
                                  schedule['availableSeats']),
                              buildRowText("Fares", "${schedule['fares']} /KM"),
                              buildRowText(
                                  "Origin", routesList[index]['origin']),
                              buildRowText("Car No", schedule['carNo']),
                              buildRowText("Destination",
                                  routesList[index]['destination']),
                              buildRowText("No of Stops",
                                  "${routesList[index]['stops'].length}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('No schedules available.'),
                ),
    );
  }
}
