import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../map_screen/database/database_helper.dart';

class SelectMapScreenController extends GetxController with GetTickerProviderStateMixin {
  var currentLocation = Rxn<Position>();
  var destination = Rxn<LatLng>();
  var routePoints = <LatLng>[].obs;
  var loading = false.obs;
  var currentZoom = 13.0.obs;

  final MapController mapController = MapController();
  late AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permission denied.');
        return;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLocation.value = position;

      Geolocator.getPositionStream().listen((Position position) {
        currentLocation.value = position;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void setDestination(LatLng dest) {
    destination.value = dest;
    fetchRoute();
  }

  Future<void> fetchRoute() async {
    if (currentLocation.value == null || destination.value == null) return;
    loading.value = true;

    final start =
        '${currentLocation.value!.longitude},${currentLocation.value!.latitude}';
    final end = '${destination.value!.longitude},${destination.value!.latitude}';

    try {
      final response = await http.get(Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62485c13e68a964040c1b3315dfc971770a5&start=$start&end=$end'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          routePoints.value = coordinates.map<LatLng>((point) {
            return LatLng(point[1], point[0]);
          }).toList();

          final routeData = RouteData(
            name: 'My Route',
            start: LatLng(currentLocation.value!.latitude, currentLocation.value!.longitude),
            end: destination.value!,
            points: routePoints,
          );
          await DatabaseHelper().insertRoute(routeData);
          print('Route successfully saved to the database.');
        } else {
          print('No features found in API response.');
        }
      } else {
        print('Failed to fetch route. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    loading.value = false;
  }

  Future<void> fetchRouteBetweenTwoPlaces(LatLng start, LatLng end) async {
    loading.value = true;

    final startCoord = '${start.longitude},${start.latitude}';
    final endCoord = '${end.longitude},${end.latitude}';

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62485c13e68a964040c1b3315dfc971770a5&start=$startCoord&end=$endCoord',
        ),
        headers: {
          'Authorization': '5b3ce3597851110001cf62485c13e68a964040c1b3315dfc971770a5', // Ensure to replace with the actual API key or relevant headers
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          routePoints.value = coordinates.map<LatLng>((point) {
            return LatLng(point[1], point[0]);
          }).toList();

          final routeData = RouteData(
            name: 'Route between ${start.latitude},${start.longitude} and ${end.latitude},${end.longitude}',
            start: start,
            end: end,
            points: routePoints,
          );
          await DatabaseHelper().insertRoute(routeData);
        }
      } else {
        print('Failed to fetch route. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    loading.value = false;
  }

  void animatedMapMove(LatLng destLocation, double destZoom) {
    final initialCenter = LatLng(
      currentLocation.value?.latitude ?? destLocation.latitude,
      currentLocation.value?.longitude ?? destLocation.longitude,
    );

    final latTween = Tween<double>(
      begin: initialCenter.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: initialCenter.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: currentZoom.value,
      end: destZoom,
    );

    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.addListener(() {
      final newZoom = zoomTween.evaluate(animation);
      currentZoom.value = newZoom;

      mapController.move(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        newZoom,
      );
    });

    animationController.forward(from: 0);
  }

  void centerMapOnCurrentLocation() {
    if (currentLocation.value != null) {
      animatedMapMove(
        LatLng(currentLocation.value!.latitude, currentLocation.value!.longitude),
        15.0,
      );
    }
  }
}
