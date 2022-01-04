import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkirisca/model/parking_model.dart';
import 'package:http/http.dart' as http;

class ParkingProvider extends ChangeNotifier {
  List<dynamic>? _parkingData;
  Set<Marker> _markers = {};

  List<dynamic> get parkingData => _parkingData ?? [];
  Set<Marker> get markers => _markers;

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

  void spawnMarkers() {
    if (_markers.isNotEmpty) return;
    int occ, cap;
    for (int i = 0; i < _parkingData!.length; i++) {
      occ = _parkingData![i]['occupancy'];
      cap = _parkingData![i]['capacity'];
      _markers.add(
        Marker(
          markerId: MarkerId('id-' + i.toString()),
          position: LatLng(_parkingData![i]['lat'], _parkingData![i]['lng']),
          infoWindow: InfoWindow(
              title: _parkingData![i]['name'],
              snippet: 'Posodobljeno ob: ' +
                  _parkingData![i]['refreshed_date'] +
                  '\nZasedenost: ' +
                  occ.toString() +
                  '/' +
                  (cap + occ).toString()),
        ),
      );
    }
  }
}
