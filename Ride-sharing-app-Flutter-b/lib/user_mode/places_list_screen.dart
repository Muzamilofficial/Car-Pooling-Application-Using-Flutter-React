import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import "package:http/http.dart" as http;

class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({super.key});

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  TextEditingController controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = "";
  List<dynamic> placesList = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onChange);
  }

  void onChange() {
    if (_sessionToken.isEmpty) {
      setState(() {
        _sessionToken = uuid.v4(); // Generates a unique session token for each session.
      });
    }
    getSuggestion(controller.text);
  }

void getSuggestion(String input) async {
  String kPLACES_API_KEY = "AIzaSyDYNJVSQHG-_I6eC6VXqhSrcpYmXTKWtU8";
  String baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  String request = "$baseUrl?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken";

  try {
    var response = await http.get(Uri.parse(request));
    log("Response Status: ${response.statusCode}");
    log("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      log("Error: ${response.statusCode}");
      throw Exception("Failed to load Data");
    }
  } catch (e) {
    log("Exception: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        backgroundColor: Colors.green[300],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Enter Location',
                prefixIcon: const Icon(Icons.location_on),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: placesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.pop(context, placesList[index]["description"]);
                  },
                  title: Text(placesList[index]["description"]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
