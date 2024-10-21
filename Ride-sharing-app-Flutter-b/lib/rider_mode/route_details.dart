class RouteDetails {
  late String origin;
  late String destination;
  late List<Map<String, double>> stops;
  // Add other necessary properties

  RouteDetails(this.origin, this.destination, this.stops);

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'stops': stops,
      // Add other properties
    };
  }
}
