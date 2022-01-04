import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parkirisca/model/parking_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';

/* WOOZY HACKS
Future<List<Parking>> fetchPost() async {
  final response = await http.get(
      Uri.parse('https://api.ontime.si/api/v1/parking/?format=json&page=1'));

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body)["results"];

    return parsed.map<Parking>((json) => Parking.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load');
  }
}
*/

void requestLocationPermission() async {
  final status = await Permission.locationWhenInUse.request();
  if (status == PermissionStatus.denied) {
  } else if (status == PermissionStatus.permanentlyDenied) {
    await openAppSettings();
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Parking>> futureParking;

  late GoogleMapController mapController;

  // LJ center coordinates -> random location in LJ (46.054939, 14.504820)
  final LatLng _center = const LatLng(46.056946, 14.505751);
  final double _defaultZoom = 14;
  late String _mapStyle;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((Position position) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: _defaultZoom)));
    });

    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => requestLocationPermission());
    //futureParking = fetchPost();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parkirisca',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
      ),
      home: Scaffold(
        body: GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: _defaultZoom,
          ),
        ),
      ),
    );
  }
}

/* WOOZY HACKS

FutureBuilder<List<Parking>>(
          future: futureParking,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => Container(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Color(0xff97FFFF),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data![index].name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
 */
