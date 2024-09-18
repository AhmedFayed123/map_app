import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controller/map_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = Get.put(MapScreenController());

    final args = Get.arguments as Map<String, double>?;

    if (args != null) {
      final startLat = args['startLat']!;
      final startLng = args['startLng']!;
      final endLat = args['endLat']!;
      final endLng = args['endLng']!;

      // Set the initial current location and destination
      mapController.currentLocation.value = Position(
        latitude: startLat,
        longitude: startLng,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
      mapController.setDestination(LatLng(endLat, endLng));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Current Location and Route'),
      ),
      body: Obx(() {
        // Check if the current location is available
        if (mapController.currentLocation.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FlutterMap(
          mapController: mapController.mapController,
          options: MapOptions(
            initialCenter: LatLng(
              mapController.currentLocation.value!.latitude,
              mapController.currentLocation.value!.longitude,
            ),
            initialZoom: 12.0,
            onTap: (tapPosition, point) {
              mapController.setDestination(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    mapController.currentLocation.value!.latitude,
                    mapController.currentLocation.value!.longitude,
                  ),
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
                if (mapController.destination.value != null)
                  Marker(
                    point: mapController.destination.value!,
                    child: const Icon(Icons.flag, color: Colors.blue, size: 40),
                  ),
              ],
            ),
            Obx(() {
              if (mapController.routePoints.isEmpty) {
                return Container(); // Return an empty container if no route points
              }
              return PolylineLayer(
                polylines: [
                  Polyline(
                    points: mapController.routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              );
            }),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mapController.centerMapOnCurrentLocation(),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
