import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maptask4new/select_places/view/select_places_screen.dart';
import 'history_screen/view/history_screen.dart';
import 'map_screen/view/map_screen.dart';
import 'nav_bar_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final BottomNavController controller = Get.put(BottomNavController());

    final List<Widget> pages = [
      const MapScreen(),
      const SelectPlacesScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
            () => ConvexAppBar(
          backgroundColor: Colors.blue,
          style: TabStyle.reactCircle,
          items: const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.map, title: 'map'),
            TabItem(icon: Icons.history, title: 'History'),
          ],
          initialActiveIndex: controller.selectedIndex.value,
          onTap: (index) => controller.changeIndex(index),
        ),
      ),
    );
  }
}
