import 'package:url_launcher/url_launcher.dart';

class PhoneCallService {
  static void makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
    // if (await canLaunch(launchUri.toString())) {
    //   await launch(launchUri.toString());
    // } else {
    //   throw 'Could not launch $launchUri';
    // }
  }
}
