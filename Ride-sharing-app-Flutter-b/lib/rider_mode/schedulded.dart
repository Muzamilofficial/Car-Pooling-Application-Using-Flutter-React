import "dart:developer";

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/credentials/auth_service.dart';
import 'package:flutter_application_1/map_screen/ride_tracking_screen.dart';
import 'package:flutter_application_1/rider_mode/schedule_request/passengers_list.dart';
import 'package:flutter_application_1/rider_mode/schedule_request/schedule_request.dart';
import 'package:flutter_application_1/utils.dart/const.dart';
import 'package:flutter_application_1/utils.dart/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'home_screen.dart';
import 'userprofile.dart';
import 'original_map.dart';

// import 'package:fluttertoast/fluttertoast.dart';

class Scheduleded extends StatefulWidget {
  const Scheduleded({super.key});

  @override
  State<Scheduleded> createState() => _SchedulededState();
}

class _SchedulededState extends State<Scheduleded> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TextEditingController faresController = TextEditingController();
  bool? isDaily;
  List<String> carTypeList = ["CAR AC", "Car Non-AC"];
  String? selectedCarType;
  List<String> availableList = ["1", "2", "3"];
  String? selectedavailableseats;
  TabController? tabController;
  int selectedIndex = 0;

  bool _isLoading = true;

  List<Map> scheduleData = [];

  var loading = false; // to show loading indicator

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  List scheduleID = [];

//  Get Data from database
  Future<dynamic> getSchedule() async {
    scheduleID = [];
    Map userData = {};

    // go to drivers data and get scheduleId
    String userId = AuthService.getCurrentUser()!.uid.toString();
    final snapshot = await ref.child('drivers').child(userId).get();
    if (snapshot.exists) {
      userData = snapshot.value as Map;
      print("userData" + userData.toString());
      scheduleID = userData['scheduleId'];

      if (scheduleID.isNotEmpty) {
        for (var schId in scheduleID) {
          // get schedule
          final scheduleSnapshot =
              await ref.child('schedules').child(schId).get();

          if (scheduleSnapshot.exists) {
            Map singleSchedule = scheduleSnapshot.value as Map;
            if (singleSchedule != null) {
              // print("+ -> " * 20);
              // print(singleSchedule);
              // print(singleSchedule['requests']);
              scheduleData.add(singleSchedule);
            }
          } else {
            log('No data available.');
          }
        }
        print("scheduleData :  $scheduleData");
        await getSchedulesBooking();
      }
    } else {
      log('No data available.');
    }

    setState(() {
      _isLoading = false;
    });
    return scheduleData;
  }

  List<Map> bookingsData = [];
  Future<void> getSchedulesBooking() async {
    // bookingsData.clear();
    print("_________________ ${scheduleData.length} ____________________");

    // var i = 1;
    for (var schData in scheduleData) {
      // log("$i");
      // i++;
      // print("SCHDATA : $schData");
      print("*" * 30);
      // print("RouteID " + schData['routeId'].toString());
      getRoutes(schData['routeId']);
      List requests = schData['requests'];
      if (schData['requests'] != null) {
        if (requests.isNotEmpty) {
          // print("Requests  : " + requests.toString());

          for (var bookingId in requests) {
            DataSnapshot bookingSnapshot =
                await ref.child('scheduleBooking').child(bookingId).get();
            if (bookingSnapshot.exists) {
              // print("0" * 30);
              Map requestData = bookingSnapshot.value as Map;
              if (requestData['bookingStatus'] == bookingStatus['accept']) {
                // print(requestData);
                bookingsData.add(requestData);
              }
            }
          }
        } else {
          log("do Nothing");
        }
      }

      // print("RouteID");
      // print(schData['routeId']);
      // getRoutes(schData['routeId']);
    }
    // setState(() {});
    // print("BookingData" + bookingsData.toString());
  }

  // Get Routes
  List<Map> routesList = [];
  Future<void> getRoutes(String routeId) async {
    DataSnapshot routesSnapshot =
        await ref.child('routesnew').child(routeId).get();

    if (routesSnapshot.exists) {
      Map routesData = routesSnapshot.value as Map;
      routesData['origin'] = await _getAddressFromLatLng(routesData['origin']);
      routesData['destination'] =
          await _getAddressFromLatLng(routesData['destination']);
      List stops = routesData['stops'];
      routesData['stops'] = stops.length;
      routesList.add(routesData);
      log("Routes Loaded");
      print("Routes ==> " + routesList.toString());
      setState(() {
        _isLoading = false;
      });
    }
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

  // onStartRide
  void onStartRide(index) async {
    log("Start Ride");
    // print(bookingsData);
    for (var booking in bookingsData) {
      // print("booking " + booking.toString());

      var bookingId = booking['bookingId'];
      print("BOOKING ID # " + bookingId.toString());
      booking['bookingStatus'] = bookingStatus['start'];
      await ref
          .child('scheduleBooking')
          .child(bookingId)
          .update({'bookingStatus': bookingStatus['start']}).then((value) {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         RideTrackingScreen(routesId: scheduleData[index]['routeId']),
        //   ),
        // );
        log("Success");
      }).catchError((e) {
        log("Failed");
      });
    }
  }

  Future<void> showDeleteDialog(int index) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this Schedule?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                deleteSchedule(index).whenComplete(
                  () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const Scheduleded(),
                    ));
                  },
                );
                // Perform the delete operation here
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> notDeleteDialog() async {
    print("Not Deleted");
    Fluttertoast.showToast(
        msg: "Bookings have Found on this dialogs",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> deleteSchedule(int index) async {
    String scheduleId = scheduleID[index];

    DataSnapshot snapshot = await ref
        .child("schedules")
        .child(scheduleId)
        .child("noOfBookings")
        .get();

    if (snapshot.exists) {
      int noOfBookings = snapshot.value as int;

      if (noOfBookings == 0) {
        ref
            .child("schedules")
            .child(scheduleId)
            .child("isDeleted")
            .update({"isDeleted": true});

        // print("DELETE SCHEDULES");
        List newList = List.from(scheduleID);
        // print(newList);
        setState(() {
          newList.removeAt(index);
        });
        // print(newList);

        // update Schedules
        String currentUser = AuthService.getCurrentUser()!.uid.toString();

        await ref
            .child("drivers")
            .child(currentUser)
            .update({"scheduleId": newList});

        ref
            .child("schedules")
            .child(scheduleId)
            .update({"isDeleted": true}).then(
          (value) {
            Navigator.of(context).restorablePushReplacement(
              (context, arguments) {
                return MaterialPageRoute(
                  builder: (context) {
                    return const Scheduleded();
                  },
                );
              },
            );
          },
        );
      } else {
        // Show alert Dialog
        print("Not Deleted");
        notDeleteDialog();
      }
    }

    // .update({"isDeleted": false});
  }

  fetch() async {
    await getSchedule().whenComplete(() {
      setState(() {
        // _isLoading = false;
      });
    });

    setState(() {
      _isLoading = true;
    });
  }

  @override
  void initState() {
    fetch();

    // getSchedulesBooking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text(
          "My Schedule",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: scheduleID.isEmpty
          ? const Center(
              child: Text("NO Schedules Available!"),
            )
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : ListView.builder(
                  itemCount: scheduleID.length,
                  itemBuilder: (context, index) {
                    // print("Schedules " + scheduleData.length.toString());
                    log("routes " + routesList.length.toString());
                    return Column(
                      children: [
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.green[200],
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: const Text("Car Type"),
                                    trailing: Text(
                                        "${scheduleData[index]['carType'] ?? ""}"),
                                  ),
                                  ListTile(
                                    title: const Text("Available Seats"),
                                    trailing: Text(
                                        "${scheduleData[index]['availableSeats']}"),
                                  ),

                                  // * Routes Data *

                                  buildRow(
                                      "Origin", routesList[index]['origin']),
                                  const SizedBox(height: 10),
                                  buildRow("Destination",
                                      routesList[index]['destination']),

                                  ListTile(
                                    title: const Text("Stops"),
                                    trailing:
                                        Text("${routesList[index]['stops']}"),
                                  ),

                                  ListTile(
                                    title: const Text("Routine"),
                                    trailing: Text(
                                        "${scheduleData[index]['scheduleType']}"),
                                  ),

                                  ListTile(
                                    title: const Text("Date"),
                                    trailing: Text(Helper.formatDate(
                                        scheduleData[index]['date'])),
                                  ),
                                  ListTile(
                                    title: const Text("Time"),
                                    trailing:
                                        Text("${scheduleData[index]['time']}"),
                                  ),
                                  ListTile(
                                    title: const Text("Fares/KM"),
                                    trailing:
                                        Text("${scheduleData[index]['fares']}"),
                                  ),

                                  const Divider(
                                    color: Colors.black12,
                                  ),
                                  //  create Three button
                                  ListTile(
                                    onTap: () {
                                      showDeleteDialog(index);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    tileColor: Colors.red[500],
                                    title: const Text(
                                      "Delete Schedule",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ScheduleRequest(
                                            scheduleId: scheduleID[index],
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: Colors.green[700],
                                    title: const Text(
                                      "Requests",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: const Icon(
                                      Icons.file_copy,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PassengerListScreen(
                                            scheduleId: scheduleID[index],
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: Colors.green[700],
                                    title: const Text(
                                      "Passengers",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: const Icon(
                                      Icons.person_add_alt_outlined,
                                      color: Colors.white,
                                    ),
                                  ),

                                  // Start Ride Button
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: bookingsData.isNotEmpty
                                              ? () {
                                                  onStartRide(index);
                                                }
                                              : null,
                                          child: const Text(
                                            "Start Ride",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // print(scheduleData[index]
                                            //     ['routeId']);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RideTrackingScreen(
                                                        routesId:
                                                            scheduleData[index]
                                                                ['routeId']),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Driver Route",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // OLD UI CARD
                        /*
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDaily = true;
                            });
                          },
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDaily != null && isDaily == true
                                  ? Colors.green[300]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Daily",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDaily != null && isDaily == true
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isDaily = false;
                              });
                            },
                            child: Container(
                              width: 150,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDaily != null && isDaily == false
                                    ? Colors.green[300]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Once",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDaily != null && isDaily == false
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(20),
                  height: 720,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Car Type:',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 120),
                              child: Container(
                                width: 120, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                child: DropdownButton(
                                  iconSize: 30,
                                  dropdownColor: Colors.white,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "Select",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  value: selectedCarType,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedCarType = newValue.toString();
                                    });
                                  },
                                  items: carTypeList.map((car) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        car,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      value: car,
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Available Seats:',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // SizedBox(
                            //   height: 10,
                            //   width: 88,
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 52),
                              child: Container(
                                width: 120, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                child: DropdownButton(
                                  iconSize: 30,
                                  dropdownColor: Colors.white,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "Select",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  value: selectedavailableseats,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedavailableseats = newValue.toString();
                                    });
                                  },
                                  items: availableList.map((available) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        available,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      value: available,
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Row(
                          children: [
                            const Center(
                                child: Text(
                              "Select Date",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 21),
                            )),
                            // _selectedDate == null
                            // ? "Select Date"
                            // : DateFormat.yMMMd()
                            // .format(_selectedDate!)
                            // .toString(),
                            // style: const TextStyle(
                            // fontSize: 20,
                            // fontWeight: FontWeight.bold,
                            // ),
                            // textAlign: TextAlign.center,
                        
                            // const Spacer(),
                            const SizedBox(
                              width: 160,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100))
                                      .then((value) => setState(() {
                                            _selectedDate = value!;
                                          }));
                                },
                                child: const Icon(Icons.calendar_today_outlined))
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Row(
                          children: [
                            Text(
                              _selectedTime == null
                                  ? "Select Time"
                                  : TimeOfDay(
                                          hour: _selectedTime!.hour,
                                          minute: _selectedTime!.minute)
                                      .format(context)
                                      .toString(),
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // const Spacer(),
                            const SizedBox(
                              width: 155,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay(
                                              hour: DateTime.now().hour,
                                              minute: DateTime.now().minute))
                                      .then((value) => setState(() {
                                            _selectedTime = value!;
                                          }));
                                },
                                child: const Icon(Icons.timer_outlined))
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Enter Amount",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: TextFormField(
                                controller: faresController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Add Fares",
                                  // hintText: "Select From Location",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 21,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    // Define the route you want to navigate to here.
                                    // For example, you can navigate to a new screen.
                                    return CarInfoScreen();
                                  }),
                                );
                              },
                              child: const Text('Delete Schedule'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10),
                                backgroundColor: Colors.green[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Set the border radius
                                ),
                                fixedSize: const Size(400, 50.0),
                              ), //
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                // Define the route you want to navigate to here.
                                // For example, you can navigate to a new screen.
                                return CarInfoScreen();
                              }),
                            );
                          },
                          // onPressed: _updateUserProfile,
                          child: const Text('Requests'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10), // Adjust the padding for width
                            backgroundColor: Colors.green[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(400.0, 50.0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                // Define the route you want to navigate to here.
                                // For example, you can navigate to a new screen.
                                return CarInfoScreen();
                              }),
                            );
                          },
                          // onPressed: _updateUserProfile,
                          child: const Text('Passengers'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10), // Adjust the padding for width
                            backgroundColor: Colors.green[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(400.0, 50.0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                // Define the route you want to navigate to here.
                                // For example, you can navigate to a new screen.
                                return CarInfoScreen();
                              }),
                            );
                          },
                          // onPressed: _updateUserProfile,
                          child: const Text('Start Ride'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10), // Adjust the padding for width
                            backgroundColor: Colors.green[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(400.0, 50.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                          */
                      ],
                    );
                  }),

/*
          FutureBuilder(
              future: getSchedule(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.green,
                  ));
                }

                return scheduleID.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      )
                    : ListView.builder(
                        itemCount: scheduleID.length,
                        itemBuilder: (context, index) {
                          print("Schedules " + scheduleData.length.toString());
                          print("routes " + routesList.length.toString());
                          return Column(
                            children: [
                              const SizedBox(height: 10),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.green[200],
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: const Text("Car Type"),
                                          trailing: Text(
                                              "${scheduleData[index]['carType'] ?? ""}"),
                                        ),
                                        ListTile(
                                          title: const Text("Available Seats"),
                                          trailing: Text(
                                              "${scheduleData[index]['availableSeats']}"),
                                        ),
                                        buildRow("Origin",
                                            routesList[index]['origin']),
                                        buildRow("Destination",
                                            routesList[index]['destination']),
                                        ListTile(
                                          title: const Text("Stops"),
                                          trailing: Text(
                                              "${routesList[index]['stops']}"),
                                        ),

                                        ListTile(
                                          title: const Text("Routine"),
                                          trailing: Text(
                                              "${scheduleData[index]['scheduleType']}"),
                                        ),
                                        ListTile(
                                          title: const Text("Date"),
                                          trailing: Text(Helper.formatDate(
                                              scheduleData[index]['date'])),
                                        ),
                                        ListTile(
                                          title: const Text("Time"),
                                          trailing: Text(
                                              "${scheduleData[index]['time']}"),
                                        ),
                                        ListTile(
                                          title: const Text("Fares/KM"),
                                          trailing: Text(
                                              "${scheduleData[index]['fares']}"),
                                        ),

                                        const Divider(
                                          color: Colors.black12,
                                        ),
                                        //  create Three button
                                        ListTile(
                                          onTap: () {
                                            showDeleteDialog(index);
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          tileColor: Colors.red[500],
                                          title: const Text(
                                            "Delete Schedule",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          trailing: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ScheduleRequest(
                                                  scheduleId: scheduleID[index],
                                                ),
                                              ),
                                            );
                                          },
                                          tileColor: Colors.green[700],
                                          title: const Text(
                                            "Requests",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          trailing: const Icon(
                                            Icons.file_copy,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PassengerListScreen(
                                                  scheduleId: scheduleID[index],
                                                ),
                                              ),
                                            );
                                          },
                                          tileColor: Colors.green[700],
                                          title: const Text(
                                            "Passengers",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          trailing: const Icon(
                                            Icons.person_add_alt_outlined,
                                            color: Colors.white,
                                          ),
                                        ),

                                        // Start Ride Button
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: bookingsData.isNotEmpty
                                                ? () {
                                                    onStartRide(index);
                                                  }
                                                : () {
                                                    // print(scheduleData[index]
                                                    //     ['routeId']);
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RideTrackingScreen(
                                                                routesId: scheduleData[
                                                                        index][
                                                                    'routeId']),
                                                      ),
                                                    );
                                                  },
                                            child: const Text(
                                              "Start Ride",
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // OLD UI CARD
                              /*
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDaily = true;
                            });
                          },
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDaily != null && isDaily == true
                                  ? Colors.green[300]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Daily",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDaily != null && isDaily == true
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isDaily = false;
                              });
                            },
                            child: Container(
                              width: 150,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDaily != null && isDaily == false
                                    ? Colors.green[300]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Once",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDaily != null && isDaily == false
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(20),
                  height: 720,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Car Type:',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 120),
                              child: Container(
                                width: 120, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                child: DropdownButton(
                                  iconSize: 30,
                                  dropdownColor: Colors.white,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "Select",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  value: selectedCarType,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedCarType = newValue.toString();
                                    });
                                  },
                                  items: carTypeList.map((car) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        car,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      value: car,
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Available Seats:',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // SizedBox(
                            //   height: 10,
                            //   width: 88,
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 52),
                              child: Container(
                                width: 120, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                child: DropdownButton(
                                  iconSize: 30,
                                  dropdownColor: Colors.white,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "Select",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  value: selectedavailableseats,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedavailableseats = newValue.toString();
                                    });
                                  },
                                  items: availableList.map((available) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        available,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      value: available,
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Row(
                          children: [
                            const Center(
                                child: Text(
                              "Select Date",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 21),
                            )),
                            // _selectedDate == null
                            // ? "Select Date"
                            // : DateFormat.yMMMd()
                            // .format(_selectedDate!)
                            // .toString(),
                            // style: const TextStyle(
                            // fontSize: 20,
                            // fontWeight: FontWeight.bold,
                            // ),
                            // textAlign: TextAlign.center,
                        
                            // const Spacer(),
                            const SizedBox(
                              width: 160,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100))
                                      .then((value) => setState(() {
                                            _selectedDate = value!;
                                          }));
                                },
                                child: const Icon(Icons.calendar_today_outlined))
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Row(
                          children: [
                            Text(
                              _selectedTime == null
                                  ? "Select Time"
                                  : TimeOfDay(
                                          hour: _selectedTime!.hour,
                                          minute: _selectedTime!.minute)
                                      .format(context)
                                      .toString(),
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // const Spacer(),
                            const SizedBox(
                              width: 155,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay(
                                              hour: DateTime.now().hour,
                                              minute: DateTime.now().minute))
                                      .then((value) => setState(() {
                                            _selectedTime = value!;
                                          }));
                                },
                                child: const Icon(Icons.timer_outlined))
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Enter Amount",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: TextFormField(
                                controller: faresController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Add Fares",
                                  // hintText: "Select From Location",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 21,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    // Define the route you want to navigate to here.
                                    // For example, you can navigate to a new screen.
                                    return CarInfoScreen();
                                  }),
                                );
                              },
                              child: const Text('Delete Schedule'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10),
                                backgroundColor: Colors.green[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Set the border radius
                                ),
                                fixedSize: const Size(400, 50.0),
                              ), //
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                // Define the route you want to navigate to here.
                                // For example, you can navigate to a new screen.
                                return CarInfoScreen();
                              }),
                            );
                          },
                          // onPressed: _updateUserProfile,
                          child: const Text('Requests'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10), // Adjust the padding for width
                            backgroundColor: Colors.green[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(400.0, 50.0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                // Define the route you want to navigate to here.
                                // For example, you can navigate to a new screen.
                                return CarInfoScreen();
                              }),
                            );
                          },
                          // onPressed: _updateUserProfile,
                          child: const Text('Passengers'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10), // Adjust the padding for width
                            backgroundColor: Colors.green[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(400.0, 50.0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                // Define the route you want to navigate to here.
                                // For example, you can navigate to a new screen.
                                return CarInfoScreen();
                              }),
                            );
                          },
                          // onPressed: _updateUserProfile,
                          child: const Text('Start Ride'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10), // Adjust the padding for width
                            backgroundColor: Colors.green[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: const Size(400.0, 50.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                          */
                            ],
                          );
                        });
              }),
              */
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "location",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Account",
          ),
        ],
        onTap: (int index) {
          // Handle navigation based on the tapped item
          if (index == 3) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileManagement()),
            );
          }
          if (index == 0) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreene()),
            );
          }
          if (index == 1) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OriginalMap()),
            );
          }
          if (index == 2) {
            // Navigate to the next page (AccountPage in this example)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Scheduleded()),
            );
          }
        },

        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.green[300],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,

        // onTap: onItemClicked,
      ),
    );
  }

  Padding buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 5.0, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
    if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("No Schedule Created"),
              );
            }
 */
