import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkirisca/providers/parking_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

void requestLocationPermission() async {
  final status = await Permission.locationWhenInUse.request();
  if (status.isGranted) {
    return;
  } else if (status == PermissionStatus.denied) {
  } else if (status == PermissionStatus.permanentlyDenied) {
    await openAppSettings();
  }
}

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late List<dynamic> _parkingData;
  Set<Marker> _markers = {};

  late GoogleMapController mapController;

  // LJ center coordinates -> random location in LJ (46.054939, 14.504820)
  final LatLng _center = const LatLng(46.056946, 14.505751);
  final double _defaultZoom = 14;
  late String _mapStyle;

  late Position _currentPosition;
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: _defaultZoom)));
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: _defaultZoom)));
    });

    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => requestLocationPermission());
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).viewPadding.top;
    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          onMapCreated: _onMapCreated,
          markers: context.watch<ParkingProvider>().markers,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: _defaultZoom,
          ),
        ),
        Positioned(
          left: 15,
          top: statusBarHeight + 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10.0),
                  primary: Colors.white,
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 22.0,
                  color: Colors.black87,
                ),
                onPressed: () async => await context
                    .read<ParkingProvider>()
                    .fetchParking()
                    .then((value) {
                  context.read<ParkingProvider>().spawnMarkers();
                }),
              ),
              const SizedBox(
                height: 8.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10.0),
                  primary: Colors.white,
                ),
                child: const Icon(
                  Icons.filter_alt_rounded,
                  size: 22.0,
                  color: Colors.black87,
                ),
                onPressed: () {},
              ),
              const SizedBox(
                height: 8.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10.0),
                  primary: Colors.white,
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  size: 22.0,
                  color: Colors.lightBlue,
                ),
                onPressed: () {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: LatLng(_currentPosition.latitude,
                              _currentPosition.longitude),
                          zoom: _defaultZoom),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
