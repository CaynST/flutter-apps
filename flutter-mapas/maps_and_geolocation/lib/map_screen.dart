import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _defaultZoom = 13.0;

  late final MapController _mapController;
  LatLng _center = const LatLng(28.6139, 77.2090); // New Delhi, India

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeeksforGeeks Maps'),
        backgroundColor: const Color(0xFF2F8D46), // GeeksforGeeks green
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: _defaultZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.maps_and_geolocation',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: _center,
                child: const Icon(
                  Icons.location_on,
                  size: 48.0,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: 'Get Location',
        backgroundColor: const Color(0xFF2F8D46), // GeeksforGeeks green
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage(
        'Location permissions are permanently denied, '
        'we cannot request permissions.',
      );
      return;
    }

    // When permissions are granted, get the position of the device.
    try {
      final Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_center, _defaultZoom);
    } catch (e) {
      _showMessage('Error getting location: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
