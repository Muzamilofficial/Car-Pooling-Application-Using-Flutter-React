import 'package:intl/intl.dart';

class Helper {
  static String formatDate(String date) {
    String inputDateString = date;

    // Parse the input date string into a DateTime object
    DateTime inputDate = DateTime.parse(inputDateString);

    // Define the output date format
    DateFormat outputDateFormat = DateFormat('dd-MM-yyyy');

    // Format the DateTime object into the desired output string format
    String formattedDate = outputDateFormat.format(inputDate);

    print(formattedDate); // Output: 31-12-2023
    return formattedDate;
  }
}
