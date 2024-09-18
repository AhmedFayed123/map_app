import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/history_controller.dart'; // استبدل بهذا المسار الصحيح
import 'route_details_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تسجيل الـ Controller فقط إذا لم يكن مسجلاً بالفعل
    if (!Get.isRegistered<HistoryController>()) {
      Get.put(HistoryController());
    }
    final historyController = Get.find<HistoryController>();

    // إعادة تحميل البيانات كلما تمت زيارة الشاشة
    historyController.loadHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.route),
            onPressed: () {
              final selectedRoutes = historyController.selectedRoutesList;
              if (selectedRoutes[0] != null && selectedRoutes[1] != null) {
                Get.to(() => RouteDetailsScreen(
                  startRoute: selectedRoutes[0]!,
                  endRoute: selectedRoutes[1]!,
                ));
              } else {
                Get.snackbar('Error', 'Please select two routes first.');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (historyController.historyRoutes.isEmpty) {
          return const Center(child: Text('No routes available.'));
        }

        return ListView.builder(
          itemCount: historyController.historyRoutes.length,
          itemBuilder: (context, index) {
            final route = historyController.historyRoutes[index];

            return ListTile(
              title: Text(route.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start: ${route.start.latitude}, ${route.start.longitude}'),
                  Text('End: ${route.end.latitude}, ${route.end.longitude}'),
                ],
              ),
              leading: Obx(() {
                final isSelected = historyController.selectedRoutesList.contains(route);
                return Checkbox(
                  value: isSelected,
                  onChanged: (isChecked) {
                    if (isChecked == true) {
                      if (historyController.selectedRoutesList[0] == null) {
                        historyController.selectRoute(0, route);
                      } else if (historyController.selectedRoutesList[1] == null) {
                        historyController.selectRoute(1, route);
                      } else {
                        historyController.selectRoute(0, route); // Handle overwrite if needed
                      }
                    } else {
                      if (historyController.selectedRoutesList.contains(route)) {
                        int index = historyController.selectedRoutesList.indexOf(route);
                        historyController.selectRoute(index, null);
                      }
                    }
                  },
                );
              }),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final shouldDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text('Are you sure you want to delete this route?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete) {
                    await historyController.deleteRoute(route.id!);
                  }
                },
              ),
              onTap: () {
                // Handle item tap for details or editing if needed
              },
            );
          },
        );
      }),
    );
  }
}
