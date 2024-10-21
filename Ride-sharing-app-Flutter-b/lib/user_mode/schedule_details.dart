// ------
import 'package:flutter/material.dart';
import 'package:flutter_application_1/user_mode/booking_screen.dart';
import 'package:flutter_application_1/user_mode/view_travel_route.dart';
import 'package:flutter_application_1/utils.dart/helper.dart';

class ScheduleDetailsScreen extends StatelessWidget {
  final Map<dynamic, dynamic> schedule;

  ScheduleDetailsScreen({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Details'),
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
                    Text('Route: ${schedule['routeId']}'),
                    const SizedBox(height: 8),
                    Text('Vehicle Type: ${schedule['carType']}'),
                    const SizedBox(height: 8),
                    Text('Available Seats: ${schedule['availableSeats']}'),
                    const SizedBox(height: 8),
                    Text('Date: ${Helper.formatDate(schedule['date'])}'),
                    const SizedBox(height: 8),
                    Text('Time: ${schedule['time']}'),
                    const SizedBox(height: 8),
                    Text('Schedule Type: ${schedule['scheduleType']}'),
                    const SizedBox(height: 8),
                    Text('Fares: ${schedule['fares']}'),
                  ],
                ),
              ),
            ),

            // View Travel Route
            ElevatedButton(
              onPressed: () {
                // Navigate to the map view for the selected schedule
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        // ViewTravelRouteScreen(scheduleId: '-NliXfP1uOa4t3xYJiIS'),
                        ViewTravelRouteScreen(scheduleId: schedule['routeId']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Change this to the desired background color
                foregroundColor: Colors
                    .white, // Change this to the desired foreground (text) color
              ),
              child: const Text('View Travel Route'),
            ),

            // Book Now
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Change this to the desired background color
                foregroundColor: Colors
                    .white, // Change this to the desired foreground (text) color
              ),
              onPressed: () {
                // Navigate to the booking screen for the selected schedule
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      schedule: schedule,
                      routeId: schedule['routeId'],
                    ),
                  ),
                );
              },
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
