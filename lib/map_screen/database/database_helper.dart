import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RouteData {
  final int? id;
  final String name;
  final LatLng start;
  final LatLng end;
  final List<LatLng> points;
  bool selected;

  RouteData({
    this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.points,
    this.selected = false,
  });
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'routes.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE routes('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'name TEXT DEFAULT "Unnamed Route", '
              'startLat REAL DEFAULT 0.0, '
              'startLng REAL DEFAULT 0.0, '
              'endLat REAL DEFAULT 0.0, '
              'endLng REAL DEFAULT 0.0, '
              'points TEXT DEFAULT "")',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 4) {
          db.execute(
            'ALTER TABLE routes ADD COLUMN points TEXT DEFAULT ""',
          );
        }
      },
      version: 4, // Increment the version to trigger the upgrade
    );
  }

  Future<void> insertRoute(RouteData route) async {
    final db = await database;
    final routeMap = {
      'name': route.name,
      'startLat': route.start.latitude,
      'startLng': route.start.longitude,
      'endLat': route.end.latitude,
      'endLng': route.end.longitude,
      'points': route.points.map((p) => '${p.latitude},${p.longitude}').join(';'),
    };
    try {
      await db.insert('routes', routeMap);
    } catch (e) {
      print('Failed to insert route: $e');
    }
  }

  Future<List<RouteData>> getAllRoutes() async {
    final db = await database;
    final maps = await db.query('routes');

    return maps.map((map) {
      final pointsString = map['points'] as String?;
      final points = pointsString != null
          ? pointsString.split(';').map((point) {
        final coords = point.split(',');
        try {
          final latitude = double.parse(coords[0]);
          final longitude = double.parse(coords[1]);
          return LatLng(latitude, longitude);
        } catch (e) {
          print('Failed to parse point: $point, error: $e');
          return null; // Skip this point if there's an error
        }
      }).whereType<LatLng>().toList() // Filter out any null values
          : <LatLng>[]; // Return an empty list if points is null

      return RouteData(
        id: map['id'] as int?,
        name: map['name'] as String? ?? 'Unnamed Route', // Provide a default name
        start: LatLng(
          map['startLat'] as double? ?? 0.0,
          map['startLng'] as double? ?? 0.0,
        ),
        end: LatLng(
          map['endLat'] as double? ?? 0.0,
          map['endLng'] as double? ?? 0.0,
        ),
        points: points,
      );
    }).toList();
  }

  Future<void> deleteRoute(int id) async {
    final db = await database;
    await db.delete(
      'routes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
