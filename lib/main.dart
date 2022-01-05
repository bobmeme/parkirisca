import 'package:flutter/material.dart';
import 'package:parkirisca/google_map_widget.dart';
import 'package:provider/provider.dart';
import 'package:parkirisca/providers/parking_provider.dart';

void main() => runApp(ChangeNotifierProvider(
      create: (_) => ParkingProvider(),
      child: const MyApp(),
    ));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parkirisca',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
      ),
      home: const Scaffold(
        body: GoogleMapWidget(),
      ),
    );
  }
}
