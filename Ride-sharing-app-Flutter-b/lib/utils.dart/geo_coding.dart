import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  // final String apiKey;

  // GeocodingService({required this.apiKey});

  static Future<Map<String, dynamic>?> getLatLangFromAddress(
      String address) async {
    String kPLACES_API_KEY = "AIzaSyCdLAHV2BMZg_vfQcb8PZc9WggHr0w_U0A";
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$kPLACES_API_KEY';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final Map<String, dynamic> location =
            data['results'][0]['geometry']['location'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
        };
      }
    }
    return null;
  }
}
