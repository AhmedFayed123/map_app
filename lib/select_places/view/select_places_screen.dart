import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controller/map_screen_controller.dart';

class SelectPlacesScreen extends StatelessWidget {
  const SelectPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = Get.put(SelectMapScreenController());
    final selectedPlaces = <LatLng?>[null, null].obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Two Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (selectedPlaces[0] != null && selectedPlaces[1] != null) {
                mapController.fetchRouteBetweenTwoPlaces(
                  selectedPlaces[0]!,
                  selectedPlaces[1]!,
                ).then((_) {
                  // Navigate back only after the route has been fetched and stored
                  Get.back();
                }).catchError((error) {
                  // Handle errors in fetching or storing the route
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                });
              } else {
                // Handle case where places are not selected
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select two places')),
                );
              }
            },
          ),
        ],
      ),
      body: Obx(
            () => FlutterMap(
          mapController: mapController.mapController,
          options: MapOptions(
            initialCenter: const LatLng(0.0, 0.0),
            initialZoom: 4.0,
            onTap: (tapPosition, point) {
              if (selectedPlaces[0] == null) {
                selectedPlaces[0] = point;
              } else if (selectedPlaces[1] == null) {
                selectedPlaces[1] = point;
              } else {
                // Reset selection if both places are selected
                selectedPlaces[0] = point;
                selectedPlaces[1] = null;
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                if (selectedPlaces[0] != null)
                  Marker(
                    point: selectedPlaces[0]!,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                if (selectedPlaces[1] != null)
                  Marker(
                    point: selectedPlaces[1]!,
                    child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                  ),
              ],
            ),
            PolylineLayer(
              polylines: [
                if (mapController.routePoints.isNotEmpty)
                  Polyline(
                    points: mapController.routePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
