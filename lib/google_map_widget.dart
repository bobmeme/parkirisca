import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkirisca/model/parking_model.dart';
import 'package:parkirisca/model/directions_model.dart';
import 'package:parkirisca/providers/parking_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'directions_repository.dart';

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
  late Future<List<Parking>> futureData;

  late GoogleMapController mapController;

  // LJ center coordinates -> random location in LJ (46.054939, 14.504820)
  final LatLng _center = const LatLng(46.056946, 14.505751);
  final double _defaultZoom = 14;
  late String _mapStyle;

  Position? _currentPosition;
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: (_currentPosition == null)
            ? _center
            : LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: _defaultZoom)));
    Provider.of<ParkingProvider>(context, listen: false).init();
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
            .listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
        });
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: _defaultZoom)));
        /*mapController
        .animateCamera(CameraUpdate.newLatLngBounds(_route!.bounds, 50));*/
      },
    );

    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => requestLocationPermission());
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).viewPadding.top;

    Directions? selectedRoute = context.watch<ParkingProvider>().selectedRoute;

    if (selectedRoute != null) {
      mapController.animateCamera(
          CameraUpdate.newLatLngBounds(selectedRoute.bounds, 50));
    }

    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: _onMapCreated,
          markers: context.watch<ParkingProvider>().markers,
          polylines: {
            if (selectedRoute != null)
              Polyline(
                polylineId: const PolylineId('overview_polyline'),
                color: Colors.pink.shade400,
                width: 5,
                points: selectedRoute.polylinePoints
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList(),
              )
          },
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
                  context.read<ParkingProvider>().reset();
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
                onPressed: () async {
                  var result = await showFilter(context);
                  if (result == null) return;
                  if (result.length != 0) {
                    // result[0] = lat, result[1] = lng
                    print(result[0]);
                    // Position _currentPosition =
                    //     await Geolocator.getCurrentPosition();
                    await DirectionsRepository()
                        .getDirections(
                            origin: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            destination: LatLng(result[0], result[1]))
                        .then((value) =>
                            context.read<ParkingProvider>().showRoute(value));
                  }
                },
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
                  if (_currentPosition != null) {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            zoom: _defaultZoom),
                      ),
                    );
                  }
                },
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
                  Icons.add_circle_outline,
                  size: 22.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddParking()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future showFilter(BuildContext context) async {
    await context.read<ParkingProvider>().fetchParking();
    List<dynamic> parkData = context.read<ParkingProvider>().parkingData;

    Widget buildParkTile(BuildContext context, int index) {
      final plc = parkData[index];
      return GestureDetector(
        onTap: () async {
          var result = await showDetails(context, plc);
          if (result != null && result.length != 0) {
            Navigator.pop(context, result);
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        plc["name"],
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      const Spacer(),
                      Text(
                        plc["occupancy"].toString(),
                      ),
                      const Text("/"),
                      Text(
                        (plc["occupancy"] + plc["capacity"]).toString(),
                      ),
                    ],
                  ),
                ),
                Text(
                  plc["capacity"] == 0 ? "ZASEDENO" : "PROSTO",
                  style: TextStyle(
                      color: plc["capacity"] == 0 ? Colors.red : Colors.green),
                )
              ],
            ),
          ),
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10.0),
                  primary: Colors.white,
                ),
                child: const Icon(
                  Icons.close,
                  size: 22.0,
                  color: Colors.black87,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Izberite parametre za iskanje parkirnega prostora.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: parkData.length,
                  itemBuilder: (BuildContext context, int index) =>
                      buildParkTile(context, index),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showDetails(BuildContext context, final data) async => await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(data["name"]),
          content: const Text("This is my message."),
          actions: [
            TextButton(
              child: const Text("CLOSE"),
              onPressed: () => Navigator.pop(context, []),
            ),
            TextButton(
              child: const Text("GO"),
              onPressed: () =>
                  Navigator.pop(context, [data["lat"], data["lng"]]),
            ),
          ],
        ),
      );
}

class Parking1 {
  String name = '';
  double lat = 0.0;
  double lng = 0.0;
  double price = 0.0;
  bool occupied = false;
}

List<Parking1> data = [];

class AddParking extends StatefulWidget {
  const AddParking({Key? key}) : super(key: key);

  @override
  AddParkingState createState() {
    return AddParkingState();
  }
}

class AddParkingState extends State<AddParking> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  Parking1 _data = Parking1();

  void submit() {
    if (_formKey.currentState!.validate()) {
      _data.occupied = isChecked;
      _formKey.currentState!.save();
      Parking1 temp = Parking1();
      temp.name = _data.name;
      temp.lat = _data.lat;
      temp.lng = _data.lng;
      temp.occupied = _data.occupied;
      temp.price = _data.price;

      data.add(temp);
      for (int i = 0; i < data.length; i++) {
        print(data[i].name);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add parking"),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter parking name';
                      return null;
                    },
                    onSaved: (value) {
                      _data.name = value.toString();
                    },
                    decoration: new InputDecoration(labelText: 'Parking name')),
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter latitude number';
                      return null;
                    },
                    onSaved: (value) {
                      _data.lat = double.parse(value!);
                    },
                    decoration: new InputDecoration(labelText: 'Latitude')),
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter longitude number';
                      return null;
                    },
                    onSaved: (value) {
                      _data.lng = double.parse(value!);
                    },
                    decoration: new InputDecoration(labelText: 'Longitude')),
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter price number';
                      return null;
                    },
                    onSaved: (value) {
                      _data.price = double.parse(value!);
                    },
                    decoration: new InputDecoration(labelText: 'Price')),
                CheckboxListTile(
                  checkColor: Colors.white,
                  title: Text("Occupied"),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                Container(
                  width: screenSize.width,
                  child: ElevatedButton(
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: submit,
                  ),
                  margin: EdgeInsets.only(top: 20.0),
                ),
              ],
            ),
          )),
    );
  }
}
