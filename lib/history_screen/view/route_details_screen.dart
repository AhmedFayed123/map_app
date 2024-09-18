import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../map_screen/database/database_helper.dart';

class RouteDetailsScreen extends StatelessWidget {
  final RouteData startRoute;
  final RouteData endRoute;

  const RouteDetailsScreen({super.key,
    required this.startRoute,
    required this.endRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            (startRoute.start.latitude + endRoute.end.latitude) / 2,
            (startRoute.start.longitude + endRoute.end.longitude) / 2,
          ),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  startRoute.start,
                  ...startRoute.points,
                  endRoute.end,
                ],
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: startRoute.start,
                child: const Icon(Icons.location_on, color: Colors.green, size: 40.0),
              ),
              Marker(
                width: 40.0,
                height: 40.0,
                point: endRoute.end,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
