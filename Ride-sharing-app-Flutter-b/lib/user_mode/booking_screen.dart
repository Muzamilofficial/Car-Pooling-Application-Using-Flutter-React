import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/user_mode/home_screen.dart';
import 'package:flutter_application_1/utils.dart/const.dart';
import 'package:flutter_application_1/utils.dart/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookingScreen extends StatefulWidget {
  final Map<dynamic, dynamic> schedule;
  final String routeId;

  BookingScreen({required this.schedule, required this.routeId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // get Database Refernce
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  // Define variables to store user selections
  int selectedPassengers = 1;
  String selectedStop = 'Origin';
  List<String> stops = ["Origin", "Destination"];

  void onBookNow() {
    // show toast Msg
    Fluttertoast.showToast(
        msg: "Booking Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green[300],
        textColor: Colors.white,
        fontSize: 16.0);

    // Implement booking logic here
    sendBookingRequest();

    // You may want to update the schedule in the database to mark it as booked
    // Show a success message and navigate back to the schedules screen
  }

  List usersBooking = [];
  List schedulesBooking = [];

  void getRoutes() async {
    DataSnapshot routeSnap =
        await ref.child('routesnew').child(widget.routeId).child('stops').get();

    if (routeSnap.exists) {
      log("Routes Found");
      List newStops = routeSnap.value as List;
      print("Stops -> $newStops");

      for (var i = 0; i < newStops.length; i++) {
        stops.add("Stops ${i + 1}");
      }
      setState(() {});
    } else {
      log("No Data Found!");
    }
  }

  void getUserBooking() async {
    String currentUser = AuthService.getCurrentUser()!.uid.toString();

    DataSnapshot userbookingSnap =
        await ref.child('users').child(currentUser).child('bookings').get();

    if (userbookingSnap.exists) {
      log("User Data Found");

      // print(userbookingSnap.value as List);
      List lst = userbookingSnap.value as List;
      setState(() {
        usersBooking.addAll(lst);
      });
    } else {
      log("no Data Found");
    }
  }

  void getScheduleooking() async {
    String scheduleId = widget.schedule['scheduleId']; // get scheduleID

    DataSnapshot scheduleBookingSnap =
        await ref.child('schedules').child(scheduleId).child('requests').get();

    if (scheduleBookingSnap.exists) {
      log("Schedule Data Found");
      // print(scheduleBookingSnap.value as List);
      List lst = scheduleBookingSnap.value as List;
      setState(() {
        schedulesBooking.addAll(lst);
      });
    } else {
      log("no Data Found");
    }
  }

  void sendBookingRequest() async {
    DatabaseReference bookingRef = ref.child('scheduleBooking').push();

    String bookingId = bookingRef.key.toString();
    String scheduleId = widget.schedule['scheduleId']; // get scheduleID
    print(scheduleId);
    String currentUser = AuthService.getCurrentUser()!.uid.toString();
    // make a map of booking request
    Map<String, dynamic> booking = {
      "bookingId": bookingId,
      "scheduleId": scheduleId,
      "passengerId": currentUser,
      "driverId": widget.schedule['driverId'],
      "noOfPassengers": selectedPassengers,
      "pickupPoint": selectedStop,
      "bookingStatus": bookingStatus['pending'],
    };

    // Specify the path where the data should be added
    bookingRef.set(booking).then((_) {
      // print('Data added successfully!');
      updateSchedules(bookingId);
      updateUserBooking(bookingId);
    }).catchError((error) {
      log('Failed to add data: $error');
    });
  }

  Future<void> updateSchedules(String bookingId) async {
    String scheduleId = widget.schedule['scheduleId']; // get scheduleID
    log("ScheduleId--> " + scheduleId + " <---");
    // if booking is complete make sure to available seats is decrease

    // Update schedule counter by one 1
    DatabaseReference scheduleRef = ref.child('schedules').child(scheduleId);
    DataSnapshot snapshot = await scheduleRef.get();
    if (snapshot.exists) {
      log("Schedules Found ****");
      Map data = snapshot.value as Map;
      // print("Schedule  data -->" + data.toString());
      int noOfBookings = data["noOfBookings"];
      log("<----------------------> No Of booking $noOfBookings <------------------> ");
      noOfBookings = noOfBookings + 1;
      await scheduleRef.update({"noOfBookings": noOfBookings});
    } else {
      log("No Booking no found");
    }

    String remainingSeats =
        "${int.parse(widget.schedule['availableSeats'].toString()) - selectedPassengers}";

    // add booking id
    schedulesBooking.add(bookingId);

    // update schedules data
    ref.child('schedules').child(scheduleId).update({
      "availableSeats": remainingSeats,
      "requests": schedulesBooking,
    }).then((value) {
      log('Schedule update successfully!');
    }).catchError((e) {
      log('Failed to add data: $e');
    });
  }

  void updateUserBooking(String bookingId) {
    String currentUser = AuthService.getCurrentUser()!.uid.toString();

    usersBooking.add(bookingId);

    // add booking ID to users data also
    ref.child('users').child(currentUser).update({
      "bookings": usersBooking,
    }).then((value) {
      log('Data update successfully!');
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      ));
    }).catchError((e) {
      log('Failed to add data: $e');
    });
  }

  // init method
  @override
  void initState() {
    getRoutes();
    getUserBooking();
    getScheduleooking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Schedule ID: ${widget.schedule['scheduleId']}'),
                    const SizedBox(height: 8),
                    Text('Car Type: ${widget.schedule['carType']}'),
                    const SizedBox(height: 8),
                    Text(
                        'Available Seats: ${widget.schedule['availableSeats']}'),
                    const SizedBox(height: 8),
                    Text('Date: ${Helper.formatDate(widget.schedule['date'])}'),
                    const SizedBox(height: 8),
                    Text('Time: ${widget.schedule['time']}'),
                    const SizedBox(height: 8),
                    Text('Schedule Type: ${widget.schedule['scheduleType']}'),
                    const SizedBox(height: 8),
                    Text('Fares: ${widget.schedule['fares']}'),
                  ],
                ),
              ),
            ),

            // Add other details as needed
            // Add dropdowns for passengers and stops selection
            // Add a button to book the schedule
            const SizedBox(height: 16),

            DropdownButton<int>(
              value: selectedPassengers,
              onChanged: (int? value) {
                setState(() {
                  selectedPassengers = value!;
                });
              },
              items: [1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value Passenger(s)'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            DropdownButton<String>(
              value: selectedStop,
              onChanged: (String? value) {
                setState(() {
                  selectedStop = value!;
                });
              },
              items: stops.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Change this to the desired background color
                foregroundColor: Colors
                    .white, // Change this to the desired foreground (text) color
              ),
              onPressed: onBookNow,
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
