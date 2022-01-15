import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkirisca/directions_repository.dart';
import 'package:parkirisca/model/directions_model.dart';
import 'package:parkirisca/model/parking_model.dart';
import 'package:http/http.dart' as http;

class ParkingProvider extends ChangeNotifier {
  List<dynamic>? _parkingData;
  Set<Marker> _markers = {};
  Directions? _selectedRoute;

  List<dynamic> get parkingData => _parkingData ?? [];
  Set<Marker> get markers => _markers;
  Directions? get selectedRoute => _selectedRoute;

  Future<void> fetchParking() async {
    final response = await http.get(
        Uri.parse('https://api.ontime.si/api/v1/parking/?format=json&page=1'));

    if (response.statusCode == 200) {
      final parsed = json.decode(utf8.decode(response.bodyBytes))["results"];
      _parkingData = parsed;
      //{parking_id: 2, name: PETKOVÅ KOVO NABREÅ½JE II., lat: 46.05222222222222, lng: 14.511666666666667, created_date: 2022-01-05T17:58:39.001556+01:00, refreshed_date: 2022-01-05T18:54:00+01:00, occupancy: 128, capacity: 87, handicapped: 1, electric: 0, trend: 0}
      /*_parkingData!.add({
        'parking_id': 1000,
        'name': 'Kabinet doc. dr. Rok Rupnik (PMP BTW)',
        'lat': 46.050000,
        'lng': 14.469112,
        'refreshed_date': '2022-01-05T18:57:00+01:00',
        "occupancy": 1,
        "capacity": 0
      });*/
      print('API data refreshed');
      notifyListeners();
    } else {
      throw Exception('Failed to load');
    }
  }

  void init() async {
    print('initializing');
    await fetchParking().then((value) {
      print(_parkingData);
      spawnMarkers();
    });
    notifyListeners();
  }

  void reset() {
    _selectedRoute = null;
    notifyListeners();
  }

  void showRoute(Directions? d) {
    _selectedRoute = d;
    notifyListeners();
  }

  void addParkingSpot(dynamic m) {
    _parkingData!.add(m);
    print(_parkingData!.last);
    print("Done!");
    //notifyListeners();
  }

  void spawnMarkers() async {
    final Uint8List spotIcon =
        await getBytesFromAsset('assets/icons/spot.png', 100);
    final Uint8List garageIcon =
        await getBytesFromAsset('assets/icons/garage.png', 100);
    final Uint8List parkingIcon =
        await getBytesFromAsset('assets/icons/parking.png', 100);
    final Uint8List rokIcon =
        await getBytesFromAsset('assets/icons/rok.png', 200);

    if (_markers.isNotEmpty) _markers = {};
    int occ, cap;
    for (int i = 0; i < _parkingData!.length; i++) {
      occ = _parkingData![i]['occupancy'];
      cap = _parkingData![i]['capacity'];
      LatLng pos = LatLng(_parkingData![i]['lat'], _parkingData![i]['lng']);
      Uint8List icon =
          (_parkingData![i]['name'].toString().substring(0, 2) == 'PH')
              ? parkingIcon
              : spotIcon;
           
      _markers.add(
        Marker(
          markerId: MarkerId('id-' + i.toString()),
          position: pos,
          icon: (_parkingData![i]['parking_id'] == 1000)
              ? BitmapDescriptor.fromBytes(rokIcon)
              : BitmapDescriptor.fromBytes(icon),
          infoWindow: InfoWindow(
              title: _parkingData![i]['name'],
              snippet: (_parkingData![i]['parking_id'] == 1000)
                  ? 'Zasedenost: Samski'
                  : 'Zasedenost: ' +
                      occ.toString() +
                      '/' +
                      (cap + occ).toString()),
          // onTap: () async {
          //   Position _currentPosition = await Geolocator.getCurrentPosition();
          //   await DirectionsRepository()
          //       .getDirections(
          //           origin: LatLng(
          //               _currentPosition.latitude, _currentPosition.longitude),
          //           destination: pos)
          //       .then(
          //     (value) {
          //       _selectedRoute = value;
          //       notifyListeners();
          //     },
          //   );
          // },
        ),
      );
    }
    notifyListeners();
  }
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}
