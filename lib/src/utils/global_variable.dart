import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final isTripStartedProvider = StateProvider<bool>((ref) => false);

final pathCoordinatesProvider = StateProvider<List<LatLng>>((ref) => []);

final staticStartingPointProvider = StateProvider<LatLng?>((ref) => null);

final movingLocationProvider = StateProvider<LatLng?>((ref) => null);

class GlobalVariables {
  static int? userId;
  static String? userName;
  static String? realName;
  static String? bio;
  static String? happyPlace;
  static String? odometer;
  static String? garage;
  static String? garageLogoUrl;
  static String? userImageUrl;
  static int? tripCount;
  static String? followingIds;
  static List<dynamic>? dropPinsData;

   static bool isTripStarted = false;
}
