import 'dart:convert';

List<Parking> ParkingFromJson(String str) =>
    List<Parking>.from(json.decode(str).map((x) => Parking.fromJson(x)));

class Parking {
  Parking({
    required this.parkingId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.occupancy,
    required this.capacity,
    required this.handicapped,
    required this.electric,
  });

  int parkingId;
  String name;
  double lat;
  double lng;
  int occupancy;
  int capacity;
  int handicapped;
  int electric;

  factory Parking.fromJson(Map<String, dynamic> json) => Parking(
        parkingId: json["parking_id"],
        name: json["name"],
        lat: json["lat"],
        lng: json["lng"],
        occupancy: json["occupancy"],
        capacity: json["capacity"],
        handicapped: json["handicapped"],
        electric: json["electric"],
      );
}
