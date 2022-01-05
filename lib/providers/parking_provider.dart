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
      final parsed = json.decode(response.body)["results"];
      _parkingData = parsed;
      print('API data refreshed');
      notifyListeners();
    } else {
      throw Exception('Failed to load');
    }
  }

  void reset() {
    _selectedRoute = null;
    notifyListeners();
  }

  void spawnMarkers() async {
    final Uint8List spotIcon =
        await getBytesFromAsset('assets/icons/spot.png', 100);
    final Uint8List garageIcon =
        await getBytesFromAsset('assets/icons/garage.png', 100);
    final Uint8List parkingIcon =
        await getBytesFromAsset('assets/icons/parking.png', 100);

    if (_markers.isNotEmpty) _markers = {};
    int occ, cap;
    for (int i = 0; i < _parkingData!.length; i++) {
      occ = _parkingData![i]['occupancy'];
      cap = _parkingData![i]['capacity'];
      LatLng pos = LatLng(_parkingData![i]['lat'], _parkingData![i]['lng']);
      Uint8List icon =
          (_parkingData![i]['name'].toString().substring(0, 2) == 'PH')
              ? garageIcon
              : spotIcon;
      _markers.add(
        Marker(
          markerId: MarkerId('id-' + i.toString()),
          position: pos,
          icon: BitmapDescriptor.fromBytes(icon),
          infoWindow: InfoWindow(
              title: _parkingData![i]['name'],
              snippet: 'Posodobljeno ob: ' +
                  _parkingData![i]['refreshed_date'] +
                  '\nZasedenost: ' +
                  occ.toString() +
                  '/' +
                  (cap + occ).toString()),
          onTap: () async {
            Position _currentPosition = await Geolocator.getCurrentPosition();
            await DirectionsRepository()
                .getDirections(
                    origin: LatLng(
                        _currentPosition.latitude, _currentPosition.longitude),
                    destination: pos)
                .then((value) {
              _selectedRoute = value;
              notifyListeners();
            });
          },
        ),
      );
    }
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
