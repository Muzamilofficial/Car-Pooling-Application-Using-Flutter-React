import "dart:developer";

import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:flutter_application_1/credentials/auth_service.dart";
import "package:flutter_application_1/utils.dart/const.dart";

class ScheduleRequest extends StatefulWidget {
  final String scheduleId;
  const ScheduleRequest({super.key, required this.scheduleId});

  @override
  State<ScheduleRequest> createState() => _ScheduleRequestState();
}

class _ScheduleRequestState extends State<ScheduleRequest> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  bool _isLoading = true; // to show loading indicator

  List requestList = [];
//  Get Data from database
  Future<dynamic> getBookingRequests() async {
    Map scheduleData = {};
    requestList.clear();

    // show loading Indicator
    // setState(() {
    //   _isLoading = true;
    // });

    final requestSnapshot = await ref
        .child('schedules')
        .child(widget.scheduleId)
        .get()
        .then((value) async {
      if (value.exists) {
        scheduleData = value.value as Map;
        requestList = scheduleData['requests'] as List;
        // setState(() {
        // });

        await getBookings();
      } else {
        print('No data available.');
      }
    }).catchError((e) {
      log(e.toString());
    });

    return scheduleData;
  }

  List<Map> bookingList = [];
  Future<void> getBookings() async {
    bookingList.clear();

    for (var request in requestList) {
      final bookingSnapshot = await ref
          .child('scheduleBooking')
          .child(request)
          .get()
          .then((value) async {
        if (value.exists) {
          Map bookingRequest = value.value as Map;
          if (bookingRequest['bookingStatus'] == bookingStatus['pending']) {
            // print(bookingRequest);
            bookingList.add(bookingRequest);
          }
          // setState(() {
          //   // _isLoading = false;
          // });
          await getPassengers();
        } else {
          print('No data available.');
        }
      }).catchError((e) {
        log(e);
      });
    }
  }

  List<Map> passengersList = [];
  Future<void> getPassengers() async {
    passengersList.clear();

    for (var passenger in bookingList) {
      // print("Pass " + passenger['passengerId']);
      final passengerSnapshot = await ref
          .child('users')
          .child(passenger['passengerId'])
          .get()
          .then((value) {
        if (value.exists) {
          Map passengerData = value.value as Map;
          passengersList.add(passengerData);
          // setState(() {
          // _isLoading = false;
          // });
        } else {
          print('No data available.');
        }
      }).catchError((e) {
        // setState(() {
        //   _isLoading = false;
        // });
        log(e);
      });
    }
  }

  void onChangeStatus(int index, String status) {
    String bookingId = bookingList[index]['bookingId'].toString();
    final bookingSnapshot =
        ref.child('scheduleBooking').child(bookingId).update({
      "bookingStatus": status,
    }).then((value) {
      // print("---------------> Success ----- ");
      setState(() {
        passengersList.removeRange(index, index + 1);
        bookingList.removeRange(index, index + 1);
      });
    }).catchError((e) {
      // print(e);
    });
  }

  void get() async {
    _isLoading = true;
    await getBookingRequests().whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Build--->");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text(
          "Schedule Requests",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _isLoading == true
          ? buildloadingIndicator()
          : passengersList.isEmpty || bookingList.isEmpty
              ? buildErrorMsg()
              : ListView.builder(
                  itemCount: passengersList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.green[200],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${passengersList[index]['name']}"),
                            Text(
                                "Phone: ${passengersList[index]['phoneNumber']}"),
                            Text(
                                "NO of Passenger: ${bookingList[index]['noOfPassengers']}"),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Accept or Reject button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    onChangeStatus(
                                        index, bookingStatus['accept']!);
                                  },
                                  child: const Text("Accepted"),
                                ),
                                const SizedBox(width: 15),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // print("Click ===> ");
                                    onChangeStatus(
                                        index, bookingStatus['reject']!);
                                  },
                                  child: const Text("Rejected"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

/*
      body: FutureBuilder(
        future: getBookingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildloadingIndicator();
          }
          if (snapshot.hasData) {
            if (requestList.isEmpty ||
                bookingList.isEmpty ||
                passengersList.isEmpty) {
              return const SizedBox();
            } else {
              return ListView.builder(
                  itemCount: requestList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.green[200],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${passengersList[index]['name']}"),
                            Text(
                                "Phone: ${passengersList[index]['phoneNumber']}"),
                            Text(
                                "NO of Passenger: ${bookingList[0]['noOfPassengers']}"),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Accept or Reject button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    onChangeStatus(index, "Accepted");
                                  },
                                  child: const Text("Accepted"),
                                ),
                                const SizedBox(width: 15),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // print("Click ===> ");
                                    onChangeStatus(index, "Rejected");
                                  },
                                  child: const Text("Rejected"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }
          } else {
            return ListView.builder(
                itemCount: requestList.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.green[200],
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${passengersList[index]['name']}"),
                          Text(
                              "Phone: ${passengersList[index]['phoneNumber']}"),
                          Text(
                              "NO of Passenger: ${bookingList[0]['noOfPassengers']}"),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Accept or Reject button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[800],
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  onChangeStatus(index, "Accepted");
                                },
                                child: const Text("Accepted"),
                              ),
                              const SizedBox(width: 15),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  // print("Click ===> ");
                                  onChangeStatus(index, "Rejected");
                                },
                                child: const Text("Rejected"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }
        },
      ),
  */
    );
  }

  Widget buildErrorMsg() => const Center(
        child: Text("No Request Found!"),
      );
  Widget buildloadingIndicator() => const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
}
