// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils.dart/const.dart';
import 'package:flutter_application_1/utils.dart/phone_call_service.dart';

class PassengerListScreen extends StatefulWidget {
  final String scheduleId;
  const PassengerListScreen({
    Key? key,
    required this.scheduleId,
  }) : super(key: key);

  @override
  State<PassengerListScreen> createState() => _PassengerListScreenState();
}

class _PassengerListScreenState extends State<PassengerListScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  bool _isLoading = true; // initially is true

  String actualTime = "";
  String actualDate = "";

  List requestList = [];
//  Get Data from database
  Future<dynamic> getBookingRequests() async {
    Map scheduleData = {};
    requestList.clear();
    // get schedule
    final requestSnapshot =
        await ref.child('schedules').child(widget.scheduleId).get();

    if (requestSnapshot.exists) {
      scheduleData = requestSnapshot.value as Map;
      actualTime = scheduleData["time"];
      actualDate = scheduleData["date"];
      requestList = scheduleData['requests'] as List;
      // setState(() {});
      getBookings();
    } else {
      print('No data available.');
    }

    return scheduleData;
  }

  List<Map> bookingList = [];
  void getBookings() async {
    bookingList.clear();

    for (var request in requestList) {
      final bookingSnapshot =
          await ref.child('scheduleBooking').child(request).get();

      if (bookingSnapshot.exists) {
        Map bookingRequest = bookingSnapshot.value as Map;
        if (bookingRequest['bookingStatus'] != bookingStatus['pending'] &&
            bookingRequest['bookingStatus'] != bookingStatus['complete'] &&
            bookingRequest['bookingStatus'] != bookingStatus['success']) {
          // print(bookingRequest);
          bookingList.add(bookingRequest);
        }
        // setState(() {});
        getPassengers();
      } else {
        print('No data available.');
      }
    }
  }

  List<Map> passengersList = [];
  void getPassengers() async {
    passengersList.clear();
    for (var passenger in bookingList) {
      print("Pass " + passenger['passengerId']);
      final passengerSnapshot =
          await ref.child('users').child(passenger['passengerId']).get();

      if (passengerSnapshot.exists) {
        Map passengerData = passengerSnapshot.value as Map;
        passengersList.add(passengerData);
        // print("*" * 10);
        // print(passengersList);
        _isLoading = false;
        setState(() {});
      } else {
        print('No data available.');
      }
    }
  }

  void onChangeStatus(int index, String status) async {
    print("CLICKED");
    print(status);
    if (status == "PickedUp") {
      log("PICKUP");

      var currentDate = DateTime.now();

      print(bookingList[index]);

      await ref
          .child('scheduleBooking')
          .child(bookingList[index]['bookingId'].toString())
          .update({
        'bookingStatus': status,
        "pickupTime": currentDate.toString(),
        "actualTime": actualTime,
        "actualDate": actualDate,
      }).then((value) {
        log("Success");
        Navigator.pop(context);
      }).catchError((e) {
        print(e.toString());
        log("Failed!");
      });
    } else {
      await ref
          .child('scheduleBooking')
          .child(bookingList[index]['bookingId'].toString())
          .update({'bookingStatus': status}).then((value) {
        log("Success");
        Navigator.pop(context);
      }).catchError((e) {
        log("Failed!");
      });
    }

    if (status == bookingStatus['complete']) {
      String scheduleId = bookingList[index]['scheduleId'].toString();

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
        noOfBookings = noOfBookings - 1;
        await scheduleRef.update({"noOfBookings": noOfBookings});
      } else {
        log("No Booking no found");
      }
    }
  }

  @override
  void initState() {
    getBookingRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text(
          "Passengers",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? buildloadingIndicator()
          : passengersList.isEmpty
              ? buildErrorMsg()
              : ListView.builder(
                  itemCount: passengersList.length,
                  itemBuilder: (context, index) => Card(
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
                                        "Name: ${passengersList[index]['name']}"),
                                    Text(
                                        "Phone: ${passengersList[index]['phoneNumber']}"),
                                    Text(
                                        "NO of Passenger: ${bookingList[index]['noOfPassengers']}"),
                                    Text(
                                        "Pickup Point: ${bookingList[index]['pickupPoint']}"),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      bookingList[index]['bookingStatus'] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      PhoneCallService.makePhoneCall(
                                          passengersList[index]['phoneNumber']);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.green[800],
                                      radius: 20,
                                      child: const Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: bookingList[index]
                                            ['bookingStatus'] ==
                                        bookingStatus['reach']
                                    ? () {
                                        onChangeStatus(index, "PickedUp");
                                      }
                                    : null,
                                child: const Text("Pickup"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: bookingList[index]
                                            ['bookingStatus'] ==
                                        bookingStatus['pickup']
                                    ? () {
                                        onChangeStatus(
                                            index, bookingStatus['complete']!);
                                      }
                                    : null,
                                child: const Text("Ride Complete"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget buildErrorMsg() {
    return const Center(
      child: Text("No Passengers Yet!"),
    );
  }

  Widget buildloadingIndicator() {
    return const Center(
      child: Text("No Passengers Yet!"),
    );
  }
}
