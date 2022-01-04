class Parking {
  Parking(
      {required this.parkingId,
      required this.name,
      required this.lat,
      required this.lng});

  int parkingId;
  String name;
  double lat;
  double lng;

  factory Parking.fromJson(Map<String, dynamic> json) => Parking(
        parkingId: json["parking_id"],
        name: json["name"],
        lat: json["lat"],
        lng: json["lng"],
      );
}
