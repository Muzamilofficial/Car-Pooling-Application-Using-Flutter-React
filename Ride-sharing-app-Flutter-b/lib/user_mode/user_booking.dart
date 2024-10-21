import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/map_screen/manual_ride_track_screen.dart';
import 'package:flutter_application_1/map_screen/user_track_location_map.dart';
import 'package:flutter_application_1/utils.dart/const.dart';
import 'package:flutter_application_1/utils.dart/geo_coding.dart';
import 'package:flutter_application_1/utils.dart/phone_call_service.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({super.key});

  @override
  State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  // Database References
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  TextEditingController ratingTextController = TextEditingController();
  double ratings = 3;
  bool _isLoading = true;

  // get current userBookings
  List<Map> bookingsData = [];
  Future<List<Map>> getBookings() async {
    bookingsData.clear();

    List<Map> schedulesBookingsList = [];

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
          print(booking);

          if (booking['bookingStatus'] != 'Successed') {
            schedulesBookingsList.add(booking);
            bookingsData.add(booking);
            await getSchedules();
            // setState(() {});
          }
        }
      }
    } else {
      log("No Data Found");
    }
    // setState(() {
    //   // _isLoading = false;
    // });
    //   log("schedulesData");

    //  log("message");
    return schedulesBookingsList;
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
        // setState(() {});
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
        print("=" * 20);
        // print(routesSnap.value);
        Map routesData = routesSnap.value as Map;
        // print(routesData['origin']);
        // routeName(routesData['origin']);
        routesData['origin'] =
            await _getAddressFromLatLng(routesData['origin']);
        routesData['destination'] =
            await _getAddressFromLatLng(routesData['destination']);
        routesList.add(routesData);
        setState(() {});
        print(routesList);
      } else {
        log("Data Not Exist");
      }
    }
  }

  // get routes name from co-ordinates
  // Future<String> routeName(String lat_long) async {
  //   double lat = double.parse(lat_long.split(',')[0]);
  //   double long = double.parse(lat_long.split(', ')[1]);
  //   final coordinates = Coordinates(lat, long);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var first = addresses.first;
  //   print("${first.featureName} : ${first.addressLine}");
  //   return first.addressLine?.split(',')[1] ?? "";
  // }

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

  void onChangeStatus(int index, String status) async {
    await ref
        .child('scheduleBooking')
        .child(bookingsData[index]['bookingId'].toString())
        .update({'bookingStatus': status}).then((value) {
      log("Success");
      Navigator.pop(context);
    }).catchError((e) {
      log("Failed!");
    });
  }

  void onChangeManualStatus(int index, String status) async {
    await ref
        .child('rideRequest')
        .child(manuals[index]['requestId'].toString())
        .update({'rideStatus': status}).then((value) {
      log("Success");
      Navigator.pop(context);
    }).catchError((e) {
      log("Failed!");
    });
  }

  void showFeedbackDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Give Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Rate your experience:'),
              // add rating bar
              RatingBar.builder(
                initialRating: ratings,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    ratings = rating;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: ratingTextController,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allow multiple lines of text
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              onChangeStatus(index, bookingStatus['success']!);

              String? feedbackId = ref.child('feedback').push().key.toString();

              String username = await AuthService().currentUserName();

              Map feedbackData = {
                'feedbackId': feedbackId,
                'rating': ratings,
                'feedback': ratingTextController.text,
                'scheduleId': bookingsData[index]['bookingId'],
                "driverId": schedulesList[index]['driverId'],
                "passenger_name": username,
              };
              ref
                  .child('feedback')
                  .child(feedbackId)
                  .set(feedbackData)
                  .then((value) {
                Navigator.of(context).pop(); // Close the dialog
              }).catchError((e) {
                Navigator.of(context).pop(); // Close the dialog
                log(e);
              });
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void showManualFeedbackDialog(int index) {
    print(index);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Give Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Rate your experience:'),
              // add rating bar
              RatingBar.builder(
                initialRating: ratings,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    ratings = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ratingTextController,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allow multiple lines of text
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onChangeManualStatus(index, bookingStatus['success']!);

              String? feedbackId = ref.child('feedback').push().key.toString();

              Map feedbackData = {
                'feedbackId': feedbackId,
                'rating': ratings,
                'feedback': ratingTextController.text,
                'scheduleId': manuals[index]['requestId']
              };
              ref
                  .child('feedback')
                  .child(feedbackId)
                  .set(feedbackData)
                  .then((value) {
                manuals.removeAt(index);
              }).catchError((e) {
                // Navigator.of(context).pop(); // Close the dialog
                log(e);
              });
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

// get User Manuals List
  List<Map<dynamic, dynamic>> manuals = [];
  List bookingsHistory = [];
  Future<void> getManuals() async {
    bookingsHistory.clear();

    String currentUser = AuthService.getCurrentUser()!.uid.toString();

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('users');

    DataSnapshot bookingSnap =
        await userRef.child(currentUser).child("rideRequest").get();

    if (bookingSnap.exists) {
      List bookingsId = bookingSnap.value as List;
      log("Rides");
      print(bookingsId);
      for (var id in bookingsId) {
        final DatabaseReference rideRef =
            FirebaseDatabase.instance.ref('rideRequest');
        DataSnapshot rideSnap = await rideRef.child(id).get();
        if (rideSnap.exists) {
          Map rideData = rideSnap.value as Map;
          if (rideData['rideStatus'] != bookingStatus['success']) {
            print(rideData);
            manuals.add(rideData);
          }
          // setState(() {});
        } else {
          log("No Ride Found!");
        }
      }
      print("bookings " + bookingsHistory.toString());
    } else {
      log("Failed");
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Pending Feedback

  fetch() async {
    await getBookings();
    log("INIT State");
    print("bookings DAta ==> " + bookingsData.toString());
    print("SCHEDULES DAta ==> " + schedulesList.toString());

    // .whenComplete(() {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
    await getManuals();
    // .whenComplete(() {
    //   // setState(() {
    //   //   _isLoading = false;
    //   // });
    // });
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
            "Bookings",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          bottom: const TabBar(tabs: [
            Tab(text: "Schedules"),
            Tab(text: "Manuals"),
          ]),
        ),
        body: TabBarView(children: [
          buildScheduleList(),
          buildManualsRides(),
          // const Center(child: Text("Manuals")),
        ]),
      ),
    );
  }

  /*
  _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : bookingsData.isEmpty
            ? const Center(
                child: Text("No Booking Yet!"),
              )
            :
   */

  Widget buildScheduleList() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : bookingsData.isEmpty
            ? const Center(
                child: Text("No Booking Yet!"),
              )
            : ListView.builder(
                itemCount: bookingsData.length,
                itemBuilder: (context, index) {
                  log(bookingsData.length.toString());
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
                                    Text("data"),
                                    Text(
                                        "Pickup Point: ${bookingsData[index]['pickupPoint']}"),
                                    Text(
                                        "No of Seats: ${bookingsData[index]['noOfPassengers']} "),
                                    Text(
                                        "VehicleType: ${schedulesList[index]['carType']} "),
                                    Text(
                                        "Driver Name: ${schedulesList[index]['driverName']} "),
                                    Text(
                                        "Car No: ${schedulesList[index]['carNo']} "),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Chip(
                                    label: Text(
                                        "Status: ${bookingsData[index]['bookingStatus']}"),
                                  ),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      print("Click");
                                      PhoneCallService.makePhoneCall(
                                          schedulesList[index]['driverPhone'] ??
                                              "0320112233456");
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 25,
                                      child: Icon(
                                        Icons.call,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          buildRowText("Origin", routesList[index]['origin']),
                          buildRowText(
                              "Destination", routesList[index]['destination']),
                          buildRowText(
                              "Stops", "${routesList[index]['stops'].length}"),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: bookingsData[index]
                                            ['bookingStatus'] ==
                                        'Started'
                                    ? () {
                                        onChangeStatus(
                                            index, bookingStatus['reach']!);
                                      }
                                    : null,
                                child: const Text("Reached"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: bookingsData[index]
                                            ['bookingStatus'] ==
                                        bookingStatus['complete']
                                    ? () {
                                        showFeedbackDialog(index);
                                      }
                                    : null,
                                child: const Text("send Feedback"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: bookingsData[index]['bookingStatus'] ==
                                      bookingStatus['start']
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserRideTrackingScreen(
                                                  driverId: schedulesList[index]
                                                      ['driverId'],
                                                  routesId: schedulesList[index]
                                                      ['routeId']),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text("Track Ride"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

  Widget buildManualsRides() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : manuals.isEmpty
            ? const Center(
                child: Text("No Rides Available!"),
              )
            : ListView.builder(
                itemCount: manuals.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Card(
                      elevation: 2,
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
                                "Ride Status", manuals[index]['rideStatus']),
                            buildRowText(
                                "Passengers", manuals[index]['noOfPassengers']),
                            buildRowText(
                                "Origin", manuals[index]['pickupLocation']),
                            buildRowText("Destination",
                                manuals[index]['dropOffLocation']),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: manuals[index]['rideStatus'] ==
                                          bookingStatus['pickup']
                                      ? () async {
                                          Map<String, dynamic>? pickup =
                                              await GeocodingService
                                                  .getLatLangFromAddress(
                                                      manuals[index]
                                                          ['pickupLocation']);
                                          Map<String, dynamic>? dropOff =
                                              await GeocodingService
                                                  .getLatLangFromAddress(
                                                      manuals[index]
                                                          ['dropOffLocation']);

                                          Map<String, dynamic> location = {
                                            "pickup": pickup,
                                            "dropOff": dropOff,
                                          };
                                          print(location);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ManualRideTrackScreen(
                                                  location: location,
                                                  riderId: manuals[index]
                                                      ['driverId'],
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    "Track Ride",
                                    style: TextStyle(
                                      color: manuals[index]['rideStatus'] ==
                                              bookingStatus['start']
                                          ? Colors.green
                                          : Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: manuals[index]['rideStatus'] ==
                                          bookingStatus['complete']
                                      ? () {
                                          showManualFeedbackDialog(index);
                                        }
                                      : null,
                                  child: Text(
                                    "Send Feedback",
                                    style: TextStyle(
                                      color: manuals[index]['rideStatus'] ==
                                              bookingStatus['complete']
                                          ? Colors.green
                                          : Colors.black.withOpacity(0.7),
                                    ),
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
