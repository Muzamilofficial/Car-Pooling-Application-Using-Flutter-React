import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/utils.dart/const.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';

class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
// Database References
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  bool _isScheduleLoading = true;
  // get current userBookings
  List<Map> bookingsData = [];
  Future<void> getBookings() async {
    bookingsData.clear();

    String currentUser = AuthService.getCurrentUser()!.uid.toString();
    var datasnapshot =
        await ref.child('users').child(currentUser).child('bookings').get();

    if (datasnapshot.exists) {
      // print("*" * 20);
      // print(datasnapshot.value);

      List bookingsIdList = datasnapshot.value as List;
      for (var booking in bookingsIdList) {
        var bookingSnapshot =
            await ref.child('scheduleBooking').child(booking.toString()).get();

        if (bookingSnapshot.exists) {
          Map booking = bookingSnapshot.value as Map;
          // print("*" * 20);
          // print(booking);
          if (booking['bookingStatus'] == bookingStatus['success']) {
            bookingsData.add(booking);
            await getSchedules();
          } else {
            log("No Success Data Found");
            setState(() {
              _isScheduleLoading = false;
            });
          }
        } else {
          log("No Bookings Found");
          setState(() {
            _isScheduleLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isScheduleLoading = false;
      });
      log("No Data Found");
    }
  }

// Get Schedueles
  List<Map> schedulesList = [];
  Future<void> getSchedules() async {
    schedulesList.clear();
    for (var booking in bookingsData) {
      DataSnapshot schSnap =
          await ref.child('schedules').child(booking['scheduleId']).get();
      if (schSnap.exists) {
        Map schdules = schSnap.value as Map;
        schedulesList.add(schdules);
        await getRoutes();
      }
    }
  }

// Get Route Data
  List<Map> routesList = [];
  Future<void> getRoutes() async {
    routesList.clear();
    for (var routes in schedulesList) {
      DataSnapshot routesSnap = await FirebaseDatabase.instance
          .ref()
          .child('routesnew')
          .child(routes['routeId'])
          .get();

      if (routesSnap.exists) {
        // print("=" * 20);
        // print(routesSnap.value);
        Map routesData = routesSnap.value as Map;
        // print(routesData['origin']);
        // routeName(routesData['origin']);
        // _isLoading = false;
        routesData['origin'] =
            await _getAddressFromLatLng(routesData['origin']);
        routesData['destination'] =
            await _getAddressFromLatLng(routesData['destination']);
        setState(() {
          routesList.add(routesData);
          _isScheduleLoading = false;
        });
      } else {
        log("Data Not Exist");
      }
    }
  }

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

// get User Manuals List
  List<Map<dynamic, dynamic>> manuals = [];
  List bookingsHistory = [];
  Future<void> getManuals() async {
    bookingsHistory.clear();

    String currentUser = AuthService.getCurrentUser()!.uid.toString();

    final DatabaseReference ref = FirebaseDatabase.instance.ref('users');

    DataSnapshot bookingSnap =
        await ref.child(currentUser).child("rideRequest").get();

    if (bookingSnap.exists) {
      List bookingsId = bookingSnap.value as List;
      for (var id in bookingsId) {
        final DatabaseReference rideRef =
            FirebaseDatabase.instance.ref('rideRequest');
        DataSnapshot rideSnap = await rideRef.child(id).get();
        if (rideSnap.exists) {
          Map rideData = rideSnap.value as Map;
          if (rideData['rideStatus'] == bookingStatus['success']) {
            setState(() {
              manuals.add(rideData);
            });
            log("Add Success");
          }
        } else {
          log("No Ride Found!");
        }
      }
      print("Manuals " + manuals.toString());
    } else {
      log("Failed");
    }
  }

  fetch() async {
    await getBookings().whenComplete(() {
      log("First");
    });

    await getManuals().whenComplete(() {
      setState(() {
        _isLoading = false;
      });
      log("Second");
    });
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[300],
          title: const Text(
            "History",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Schedules'),
              Tab(text: 'Manuals'),
            ],
          ),
        ),
        body: TabBarView(children: [
          buildScheduleHistory(),
          buildManualsHistory(),
        ]),
      ),
    );
  }

  Widget buildManualsHistory() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : manuals.isEmpty
            ? const Center(
                child: Text("No Ride Complete yet!"),
              )
            : ListView.builder(
                itemCount: manuals.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: Card(
                      // elevation: ,
                      color: Colors.green[300],

                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRowText("ID ", manuals[index]['requestId']),
                            buildRowText("Car Type", manuals[index]['CarType']),
                            buildRowText(
                                "Car Type", manuals[index]['rideStatus']),
                            buildRowText(
                                "Passengers", manuals[index]['noOfPassengers']),
                            buildRowText(
                                "Origin", manuals[index]['pickupLocation']),
                            buildRowText("Destination",
                                manuals[index]['dropOffLocation']),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget buildScheduleHistory() {
    return _isScheduleLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : bookingsData.isEmpty
            ? const Center(
                child: Text("No History Yet!"),
              )
            : ListView.builder(
                itemCount: bookingsData.length,
                itemBuilder: (context, index) {
                  print(bookingsData.length);
                  return Card(
                    color: Colors.green[200],
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Pickup Point: ${bookingsData[index]['pickupPoint']}"),
                                    Text(
                                        "No of Seats: ${bookingsData[index]['noOfPassengers']} "),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(
                                    "Status: ${bookingsData[index]['bookingStatus']}"),
                              ),
                            ],
                          ),
                          buildRowText("Origin", routesList[index]['origin']),
                          buildRowText(
                              "Destination", routesList[index]['destination']),
                          buildRowText(
                              "Stops", "${routesList[index]['stops'].length}"),
                        ],
                      ),
                    ),
                  );
                },
              );
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
}
