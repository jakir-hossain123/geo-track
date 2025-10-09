import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 1. HiveType Adapter Generation (Run build_runner later)
part 'walk_data.g.dart';

// 2. Data model for a single LatLng point (for Polyline)
@HiveType(typeId: 1)
class LatLngAdapter {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  LatLngAdapter({required this.latitude, required this.longitude});

  // Helper method to convert Hive model to Google Maps LatLng
  LatLng toLatLng() => LatLng(latitude, longitude);

  // Helper method to create Hive model from Google Maps LatLng
  static LatLngAdapter fromLatLng(LatLng latLng) =>
      LatLngAdapter(latitude: latLng.latitude, longitude: latLng.longitude);
}

// 3. Main Data model for a completed walk
@HiveType(typeId: 2)
class WalkData extends HiveObject {
  @HiveField(0)
  final double distanceKm; // Total distance walked in kilometers

  @HiveField(1)
  final int durationMicroseconds; // Total time taken stored as int microseconds (FIX)

  @HiveField(2)
  final DateTime startTime; // Time the walk was started

  @HiveField(3)
  final List<LatLngAdapter> pathPoints; // List of coordinates that make up the path

  @HiveField(4)
  final String userId; // User who completed the walk

  WalkData({
    required this.distanceKm,
    required this.durationMicroseconds,
    required this.startTime,
    required this.pathPoints,
    required this.userId,
  });

  // Helper to get Duration object from saved microseconds
  Duration get duration => Duration(microseconds: durationMicroseconds);

  // Helper to get formatted date string
  String get formattedDate => '${startTime.day}/${startTime.month}/${startTime.year}';

  // Helper to get formatted time string
  String get formattedDuration {
    final d = duration;
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  }
}
