import 'package:get/get.dart';
import '../../map_screen/database/database_helper.dart';

class HistoryController extends GetxController {
  var historyRoutes = <RouteData>[].obs;
  var selectedRoutes = <RouteData?>[null, null].obs;

  @override
  void onInit() {
    super.onInit();
    // Load history data when the controller is initialized
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      print('Loading history...');
      final routes = await DatabaseHelper().getAllRoutes();
      print('Routes fetched: $routes');
      historyRoutes.assignAll(routes); // Update the routes list
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> reloadHistory() async {
    await loadHistory(); // Reload data when needed
  }

  Future<void> addRoute(RouteData route) async {
    try {
      await DatabaseHelper().insertRoute(route);
      historyRoutes.add(route);
    } catch (e) {
      print('Error adding route: $e');
    }
  }

  Future<void> deleteRoute(int routeId) async {
    try {
      await DatabaseHelper().deleteRoute(routeId);
      historyRoutes.removeWhere((route) => route.id == routeId);
      // Optionally, you can reload the history after deletion
      // await loadHistory();
    } catch (e) {
      print('Error deleting route: $e');
    }
  }

  void selectRoute(int index, RouteData? route) {
    if (index < 0 || index >= selectedRoutes.length) return;

    if (route == null) {
      // Deselect if route is null
      selectedRoutes[index] = null;
    } else {
      // Handle selection logic to ensure only two routes are selected
      if (selectedRoutes.contains(route)) {
        // If the route is already selected, deselect it
        selectedRoutes[selectedRoutes.indexOf(route)] = null;
      } else {
        // Select the route
        selectedRoutes[index] = route;
      }
    }
  }

  List<RouteData?> get selectedRoutesList => selectedRoutes;
}
