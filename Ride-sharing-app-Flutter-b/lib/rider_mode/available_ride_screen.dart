import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/utils.dart/const.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AvailableRideScreen extends StatefulWidget {
  const AvailableRideScreen({super.key});

  @override
  State<AvailableRideScreen> createState() => _AvailableRideScreenState();
}

class _AvailableRideScreenState extends State<AvailableRideScreen> {
  // void get available rides
  final DatabaseReference requestRef =
      FirebaseDatabase.instance.ref().child('rideRequest');
  bool _isLoading = true;

  List<Map<dynamic, dynamic>> rides = [];
  List<Map<dynamic, dynamic>> bookings = [];
  List<Map<dynamic, dynamic>> history = [];

  void getAvailableRides() async {
    // Use the database event stream to fetch schedules
    requestRef.onValue.listen((event) async {
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? values = snapshot.value as Map?;

      if (values != null) {
        rides = values.entries
            .map<Map<dynamic, dynamic>>((e) {
              if (e.value['rideStatus'] == bookingStatus['pending']) {
                return Map.from(e.value);
              } else {
                return {};
              }
            })
            .where((ride) => ride.isNotEmpty)
            .toList();
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  List availableBookings = [];
  void getAvailableBookings() async {
    availableBookings.clear();

    String currentUser = AuthService.getCurrentUser()!.uid.toString();

    final DatabaseReference ref = FirebaseDatabase.instance.ref('drivers');

    DataSnapshot bookingSnap =
        await ref.child(currentUser).child("rideHistory").get();

    if (bookingSnap.exists) {
      List bookingsId = bookingSnap.value as List;
      for (var id in bookingsId) {
        final DatabaseReference rideRef =
            FirebaseDatabase.instance.ref('rideRequest');
        DataSnapshot rideSnap = await rideRef.child(id).get();
        if (rideSnap.exists) {
          Map rideData = rideSnap.value as Map;
          if (rideData['rideStatus'] == bookingStatus['start'] ||
              rideData['rideStatus'] == bookingStatus['pickup']) {
            bookings.add(rideData);
          }
        } else {
          log("No Ride Found!");
        }
      }
      print("bookings " + bookings.toString());
      setState(() {});
    } else {
      log("Failed to Fetch Availble Rides");
    }
  }

  List bookingsHistory = [];
  void getBookingsHistory() async {
    bookingsHistory.clear();

    String currentUser = AuthService.getCurrentUser()!.uid.toString();

    final DatabaseReference ref = FirebaseDatabase.instance.ref('drivers');

    DataSnapshot bookingSnap =
        await ref.child(currentUser).child("rideHistory").get();

    if (bookingSnap.exists) {
      List bookingsId = bookingSnap.value as List;
      for (var id in bookingsId) {
        final DatabaseReference rideRef =
            FirebaseDatabase.instance.ref('rideRequest');
        DataSnapshot rideSnap = await rideRef.child(id).get();
        if (rideSnap.exists) {
          Map rideData = rideSnap.value as Map;
          if (rideData['rideStatus'] == bookingStatus['complete'] ||
              rideData['rideStatus'] == bookingStatus['success']) {
            history.add(rideData);
          }
        } else {
          log("No Ride Found!");
        }
      }
      print("bookings " + bookingsHistory.toString());
      setState(() {});
    } else {
      log("Failed to get Ride History");
    }
  }

  // on driver data updates
  Future<void> updateDriverHistory(String requestId) async {
    log("Start + $requestId");
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child("drivers");
    final String currentUser = AuthService.getCurrentUser()!.uid.toString();

    DataSnapshot data =
        await driverRef.child(currentUser).child('rideHistory').get();

    List rideHistory = [];
    if (data.exists) {
      List ls = data.value as List;
      log("Driver Ride History");
      print(ls);
      rideHistory.addAll(ls);
    } else {
      log("ERROR: No History Found");
    }

    rideHistory.add(requestId);

    driverRef
        .child(currentUser)
        .update({"rideHistory": rideHistory}).then((value) {
      Fluttertoast.showToast(msg: "Ride Booked");
    }).catchError((e) {
      log("ERROR: DRIVER HISTORY FAILED");
    });
  }

  // update Ride Status
  // void onUpdateRideStatus(int index, String status) async {
  //   log("UPDATE $index $status");

  //   String driverId = AuthService.getCurrentUser()!.uid.toString();

  //   // update
  //   await requestRef.child(rides[index]['requestId']).update({
  //     "driverId": driverId,
  //     "rideStatus": status,
  //   }).then((value) async {
  //     log("Update Stauts");
  //     // Update Driver History

  //     DatabaseReference driverRef =
  //         FirebaseDatabase.instance.ref().child("drivers");
  //     final String currentUser = AuthService.getCurrentUser()!.uid.toString();

  //     DataSnapshot data =
  //         await driverRef.child(currentUser).child('rideHistory').get();

  //     log(rides[index]["requestId"]);
  //     List rideHistory = [];
  //     if (data.exists) {
  //       List ls = data.value as List;
  //       log("Driver Ride History");
  //       print(ls);
  //       rideHistory.addAll(ls);
  //     } else {
  //       log("ERROR: No History Found");
  //     }

  //     rideHistory.add(rides[index]['requestId']);

  //     driverRef
  //         .child(currentUser)
  //         .set({"rideHistory": rideHistory}).then((value) {
  //       Fluttertoast.showToast(msg: "Ride Booked");
  //     }).catchError((e) {
  //       log("ERROR: DRIVER HISTORY FAILED");
  //     });
  //   });
  //   // updateDriverHistory(rides[index]['requestId']);
  // }

  Future<void> updateRodes(int index, String status) async {
    String driverId = AuthService.getCurrentUser()!.uid.toString();
    await requestRef.child(rides[index]["requestId"]).update({
      "driverId": driverId,
      "rideStatus": status,
    });
  }

  void updateRideStatus(int index, String status) async {
    log("Click Status");

    // Update User Data
    updateDriverHistory(rides[index]['requestId']);

    // update ride status
    updateRodes(index, status).whenComplete(() {
      log("Data Updated");
    });
    bookings.add(rides[index]);
    rides.removeAt(index);
    setState(() {});
  }

  void onCompleteRides(int index, String status) async {
    String driverId = AuthService.getCurrentUser()!.uid.toString();

    // update
    requestRef.child(bookings[index]['requestId']).update({
      "driverId": driverId,
      "rideStatus": status,
    }).then((value) {});

    if (status == bookingStatus['complete']) {
      history.add(bookings[index]);
      bookings.removeAt(index);
      setState(() {});
    }
  }

  fetchData() {
    getAvailableRides();
    getAvailableBookings();
    getBookingsHistory();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[200],
          title: const Text(
            "Available Rides",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Booking'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(children: [
          buildAvailableRides(),
          buildBookingseRides(list: bookings),
          buildBookingseHistory(list: history),
        ]),
      ),
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

  Widget buildAvailableRides() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : rides.isEmpty
            ? const Center(
                child: Text("No Rides Available!"),
              )
            : ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Card(
                      elevation: 1,
                      color: Colors.green[300],
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRowText("ID ", rides[index]['requestId']),
                            buildRowText("Car Type", rides[index]['CarType']),
                            buildRowText(
                                "Ride Status", rides[index]['rideStatus']),
                            buildRowText(
                                "Passengers", rides[index]['noOfPassengers']),
                            buildRowText(
                                "Origin", rides[index]['pickupLocation']),
                            buildRowText(
                                "Destination", rides[index]['dropOffLocation']),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    updateRideStatus(
                                        index, bookingStatus['start']!);
                                  },
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget buildBookingseRides({required List list}) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : list.isEmpty
            ? const Center(
                child: Text("No Bookings Available!"),
              )
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
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
                            buildRowText("ID ", list[index]['requestId']),
                            buildRowText("Car Type", list[index]['CarType']),
                            buildRowText(
                                "Ride Status", list[index]['rideStatus']),
                            buildRowText(
                                "Passengers", list[index]['noOfPassengers']),
                            buildRowText(
                                "Origin", list[index]['pickupLocation']),
                            buildRowText(
                                "Destination", list[index]['dropOffLocation']),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: list[index]['rideStatus'] ==
                                          bookingStatus['start']
                                      ? () {
                                          onCompleteRides(
                                              index, bookingStatus['pickup']!);
                                        }
                                      : null,
                                  child: Text(
                                    "Pickup",
                                    style: TextStyle(
                                        color: list[index]['rideStatus'] ==
                                                bookingStatus['start']
                                            ? Colors.green
                                            : Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: list[index]['rideStatus'] ==
                                          bookingStatus['pickup']
                                      ? () {
                                          onCompleteRides(index,
                                              bookingStatus['complete']!);
                                        }
                                      : null,
                                  child: Text(
                                    "Complete",
                                    style: TextStyle(
                                        color: list[index]['rideStatus'] ==
                                                bookingStatus['pickup']
                                            ? Colors.green
                                            : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget buildBookingseHistory({required List list}) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : list.isEmpty
            ? const Center(
                child: Text("No Ride Complete yet!"),
              )
            : ListView.builder(
                itemCount: list.length,
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
                            buildRowText("ID ", list[index]['requestId']),
                            buildRowText("Car Type", list[index]['CarType']),
                            buildRowText(
                                "Ride Status", list[index]['rideStatus']),
                            buildRowText(
                                "Passengers", list[index]['noOfPassengers']),
                            buildRowText(
                                "Origin", list[index]['pickupLocation']),
                            buildRowText(
                                "Destination", list[index]['dropOffLocation']),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }
}
