import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoiam1vbnRlc2M0OCIsImEiOiJjbHU1emVwaXMwbmQxMmpwZXVnamxlOHFiIn0.WM46Vcq0y50lAdh-iX1r-g';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late StreamSubscription<Position> _positionStream;
  LatLng? myPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentLocation();
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        myPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStream.cancel();
    super.dispose();
  }

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Map'),
        backgroundColor: Colors.blueAccent,
      ),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
        options: MapOptions(
          initialCenter: myPosition!,
          minZoom: 5,
          maxZoom: 25,
          initialZoom: 18,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
            additionalOptions: const {
              'accessToken': MAPBOX_ACCESS_TOKEN,
              'id': 'mapbox/streets-v12'
            },
          ),
          CircleLayer(
            circles: [
              CircleMarker(
                point: myPosition!,
                radius: 1,
                useRadiusInMeter: true,
                color: Colors.red.withOpacity(0.3),
                borderColor: Colors.red.withOpacity(0.7),
                borderStrokeWidth: 2,
              )
            ],
          ),
        ],
      ),
    );
  }
}