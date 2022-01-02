import 'dart:convert';

List<Parking> ParkingFromJson(String str) =>
    List<Parking>.from(json.decode(str).map((x) => Parking.fromJson(x)));

class Parking {
  Parking(
      {required this.parking_id,
      required this.name,
      required this.lat,
      required this.lng});

  int parking_id;
  String name;
  double lat;
  double lng;

  factory Parking.fromJson(Map<String, dynamic> json) => Parking(
        parking_id: json["parking_id"],
        name: json["name"],
        lat: json["lat"],
        lng: json["lng"],
      );
}
