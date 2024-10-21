import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class ViewTravelRouteScreen extends StatefulWidget {
  final String scheduleId;

  ViewTravelRouteScreen({required this.scheduleId});

  @override
  _ViewTravelRouteScreenState createState() => _ViewTravelRouteScreenState();
}

class _ViewTravelRouteScreenState extends State<ViewTravelRouteScreen> {
  final DatabaseReference scheduleRef = FirebaseDatabase.instance.reference().child('schedules');
  final DatabaseReference routesRef = FirebaseDatabase.instance.reference().child('routesnew');
  

  late GoogleMapController mapController;
  List<Marker> markers = [];
  List<LatLng> polylineCoordinates = [];
  

  

  @override
  void initState() {
    super.initState();
    fetchRouteInformation();
  }

void fetchRouteInformation() async {
  // Retrieve route information based on the scheduleId
  DatabaseEvent event = await routesRef.child(widget.scheduleId).once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> routeData = Map.from(event.snapshot.value as Map);

    // Extract origin and destination coordinates
    String originString = routeData['origin'];
    String destinationString = routeData['destination'];
    

    LatLng origin = convertToLatLng(originString);
    LatLng destination = convertToLatLng(destinationString);
    


    // Create markers for origin and destination
    // markers.add(Marker(markerId: MarkerId('origin'), position: origin, infoWindow: InfoWindow(title: 'Origin'),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
    // markers.add(Marker(markerId: MarkerId('destination'), position: destination, infoWindow: InfoWindow(title: 'Destination'),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)));

    // Create markers for origin and destination
      addMarker('origin', origin, 'Origin');
      addMarker('destination', destination, 'Destination');
    

    // Extract and create markers for stops
     if (routeData['stops'] != null) {
      List<dynamic> stops = routeData['stops'] as List<dynamic>;
      // stops.forEach((stop) {
      for (var stop in stops) {
        double lat = stop['lat'];
        double lng = stop['lng'];

        LatLng stopLocation = LatLng(lat, lng);
        await addMarker('stop_${stops.indexOf(stop)}', stopLocation, 'Stop');

        // markers.add(Marker(markerId: MarkerId('stop_${stops.indexOf(stop)}'), position: stopLocation, infoWindow: InfoWindow(title: 'Stop')));
        polylineCoordinates.add(stopLocation);
      }
      
    
  // });
}

   // Add origin and destination to polyline
      polylineCoordinates.insert(0, origin);
      polylineCoordinates.add(destination);

   
    // Extract polyline coordinates
    //   if (routeData['stops'] != null) {
    //    List<dynamic> stops = routeData['stops'] as List<dynamic>;
    //    polylineCoordinates = (stops.map((stop) => convertToLatLng('${stop['lat']}, ${stop['lng']}'))).toList();
    //  }


    // Move camera to a position that includes both origin and destination
    LatLngBounds bounds = LatLngBounds(southwest: origin, northeast: destination);
    mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    setState(() {});
  }
  
  
  
  // setState(() {});
}


//user location
// Future<void> addMarker(String markerId, LatLng position, String title) async {
//     double distance = await calculateDistance(position);
//     markers.add(Marker(
//       markerId: MarkerId(markerId),
//       position: position,
//       infoWindow: InfoWindow(
//         title: title,
//         snippet: 'Distance: ${distance.toStringAsFixed(2)} km',
//       ),
//       icon: BitmapDescriptor.defaultMarkerWithHue(
//           title == 'Origin' ? BitmapDescriptor.hueGreen : (title == 'Destination' ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed)),
//     ));
//   }
  Future<void> addMarker(String markerId, LatLng position, String title) async {
  double distance = await calculateDistance(position);
  BitmapDescriptor icon;

  if (title == 'Origin') {
    icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  } else if (title == 'Destination') {
    icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }
  else if (title == 'You') {
    icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
  } 
   else {
    icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    
  }
  

  markers.add(Marker(
    markerId: MarkerId(markerId),
    position: position,
    infoWindow: InfoWindow(
      title: title,
      snippet: 'Distance: ${distance.toStringAsFixed(2)} km',
    ),
    icon: icon,
  ));
}

  Future<double> calculateDistance(LatLng destination) async {
    // Get the user's current location
    Position userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //mark user location with an icon but dont use marker
    // markers.add(Marker(markerId: MarkerId('userLocation'), position: LatLng(userLocation.latitude,userLocation.longitude), infoWindow: InfoWindow(title: 'You'),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow)));

    //mark user location with an icon but dont use marker
    addMarker('userLocation', LatLng(userLocation.latitude,userLocation.longitude), 'You');

   
    // Calculate the distance between the user's current location and the destination
    double distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Convert distance from meters to kilometers
    return distance / 1000.0;
  }


LatLng convertToLatLng(String coordinates) {
  List<String> parts = coordinates.split(', ');
  double lat = double.parse(parts[0]);
  double lng = double.parse(parts[1]);
  return LatLng(lat, lng);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Travel Route'),foregroundColor: Colors.white,
        backgroundColor: Colors.green[300],
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: const CameraPosition(target: LatLng(24.87, 67.03),zoom: 10),
        markers: markers.toSet(),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            color: const Color.fromARGB(255, 7, 79, 205),
            width: 5,
            geodesic:   true,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            points: polylineCoordinates,
          ),
          
        },
      ),
    );
    
  }
  
}

