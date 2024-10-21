import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleMapsService {
  // final String apiKey;

  // GoogleMapsService(this.apiKey);

  Future<Map<String, dynamic>> getDistanceTime(
      String origin, String destination) async {
    String apiKey = "AIzaSyCdLAHV2BMZg_vfQcb8PZc9WggHr0w_U0A";
    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$origin&destinations=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final elements = data['rows'][0]['elements'][0];
        return {
          'distance': elements['distance']['text'],
          'duration': elements['duration']['text'],
        };
      } else {
        throw Exception('Error with response status: ${data['status']}');
      }
    } else {
      throw Exception('Failed to load distance and time data');
    }
  }
}
